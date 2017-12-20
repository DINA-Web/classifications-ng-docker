ID = 0

all: taxonRank dl tsv

dl: taxonRank
	@echo "Downloading from Dyntaxa for ID = $(ID)"
	@python dyntaxa.py --id $(ID)

attribs:
	@echo "Extracting taxon attribs"
	@cp $(ID).xml dyntaxa.xml
	@./d2csv.sh $(ID)
	@cp $(ID).csv attribs.csv

tsv: attribs
	@echo "Creating tsv"
	#@Rscript ./d2csv.R
	@Rscript ./dwca-dyntaxa.R
	@cp tree.csv rels.csv
	@rm -f dyntaxa.xml tree.csv dyntaxa.csv $(ID).csv

taxonRank:
	@echo "Downloading Dyntaxa Taxon Rank Map"
	@python taxonRank.py

clean:
	@rm -f taxonRank.csv dyntaxa-dwca.tsv  rels.csv attribs.csv
