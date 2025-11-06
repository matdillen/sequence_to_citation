## acquire matched keys to the gbif backbone for checklists through the 
## gbif species api

library(tidyverse)
library(jsonlite)
library(httr)

baseurl = "https://api.gbif.org/v1/species?datasetKey="

# col xr dataset (coldp)
col = "ac4054f8-c8a9-4a6e-ae39-8bff6c705318"

# iucn gbif dataset
iucnset = "19491596-35ae-4a91-9a98-85cf505f1bd3"

# DAISIE invasive species gbif dataset
invset = "39f36f10-559b-427f-8c86-2d28afff68ca"

#batches of 1000
## will fail after 100.000 (hard api limit)
batches = seq(0,300000,1000)

#initialize results list
resu = list()

# list step variable
listelement = 1

# page the api queries
for (i in batches) {
  req_url = paste0(baseurl,
                   iucnset,
                   "&limit=1000&offset=",
                   i)
  req = GET(req_url)
  reqc = content(req)
  resu[[listelement]] = reqc
  listelement = listelement + 1
  print(i)
}

# convert list to json
resujs = toJSON(resu,pretty=T,auto_unbox=T)

# write to file
write(resujs,"data/outputs/nubkey_iucn_part_until_api_limit.json")


cold = read_tsv(paste0("data/raw/",col,"/NameUsage.tsv"),
                col_types = cols(.default = "c"))

## same approach for invasive species
## this one won't run afoul of the 100k limit
batches = seq(0,20000,1000)
resui = list()
listelement = 1
for (i in batches) {
  req_url = paste0(baseurl,
                   invset,
                   "&limit=1000&offset=",
                   i)
  req = fromJSON(req_url)
  resui[[listelement]] = req
  listelement = listelement + 1
  print(i)
}

# function to merge all results in the list into a single data frame
bind_list_with_missing <- function(df_list) {
  # Get the union of all column names
  all_cols <- unique(unlist(lapply(df_list, names)))
  
  # Add missing columns as NA
  df_list_filled <- lapply(df_list, function(df) {
    missing_cols <- setdiff(all_cols, names(df))
    df[missing_cols] <- NA
    # reorder
    df <- df[all_cols]
    df
  })
  
  # Bind safely
  bind_rows(df_list_filled)
}

all = bind_list_with_missing(resui)
all2=all$results

write_tsv(all2,"data/outputs/daisie_nubkeys.txt",na="")

