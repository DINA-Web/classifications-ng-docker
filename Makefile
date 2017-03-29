#!make

all: clean init build up

init:
	#test -f nameindex/dwca-col-mammals.zip || curl --progress -o nameindex/dwca-col-mammals.zip \
	#	https://s3.amazonaws.com/ala-nameindexes/20140610/dwca-col-mammals.zip

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

