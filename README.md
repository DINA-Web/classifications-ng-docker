``` console
┏━╸╻  ┏━┓┏━┓┏━┓╻┏━╸╻┏━╸┏━┓╺┳╸╻┏━┓┏┓╻┏━┓   ┏┓╻┏━╸   ╺┳┓┏━┓┏━╸╻┏ ┏━╸┏━┓
┃  ┃  ┣━┫┗━┓┗━┓┃┣╸ ┃┃  ┣━┫ ┃ ┃┃ ┃┃┗┫┗━┓╺━╸┃┗┫┃╺┓╺━╸ ┃┃┃ ┃┃  ┣┻┓┣╸ ┣┳┛
┗━╸┗━╸╹ ╹┗━┛┗━┛╹╹  ╹┗━╸╹ ╹ ╹ ╹┗━┛╹ ╹┗━┛   ╹ ╹┗━┛   ╺┻┛┗━┛┗━╸╹ ╹┗━╸╹┗╸
```

# Introduction

This is a integration project that packages the Classifications module as a set of docker component.

# Usage

A number of files are involved in using this module. 

- The Makefile lists VERBS that start, stop, build services etc. 
- The `docker-compose.yml` file lists the NOUNS ie various involved services or components.

Required system dependencies include `make`, `docker` and `docker-compose`.

## Makefile

There is a Makefile for managing this composition of component:

-   make ... use this for building the image from scratch and starting up the first time (it runs init once and creates db)
-   make clean ... use this for cleaning out and removing stuff completely
-   make stop ... use this to stop a running system
-   make up ... use this to start a stopped system

## Loading content

Content is provided as `nameindex/dwca-dyntaxa.zip` with Dyntaxa data from 2012 in DarwinCore Archive format.

Use `make build` to generate the image, and push to Docker Hub with `make release`.

Use `make dyntaxa-dl` to pull up-to-date Dyntaxa data

## Notes related to practices for loading data in a national checklist

A great primer is available here, please read it: https://github.com/AtlasOfLivingAustralia/bie-index/blob/master/doc/nameology/index.md

In the context of Dyntaxa, the following notes may provide some rules of thumb or guidelines to follow:

- When loading the Dyntaxa checklist from a Darwin Core Archive, not all Darwin Core fields need to be populated. In fact, providing a richer set of fields (such as higher ranks etc for each record) will not necessarily make use of those, so avoiding to provide fields beyond what is strictly required may even save some time and reduce complexity of pre-processing tasks. 

- If the field `acceptedNameUsageID` has a value containing the identifier ID another taxon, the record is a synonym.

- A value of "accepted" for `taxonomicStatus` indicates the status of the use of the scientificName as a label for a taxon (other valid values are "invalid", "misapplied", "homotypic synonym".

- The field `taxonConceptID` can be used with an identifier for the taxonomic concept to which the record refers - not for the nomenclatural details of a taxon.

- Even if namematching finds no match, a search could still be made using the raw name but such a name would be "orphaned" in the sense that a search for a higher rank would not be able to include anything that cannot be matched (obviously).

- For homonyms (such as Ananthe, which can refer both a bird and a plant, or Passer which is also a homonym), you need more information such as higher ranks that can help in distinguishing these. A dataset from IRMNG with homonyms can be extended with additional homonyms (if present beyond what is available in that dataset) and loaded.

- When loading several DwCA-files, the nameindex component expects there to be no overlaps (it doesn't merge, this needs to happen as a pre-processing step).

- In the Atlas of Living Australia components, there is the BIE component - the Biodiversity Explorer - it provides a species component with search functionality that can be called like this "curl species.nbnatlas.org/search/?g=squirrel" which makes a call into a web service wrapping the nameindex library that in turn reads from the lucene index. Some documentation on this is available here: https://github.com/AtlasOfLivingAustralia/bie-index#darwin-core-archive-format-of-taxonomic-information


## TODO / Questions / issues / discussions

- Refactor the dyntaxa conversion to dwca
- What about gettin info for...
	* scientificNameAuthorship - Example: "(Torr.) J.T. Howell", "(Martinovský) Tzvelev", "(Györfi, 1952)".
	* nomenclaturalCode - Examples: "ICBN", "ICZN", "BC", "ICNCP", "BioCode", "ICZN; ICBN"
	* taxonomicStatus - Examples: "invalid", "misapplied", "homotypic synonym", "accepted"
	* nomenclaturalStatus - Examples: "nom. ambig.", "nom. illeg.", "nom. subnud.". 
	* ? why is this in col_mammals.txt? occurrenceStatus - Examples: "present", "absent".
