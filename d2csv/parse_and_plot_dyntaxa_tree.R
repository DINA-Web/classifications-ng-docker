#!/usr/bin/Rscript

#library(data.tree)

library(readr)
library(tidyverse)
library(igraph)
library(networkD3)
library(microbenchmark)

base <- "~/repos/bioatlas/classifications-ng-docker/d2csv/"
tree_file <- paste0(base, "tree.csv")
tree_df <- read.csv(tree_file)

# tree_file <- paset0(base, "dyntaxa-dwca.tsv")
# col_spec <- cols(
#   taxonID = col_double(),
#   parentNameUsageID = col_double(),
#   scientificNameID = col_character(),
#   scientificName = col_character(),
#   scientificNameAuthorship = col_character(),
#   namePublishedInYear = col_integer(),
#   CommonName = col_character(),
#   vernacularName = col_character(),
#   taxonRankID = col_integer(),
#   taxonRank = col_character()
# )
# tree_df <- read_delim(tree_file, delim = "\t", col_types = col_spec)

attrs_file <- paste0(base, "attribs.csv")
attrs_df <- read_tsv(attrs_file)

my_tree <- 
  as_tibble(tree_df) %>% 
  mutate(Parent = as.double(Parent)) %>%
  left_join(attrs_df) %>%
  filter(!is.na(Id), !is.na(Parent)) %>%
  select(1:2, rank_id = CategoryId, sciname = ScientificName) %>%
  filter(!is.na(rank_id)) %>%
  filter(!is.na(sciname)) %>%
  mutate(sciname2 = paste(sciname, Id))

t <- bind_rows(
  tibble(Id = 0, Parent = NA, rank_id = NA, sciname = "Biota"),
  my_tree
)

#any(is.na(my_tree$rank_id))

#my_tree[duplicated(my_tree$sciname2),]


#my_tree <- 
#  as_tibble(tree_df) %>%
#  mutate(Id = as.integer(Id)) %>%
#  select(from = 2, to = 1) %>%
#  arrange(from) %>%
#  filter(!is.na(2))

#my_tree[1,]$Parent <- NA

#attrs_df
#anyDuplicated()

#my_tree %>% filter(sciname == "Pristina")
#my_tree[anyDuplicated(my_tree$sciname), ]
#my_tree[anyDuplicated(my_tree$sciname), ]

e <- t %>% select(from = 2, to = 1)  %>% filter(!is.na(from))
v <- t %>% select(c(1, 4:3))
g <- graph_from_data_frame(directed = TRUE, d = e, vertices = v)


if (!is_dag(g)) 
  warning("This tree has cycles! Warning!")

if (count_components(g) != 1) {
  warning("Warning, some vertices/nodes not connected?")
  message("Groups: ", groups(count_components(g)))
}


# querying the graph with igraph

# V(g)[nei("0", mode = "out")]
# V(g)[nei("5000083", mode = "in")]
# V(g)[nei("5000083", mode = "out")]
# 
# alces <- V(g)[sciname == "Alces alces"]
# root <- V(g)[sciname == "Biota"]
# 
# # avg of 30 ms
# microbenchmark(
#   all_simple_paths(g, root, alces)
# )

# avg of 3 ms
# microbenchmark(
#   subcomponent(g, alces, "in")
# )
# 
# alces$rank_id
# alces$sciname
# 
# subcomponent(g, alces, "out")$sciname
# 
ranks <- read_csv(paste0(base,"taxonRank.csv"))
res <- 
  left_join(my_tree, ranks, by = c("rank_id" = "taxonRankID")) #%>%
#  select(taxonID, parentNameUsageID, scientificNameID = code, scientificName = ScientificName,  scientificNameAuthorship = author, namePublishedInYear = year,  CommonName, vernacularName = vernacular_names, taxonRankID = taxon_rank_id, taxonRank)




