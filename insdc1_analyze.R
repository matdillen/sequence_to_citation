filter(insdc_data[[1]],!is.na(decimalLatitude))
# 2.7M with coordinates (50%)

filter(insdc_data[[2]],!is.na(decimalLatitude))
# 200k with coordinates (14%)

filter(insdc_data[[3]],!is.na(decimalLatitude))
# 178k with coordinates (50%)

filter(insdc_data[[1]],!is.na(eventDate))
# 3.6M with coordinates (69%)

filter(insdc_data[[2]],!is.na(eventDate))
# 1.2M with coordinates (84%)

filter(insdc_data[[3]],!is.na(eventDate))
# 295k with coordinates (81%)

inv_keys = read_tsv("data/outputs/daisie_nubkeys.txt")
inv_keys_nub = inv_keys %>%
  filter(!is.na(nubKey))

#invasive species only
insdc_inv = filter(insdc_data[[1]],taxonKey%in%inv_keys_nub$nubKey)
# filter out higher taxonranks (?)
filter(insdc_inv,taxonRank=="SPECIES")

lookup_spred = read_csv("data/outputs/cited_gbifID.csv")

lookup_downs1 = lookup_downs %>%
  filter(datasetKey=="d8cd16ba-bb74-4420-821e-083f2bac17c2")

lookup_spred %>%
  count(downloadKey) %>%
  arrange(desc(n)) -> lookup_spred_f

lookup_spred %>%
  count(gbifID) %>%
  arrange(desc(n)) -> lookup_spred_idf

spred_tst = lookup_spred %>%
  filter(downloadKey%in%lookup_downs1$downloadKey)

down_tst = lookup_downs1 %>%
  filter(downloadKey%in%lookup_spred$downloadKey)

only_spred = spred_tst %>%
  filter(!gbifID%in%down_tst$gbifID)

only_down = down_tst %>%
  filter(!gbifID%in%spred_tst$gbifID)

notnulls = read_tsv("data/outputs/0020440-251025141854904/occurrence.txt")
