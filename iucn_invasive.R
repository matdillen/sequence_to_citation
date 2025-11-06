## read the datasets in memory
## big gbif occurrence datasets are trimmed for relevant properties and
## saved as trimmed versions for easier I/O

library(tidyverse)

# iucn checklist from checklistbank
iucn = "8bac10e8-92b8-49f9-afee-5cd9e322a98a"
# DAISIE checklist: https://www.checklistbank.org/dataset/25428/about
invas = "f53d23dc-6201-475c-9bac-182a67590b71"

# three INSDC datasets (keys for the dataset downloads)
insdc = c("0013170-251025141854904",
          "0013172-251025141854904",
          "0013173-251025141854904")

# selected properties from the INSDC datasets
colsn = readLines("data/gbif_insdc_cols.txt",warn=F)

## read the invasive data
# invas_data = invas %>%
#   paste0("data/raw/",.,"/NameUsage.tsv") %>%
#   read_tsv(quote="",
#            col_types = cols(.default = "c"))
# 

# read the iucn data
iucn_data = iucn %>%
  paste0("data/raw/",.,"/NameUsage.tsv") %>%
  read_tsv(quote="",
           col_types = cols(.default = "c"))

iucn_canonu = iucn_data %>%
  filter(!duplicated(`col:scientificName`))

## quickly scan presence of properties in the dwc occurrence core
# qco <- function(coln,data=insdc_data_b) {
#   return(count(data,{{coln}}))
# }

## pre select the dataset, dropping unneeded columns and save as trimmed file
# library(data.table)
# i=3
# vec = rep("character",length(colsn))
# names(vec) = colsn
# file = paste0("data/raw/",insdc[i],"/occurrence.txt")
# insdc_data = fread(file,sep="\t",
#                            quote="",
#                            select = vec)
# write_tsv(insdc_data,gsub("/occurrence.txt","/occurrence_trim.txt",file,fixed=T),na="")


# read the truncated INSDC data from GBIF
## truncated using above scripts with fread
insdc_data = list()
for (i in 1:length(insdc)) {
  file = paste0("data/raw/",insdc[i],"/occurrence_trim.txt")
  insdc_data[[i]] = read_tsv(file,
                             quote="",
                            col_types = cols(.default = "c"))
  print(i)
}

iucn1 = insdc_data[[1]] %>%
  filter(!is.na(iucnRedListCategory),
         iucnRedListCategory!="LC")

# investigate accuracy of GBIF iucn property
qj = left_join(iucn1,
                select(iucn_canonu,
                       `col:scientificName`,
                       `col:ID`),
                by=c("species"="col:scientificName"))

## issues still with duplicates: 