# dwc_ranks <- function(my_node) {
#   
# #  ancestor <- 
# #    all_simple_paths(g, my_node, root, mode = "out") %>%
# #    unlist %>% names %>% as.double
#  
#   ancestor <- as.double(names(
#     subcomponent(g, my_node, mode = "in")))
#   
#   uranks <- 
#     tibble(Id = ancestor) %>% 
#     inner_join(my_tree, by = "Id") %>%
#     right_join(ranks, by = c("rank_id" = "taxonRankID")) %>%
#     mutate(taxonRank = tolower(taxonRank))
#   
#   composite <- paste(collapse = " | ", 
#     uranks$taxonRank, ":", ifelse(is.na(uranks$sciname), "NA", uranks))
# 
# #  message("Processing ", my_node$name)
#   
#   relevant_ranks <- c(1, 2, 5, 8, 11, 14, 17, 18:20)
#   
#   out <-
#     uranks %>% 
#     filter(rank_id %in% relevant_ranks) %>%
#     select(taxonRank, sciname) %>%
#     spread(key = taxonRank, value = sciname)
#     
#   bind_cols(
#     tibble(id = as.double(my_node$name), composite), 
#     out
#   )
# }
# 
# # calling with single node
# map_df(alces, dwc_ranks)
# 
# testy <- map_df(V(g)[90000], dwc_ranks)
# 
# # calling with multiple nodes
# testy <- map_df(V(g)[1:100], dwc_ranks)
# View(testy)
# 
# microbenchmark::microbenchmark(times = 1,
#   neighbors(graph = g, v = V(g)[5], mode = "in")
# )
# 
# microbenchmark::microbenchmark(times = 1,
#   subcomponent(graph = g, v = V(g)[5], mode = "in")
# )
# 
# all_simple_paths(graph = g, from = root, to = V(g)[5], )

# system.time(
#   shortest_paths(g, alces, root, mode = "out")
# )
# 
# system.time(
#   all_simple_paths(g, alces, root, mode = "out")
# )

# library(purrr)
# 
# V(g)[1]
# 
# system.time(
#   ancestors_df <- map_df(V(g)[2:1000], ancestors_as_df)
# )



# D3 JS plot
#simpleNetwork(my_tree %>% slice(1:10))

# igraph static plot
#coords <- layout_with_fr(g)
#plot(g, layout = coords)

library(stringi)

i <- 0

dwc_rankz <- function(node) {
  
  n <- subcomponent(g, node, "in")
  
  ancestors <- tibble(
    id = node$name, 
    parent_id = n$name, 
    rank_id = n$rank_id, 
    sciname = n$sciname
  )
  
  uranks <- 
    ancestors %>% 
    right_join(ranks, by = c("rank_id" = "taxonRankID")) %>%
    mutate(taxonRank = stri_trans_totitle(taxonRank))
  
  if (anyDuplicated(uranks$taxonRank)) {
    message("Duplicated ranks for ", node$name, " ie ", node$sciname)
    print(uranks[duplicated(uranks$taxonRank), ])
    uranks <- uranks[!duplicated(uranks$taxonRank), ]
    warning("Pruning duplicated ranks for node ", node$name, " ... data loss?")
  }
  
  composite <- 
    uranks %>% 
    filter(!is.na(taxonRank) & !is.na(sciname))

  higherClassification <- NA
  
  if (nrow(composite) > 0) {
    higherClassification <- paste(collapse = " | ", 
      composite$sciname)
    composite <- paste(collapse = " | ", sep = " : ",
                       composite$taxonRank, composite$sciname)
  } else {
    composite <- NA
  }
  
  i <<- i + 1
  if (i %% 1000 == 0) {
    message("Processing ", node$name, "(#", i, ")")
  }
  message(".", appendLF = FALSE)
  
  relevant_ranks <- c(1, 2, 5, 8, 11, 14, 17, 18:20)
  
  out <-
    uranks %>% 
    filter(rank_id %in% relevant_ranks) %>%
    select(taxonRank, sciname) %>%
    spread(key = taxonRank, value = sciname)
  
  bind_cols(
    tibble(id = as.double(node$name), 
           composite = composite,
           higherClassification = higherClassification), 
    out
  )
  
}

#RA guest
#H-VW1962

# find all leaves, get all shortest paths for those and...
# http://stackoverflow.com/questions/31406328/all-paths-in-directed-tree-graph-from-root-to-leaves-in-igraph-r

#microbenchmark(times = 1,
  V(g)["3000110"]$rank_id <- 9
#  res <- map_df(V(g)[V(g)$sciname == "Pristina"], dwc_rankz)
#  res <- map_df(V(g)["101076"], dwc_rankz)
  res <- map_df(V(g), dwc_rankz)
#)

print(res)

ranks_file <- paste0(base, "ranky.tsv")

write_csv(res, ranks_file)

#res <-   map_df(V(g), dwc_rankz)

# find root and leaves (are the directions switched?)
#leaves <- which(degree(g, v = V(g), mode = "in") == 0, useNames = T)
#rooty <- which(degree(g, v = V(g), mode = "out") == 0, useNames = T)
#all_simple_paths(g, from = root, to = V(g)[leaves], mode = "in")
