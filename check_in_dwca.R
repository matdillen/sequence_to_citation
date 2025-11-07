check_in_dwca <- function(download_key, id) {
  
  path = paste0("data/gbifdownloads/",download_key,".zip")
  # test if a simple occurrence or a dwc archive
  test_content = unzip(path,
                       list=T) %>%
    nrow()
  
  # simple occurrence (1 tsv file)
  if (test_content==1) {
    filehandle = unzip(path)
    data = read_tsv(filehandle,
                    quote="",
                    col_types = cols(.default = "c")) %>%
      filter(gbifID%in%id) %>%
      mutate(downloadKey = download_key)
    
    file.remove(filehandle)
  } else {
    # dwc archive, look for occurrence core
    filehandle = unzip(path,
                       files = "occurrence.txt")
    data = read_tsv(filehandle,
                    quote="",
                    col_types = cols(.default = "c")) %>%
      filter(gbifID%in%id) %>%
      mutate(downloadKey = download_key)
    file.remove(filehandle)
  }
  return(data)
}

check_in_dwca("0014974-240202131308920",3347110843)->t

