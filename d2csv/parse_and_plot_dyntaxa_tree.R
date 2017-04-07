library(data.tree)
library(readr)
library(tidyverse)
library(igraph)
library(networkD3)

base <- "repos/dina-web/classifications-ng-docker/d2csv/"
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

my_tree[1,]$Parent <- NA

#attrs_df
#anyDuplicated()

#my_tree %>% filter(sciname == "Pristina")
#my_tree[anyDuplicated(my_tree$sciname), ]
#my_tree[anyDuplicated(my_tree$sciname), ]

g <- graph_from_data_frame(directed = TRUE,
  d = t %>% select(1:2) %>% filter(!is.na(Parent)),
  vertices = t %>% select(c(1, 4:3)))

if (!is_dag(g)) 
  warning("This tree has cycles! Warning!")

if (count_components(g) != 1) {
  message("Warning, some vertices/nodes not connected?")
  groups(clu)
}


# querying the graph with igraph

#V(g)["0"]
#V(g)[nei("5000083", mode = "in")]
#V(g)[nei("5000083", mode = "out")]

alces <- V(g)[sciname == "Alces alces"]
root <- V(g)[sciname == "Biota"]
all_simple_paths(g, alces, root)



ranks <- read_csv(paste0(base,"taxonRank.csv"))
res <- 
  left_join(my_tree, ranks, by = c("rank_id" = "taxonRankID")) #%>%
#  select(taxonID, parentNameUsageID, scientificNameID = code, scientificName = ScientificName,  scientificNameAuthorship = author, namePublishedInYear = year,  CommonName, vernacularName = vernacular_names, taxonRankID = taxon_rank_id, taxonRank)




dwc_ranks <- function(my_node) {
  
  ancestor <- 
    all_simple_paths(g, my_node, root, mode = "out") %>%
    unlist %>% names %>% as.double
  
  uranks <- 
    tibble(Id = ancestor) %>% 
    inner_join(my_tree) %>%
    right_join(ranks, by = c("rank_id" = "taxonRankID")) %>%
    mutate(taxonRank = tolower(taxonRank))
  
  composite <- paste(collapse = "|", 
    na.omit(uranks$taxonRank), ":", na.omit(uranks$sciname))

  message(composite)
  
  relevant_ranks <- c(1, 2, 5, 8, 11, 14, 17, 18:20)
  
  out <-
    uranks %>% 
    filter(rank_id %in% relevant_ranks) %>%
    select(taxonRank, sciname) %>%
    spread(key = taxonRank, value = sciname)
    
  bind_cols(
    tibble(id = as.double(my_node$name), composite), 
    out
  )
}

# calling with single node
map_df(alces, dwc_ranks)

testy <- map_df(V(g)[90000], dwc_ranks)
View(testy)

# calling with multiple nodes
testy <- map_df(V(g)[2:3], dwc_ranks)
View(testy)

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
