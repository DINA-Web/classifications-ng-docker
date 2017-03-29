# parse tabular data into tree

library(data.tree)
library(readr)

# read Dyntaxa tabular dataset and parse into a tree
base <- "~/repos/dina-web/classifications-docker/d2csv/"
tsv <- read_delim(file = paste0(base, "dyntaxa.tsv"), delim = "\t")
old <- as.data.frame(tsv)

my_tree <- FromDataFrameNetwork(old, check = c("check"))

# example of how to get a node by its id: 
my_node <- FindNode(my_tree, 248420)




# create a closure table for the tree

library(purrr)
library(dplyr)

# fcn to get ancestors as a "long" data frame
# on the form: from_node, to_node, distance/hops
ancestors_as_df <- function(my_node) {
  node <- my_node$name
  ancestor <- rev(my_node$path)
  distance <- (1:my_node$level) - 1
  
  data_frame(#stringsAsFactors = FALSE,
    node = as.double(node), 
    ancestor = as.double(ancestor), 
    distance
  )
}

# demo how to get ancestors for just one single node
ancestors_as_df(my_node)

# demo how to traverse tree, get ancestors for all those nodes
my_nodes <- Traverse(my_tree, c("level"))
ancestors <- map_df(my_nodes, ancestors_as_df)

# the closure table in "ancestors" contains 
# edges from self to self with distance 0 hops
# we're mostly not interested in those edges/relations

df <- 
  ancestors %>% 
  filter(distance > 0)

# demo how to use the df closure table 
# to get ancestors for a given node id
df %>% filter(node == 248439)


# now we want to have rank data 
# for each node at specific rank levels
# for this we need to know each node's
# categoryId/rank
  
# get category/rank for each node
attribs <- read_delim(
  delim = "\t",
  file = "~/repos/dina-web/classifications-docker/d2csv/attribs.csv"
)

# for now, just use the CategoryId attribute
# we select those columns and throw the rest away
attribs <- 
  attribs %>% 
  select(Id, CategoryId, ScientificName)

# demo: what unique rank ids are represented?
rank_ids <- 
  df %>% 
  left_join(attribs, by = c("node" = "Id")) %>%
  .$CategoryId %>%
  unique

rank_ids

# choose a set of n ranks that we need for each node
# five_ranks <- sample(rank_ids, size = 5, replace = FALSE)
five_ranks <- sort(rank_ids)[1:5]

# use a bogus lookup for ranks for now ...
# this needs to be replaced by proper data

lu <- data_frame(
  CategoryId = five_ranks, 
  Category = c("Kingdom", "Phylum", "Species", "Genus", "Hybrid")
)

# add the rank descrption as node attributes 
# and focus only on nodes of relevant ranks
attrs <-  
  attribs %>% 
  filter(CategoryId %in% five_ranks) %>%
  left_join(lu)

# decorate the closure table with ancestor rank data
res <- 
  df %>% 
  right_join(attrs, by = c("ancestor" = "Id")) %>%
#  filter(node == 6007253) %>%
  select(-c(2:3))  # skip just some columns, select the rest

# demo how to retrieve all nodes for a specific rank
res %>% filter(CategoryId == 8)



# now we want to pivot (or spread data) to get 
# specific rank levels for nodes across columns

library(tidyr)

wide <- 
  res %>% 
  select(-CategoryId) %>%
  spread(key = Category, value = ScientificName, fill = NA)

# inspect the results
wide
View(wide)

# compare count to original data
tally(wide)
nrow(tsv)
