#!make

all: clean init build up

init:
	#test -f nameindex/dwca-col-mammals.zip || curl --progress -o nameindex/dwca-col-mammals.zip \
	#	https://s3.amazonaws.com/ala-nameindexes/20140610/dwca-col-mammals.zip

dyntaxa-dl:
	docker build -t dina/pythonr d2csv
	docker run --rm -it --user rstudio \
		-v $(PWD)/d2csv:/home/rstudio/foo \
		-w /home/rstudio/foo \
		dina/pythonr \
	sh -c "make ID=0"
#	sh -c "make ID=5000013"

build:
	docker build -t dina/ala-nameindex:v0.1 nameindex

clean:
	docker-compose down

debug:
	docker-compose run nameindexer

up:
	docker-compose up

backup:
	docker-compose run backup \
		ash -c "tar cvfz /tmp/idx.tgz /data/lucene/namematching"

release:
	docker push dina/ala-nameindex:v0.1

