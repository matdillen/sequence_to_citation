## mine the specific gbifIDs for a small set of datasets which were used
## in locally available gbif downloads (zip files)

library(tidyverse)

# three INSDC datasets
insdc = c("d8cd16ba-bb74-4420-821e-083f2bac17c2",
          "393b8c26-e4e0-4dd0-a218-93fc074ebf4e",
          "583d91fe-bbc0-4b4a-afe1-801f88263016")

# list of downloaded zip files (incomplete sample)
downed = list.files("data/gbifdownloads/",
                    full.names = T)
downed_info = file.info(downed)

# only process zip files < 1GB to not run out of RAM
downed_manageable = downed_info %>%
  filter(size<1000000000)

# initialize lookup list gbifID per downloadKey
# including which of the three datasets
lookup_downs = tibble(gbifID = character(0),
                      datasetKey = character(0),
                      downloadKey = character(0))

# process all zip files
for (i in 1:dim(downed_manageable)[1]) {
  # test if a simple occurrence or a dwc archive
  test_content = unzip(rownames(downed_manageable)[i],
                       list=T) %>%
    nrow()
  
  # derive the downloadKey
  download_key = rownames(downed_manageable)[i] %>%
    gsub("data/gbifdownloads/",
         "",
         .,fixed=T) %>%
    gsub(".zip",
         "",
         .,fixed=T)
  
  # simple occurrence (1 tsv file)
  if (test_content==1) {
    filehandle = unzip(rownames(downed_manageable)[i])
    data = read_tsv(filehandle,
             quote="",
             col_select = all_of(c("gbifID","datasetKey"))) %>%
      filter(datasetKey%in%insdc) %>%
      mutate(downloadKey = download_key)
    lookup_downs = rbind(lookup_downs,data)
    file.remove(filehandle)
  } else {
    # dwc archive, look for occurrence core
    filehandle = unzip(rownames(downed_manageable)[i],
                       files = "occurrence.txt")
    data = read_tsv(filehandle,
                    quote="",
                    col_select = all_of(c("gbifID","datasetKey"))) %>%
      filter(datasetKey%in%insdc) %>%
      mutate(downloadKey = download_key)
    lookup_downs = rbind(lookup_downs,data)
    file.remove(filehandle)
  }
  print(i)
}

write_tsv(lookup_downs,"data/outputs/gbifids_per_downloadKey_filebased.txt")

lookup_downs = read_tsv("data/outputs/gbifids_per_downloadKey_filebased.txt")
