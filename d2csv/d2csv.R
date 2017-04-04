library(xml2)
library(dplyr)
library(purrr)
library(data.tree)
library(readr)
library(tidyr)

base <- paste0(getwd(), "/")  # "~/repos/dina-web/dw-classifications/plutof-data/"
header <- readLines(paste0(base, "header.xml"))
footer <- readLines(paste0(base, "dyntaxa.xml"), warn = FALSE)[-c(1:5)]
doc <- paste(collapse = "\n", c(header, footer))

# parse Dyntaxa XML tree using xpath expressions for nodes and their parents
xml <- read_xml(doc)
ns <- xml_ns(xml)
taxa <- xml_find_all(xml, "//a:Taxon/a:Id/..", ns)

xml2int <- function(x) 
  as.numeric(xml_text(x))

get_taxon_id <- function(xml) 
  xml2int(xml_find_all(xml, "./a:Id", ns))

ids <- map(taxa, get_taxon_id)

get_parent <- function(xml) 
  xml2int(xml_find_all(xml, "../../../a:Taxon/a:Id", ns))

parents <- map(taxa, get_parent)

links <-
  data_frame(
    Id = as.numeric(ids), 
    Parent = as.numeric(parents)) %>%
  distinct

out <- paste0(base, "tree.csv")
write.csv(links, file = out, row.names = FALSE)
links <- tbl_df(read.csv(file = out))

# combine tree relations and node data into one dataset
nodes <- tbl_df(read.csv(file = paste0(base, "attribs.csv"), 
 header = TRUE, sep = "\t", stringsAsFactors = FALSE, encoding = "utf8"))

nodelink <- 
  nodes %>% mutate(Id = as.numeric(Id)) %>%
  filter(!is.na(Id)) %>%
  left_join(links, by = "Id") %>%
  select(Parent, Id, everything())

out <- paste0(base, "dyntaxa.csv")
write.csv(nodelink, file = out, row.names = FALSE)
nodelink <- tbl_df(read.csv(file = out))

tsv <- 
  nodelink %>% 
  select(taxonID = Id, parentNameUsageID = Parent,
         taxon_rank_id = CategoryId, author = Author,
         code = Guid, everything()) %>%
  mutate(CommonName = trimws(CommonName)) %>%
  mutate(use_parentheses = ifelse(grepl("(", author, fixed = TRUE), 1, NA)) %>%
  mutate(year = as.integer(gsub(".*?(\\d{1,4}).*", "\\1", perl = TRUE, author))) %>%
  mutate(vernacular_names = ifelse(is.na(CommonName) | CommonName == "", NA, paste0(CommonName, ":swe")))

v <- gsub("[()\\]\\[]", "", tsv$author, perl = TRUE)
a <- gsub(",*\\s*\\[*\\d{4}\\]*", "", v, perl = TRUE)
tsv$author <- a

dwca <- tsv %>%
  # do not include Cultivar, Population, Collective taxon,
  # Species complex, Morphotype/Morfotyp, Organism group,
  # Microspecies, Cultivar group
  filter(!(taxon_rank_id %in% c(22, 23, 27, 28, 32, 33, 50, 51))) %>%
  # recode hybrids to species because DarwinCore prefers that
  mutate(taxon_rank_id = ifelse(taxon_rank_id == 21, 17, taxon_rank_id)) %>%
  select(everything())

# NB: this relies on the taxonRank.py to have been executed (Makefile will do that)
ranks <- read.csv(paste0(base, "taxonRank.csv"))
res <- left_join(dwca, ranks, by = c("taxon_rank_id" = "taxonRankID")) %>%
  # remap column names to fit with Darwin Core column names
  select(taxonID, parentNameUsageID, scientificNameID = code, 
         scientificName = ScientificName,  scientificNameAuthorship = author, 
         namePublishedInYear = year,  CommonName, 
         vernacularName = vernacular_names, taxonRankID = taxon_rank_id, taxonRank)

res <- arrange(res,taxonRankID)
res[which(is.na(res$parentNameUsageID)), ]$parentNameUsageID <- 0

out <- paste0(base, "dyntaxa-dwca.tsv")
write.table(res, file = out, sep = "\t",
  row.names = FALSE, na = "", quote = FALSE)

my_tree <- FromDataFrameNetwork(as.data.frame(res))
#print(my_tree, "level")

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
# ancestors_as_df(my_node)

# demo how to traverse tree, get ancestors for all those nodes
my_nodes <- Traverse(my_tree, c("level"))

ancestors <- map_df(my_nodes, ancestors_as_df)

# the closure table in "ancestors" contains 
# edges from self to self with distance 0 hops
# we're mostly not interested in those edges/relations

df <- 
  ancestors #%>% 
  #filter(distance > 0)

# for now, just use the CategoryId attribute
# we select those columns and throw the rest away
attribs <- 
  res %>% 
  select(Id = taxonID, CategoryId = taxonRankID, 
         ScientificName = scientificName)

relevant_ranks <- c(1, 2, 5, 8, 11, 14, 17, 18:20)

lu <-
  ranks %>%
  filter(taxonRankID %in% relevant_ranks) %>%
  select(CategoryId = taxonRankID, Category = taxonRank)

# add the rank descrption as node attributes 
# and focus only on nodes of relevant ranks
attrs <-  
  attribs %>% 
  filter(CategoryId %in% relevant_ranks) %>%
  right_join(lu)

# decorate the closure table with ancestor rank data
decorated <- 
  df %>% 
  right_join(attrs, by = c("ancestor" = "Id")) %>%
  #  filter(node == 6007253) %>%
  select(-c(2:3))  # skip just some columns, select the rest

# now we want to pivot (or spread data) to get 
# specific rank levels for nodes across columns

wide <- 
  decorated %>% 
  select(-CategoryId) %>%
  spread(key = Category, value = ScientificName, fill = NA) %>%
  select(taxonId = node, Kingdom, Phylum, Class, Order, Family, Genus, Species) 

out <- 
  tsv %>% left_join(wide, by = c("taxonID" = "taxonId"))

write.csv(out, "taxon.csv", row.names = FALSE)

