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

lookup_spred = read_csv("data/outputs/single_predicate_insdcSeqRecords.csv")

lookup_spred %>%
  count(downloadKey) %>%
  arrange(desc(n)) -> lookup_spred_f
