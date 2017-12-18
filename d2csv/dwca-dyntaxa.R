#!/usr/bin/Rscript

#library(data.tree)

library(readr)
library(tidyverse)
library(igraph)
library(networkD3)
library(microbenchmark)


base <- "~/repos/bioatlas/classifications-ng-docker/d2csv/"

tree_df <- read_csv(
  paste0(base, "tree.csv"), 
  col_types = "dd"
)

ranks_df <- read_csv(
  paste0(base,"taxonRank.csv"), 
  col_types = "dcclldd"
)

# NB initial fail below because some field where not trimmed
# without whitespace stripped -> 26 data erros in Dyntaxa
# d = decimal, c = character, l = logical, T = datetime
attrs_df <- read_tsv(
  attrs_file <- paste0(base, "attribs.csv"), 
  col_types = "dcddcdTcdlllldTcdTT"
)

my_tree <- 
  tree_df %>% 
  left_join(attrs_df, by = "Id") %>%
  filter(!is.na(Id), !is.na(Parent)) %>%
  select(
    taxonID = Id, parentNameUsageID = Parent,
    scientificName = ScientificName, 
    scientificNameAuthorship = Author,
    rank_id = CategoryId,
    is_valid = IsValid
  ) %>%
  filter(!is.na(rank_id), !is.na(scientificName)) %>%
  mutate(acceptedNameUsageID = ifelse(is_valid, scientificName, NA)) %>%
  left_join(ranks_df, by = c("rank_id" = "taxonRankID")) %>%
  select(
    taxonID, 
    parentNameUsageID,
    scientificName,
    acceptedNameUsageID,
    scientificNameAuthorship, 
    taxonRank
  )

# parse vertices and edges as graph
# then validate that there are no cycles etc

v <- bind_rows(
  tibble(taxonID = 0, parentNameUsageID = NA, scientificName = "Biota"),
  my_tree
)

e <- v %>% select(from = 2, to = 1)  %>% filter(!is.na(from))

g <- graph_from_data_frame(directed = TRUE, d = e, vertices = v)

if (!is_dag(g)) 
  warning("This tree has cycles! Warning!")

if (count_components(g) != 1) {
  warning("Warning, some vertices/nodes not connected?")
  message("Groups: ", groups(count_components(g)))
}

# export to text and Darwin Core Archive

library(stringi)

meta <- read_lines(paste0(base, "dwca-meta-template.xml"))
field <- grep("##", meta, value = TRUE)
step1 <- stri_replace_all_fixed(field, "##index_number##", 1:length(names(v)))
step2 <- stri_replace_all_fixed(step1, "##dwc_term##", names(v))
out_meta <- stri_replace_first_fixed(meta, field, paste0(collapse = "\n", step2))

eml <- read_lines(paste0(base, "dwca-eml-template.xml"))
out_eml <- stri_replace_first_fixed(eml, 
  "<pubDate>2012-03-08</pubDate>", "<pubDate>2017-05-16</pubDate>")


file_dwca <- path.expand(paste0(base, "dwca-dyntaxa.zip"))
file_meta <- "meta.xml"
file_data <- "taxon.txt"
file_eml <- "eml.xml"


current_wd <- getwd()
setwd(dirname(file_dwca))

write_lines(out_meta, file_meta)
write_lines(out_eml, file_eml)
write_tsv(v, file_data)

zip(
  zipfile = basename(file_dwca), 
  files = c(file_meta, file_data, file_eml)
)

setwd(current_wd)

