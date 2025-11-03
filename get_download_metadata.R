library(tidyverse)
library(jsonlite)

#list of downloads for the three sample INSDC datasets
# taken through e.g. https://api.gbif.org/v1/literature/export?gbifDatasetKey=d8cd16ba-bb74-4420-821e-083f2bac17c2
downloads = read_csv("data/overviewCitedData.csv")

# filter out those without a key
downloads_wkey = filter(downloads,!is.na(downloadKey))

#test = fromJSON("https://api.gbif.org/v1/occurrence/download/0013172-251025141854904")

#initialize list to store the responses
store = list()

# batch acquire the download metadata, including the query (predicate) used
print(Sys.time())
for (i in 2645:4826) {
  query = paste0("https://api.gbif.org/v1/occurrence/download/",downloads_wkey$downloadKey[i])
  #this one can crash with ssl connect error, so ideally would be wrapped in try
  # and feature a failed list for later retrying
  r = fromJSON(query)
  store[[i]] = r
  if (i %% 20 == 0) {print(i)}
}
print(Sys.time())

# attach the keys to this list
names(store) = downloads_wkey$downloadKey

# create json object
obj = toJSON(store,pretty=T, auto_unbox = T)

# write json object
write(obj,"data/downloads_metadata.json")
