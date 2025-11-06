## script to acquire metadata of gbif download objects, including the 
## predicate query

library(tidyverse)
library(jsonlite)
library(httr)

#list of downloads for the three sample INSDC datasets
# taken through e.g. https://api.gbif.org/v1/literature/export?gbifDatasetKey=d8cd16ba-bb74-4420-821e-083f2bac17c2
downloads = read_csv("data/overviewCitedData.csv")

# filter out those without a key
downloads_wkey = downloads %>%
  filter(!is.na(downloadKey)) %>%
  filter(!duplicated(downloadKey))

#test = fromJSON("https://api.gbif.org/v1/occurrence/download/0013172-251025141854904")

#initialize list to store the responses
store = list()

# batch acquire the download metadata, including the query (predicate) used
print(Sys.time())
for (i in 1:dim(downloads_wkey)[1]) {
  query = paste0("https://api.gbif.org/v1/occurrence/download/",
                 downloads_wkey$downloadKey[i])

  r = GET(query)
  rc = content(r)
  store[[i]] = rc
  if (i %% 20 == 0) {print(i)}
}
print(Sys.time())

# attach the keys to this list
names(store) = downloads_wkey$downloadKey

# create json object
store_js = toJSON(store,pretty=T, auto_unbox = T)

# write json object
write(store_js,"data/outputs/downloads_metadata.json")

# read json object

downloads_metadata = fromJSON("data/outputs/downloads_metadata.json")