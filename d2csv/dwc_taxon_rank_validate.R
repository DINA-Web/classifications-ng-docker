library(taxize)
library(dplyr)

sciname <- "Alces alces"
dyntaxa_id <- 206046
#GUID: urn:lsid:dyntaxa.se:Taxon:206046

# is dyntaxa a data source?
sources <- gnr_datasources()$title

grep("GBIF", sources)

specieslist <- c(sciname)
classification(specieslist, db = 'gbif')

classification_gbif <- function(sciname) {
  key <- "de8934f4-a136-481c-a87a-b0b202b80a31"
  res <- gbif_name_usage(datasetKey = key, name = sciname)
  
  res <- res$results[[1]]
  
  res <- data_frame(
    taxonID = res$taxonID, 
    scientificName = res$scientificName,
    scientificNameAuthorship = res$authorship,
    taxonRank = res$rank,
    kingdom = res$kingdom,
    phylum = res$phylum,
    class = res$class, 
    order = res$order,
    family = res$family, 
    genus = res$genus, 
    species = res$species 
  )
  
  return (res)
}


classification_gbif(sciname)
classification_gbif("Acrocordia cavata")

vascan_search(q = sciname)
eubon_search(query = sciname)
res$results$sources


library(readr)

dyntaxa_2012 <- 
  read_delim(
    file = "~/repos/dina-web/classifications-ng-docker/nameindex/taxon.tsv",
    delim = "\t", 
    col_name = FALSE) %>% 
  select(scientificName = 2, scientificNameAuthorship = 3, 
         taxonRank = 4, kingdom = 5, phylum = 6, class = 7,
         order = 8, family = 9, genus = 10)

# these are valid field names in dwc Taxon

taxonID | scientificNameID | acceptedNameUsageID | parentNameUsageID | originalNameUsageID | nameAccordingToID | namePublishedInID | taxonConceptID | scientificName | acceptedNameUsage | parentNameUsage | originalNameUsage | nameAccordingTo | namePublishedIn | namePublishedInYear | higherClassification | kingdom | phylum | class | order | family | genus | subgenus | specificEpithet | infraspecificEpithet | taxonRank | verbatimTaxonRank | scientificNameAuthorship | vernacularName | nomenclaturalCode | taxonomicStatus | nomenclaturalStatus | taxonRemarks


