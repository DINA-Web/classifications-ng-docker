#!make

all: clean init build up

init:
	test -f nameindex/backbone.zip || curl --progress -o \
		nameindex/backbone.zip http://rs.gbif.org/datasets/backbone/2017-02-13/backbone.zip

build:
	docker build -t bioatlas/backbone:v0.1 nameindex

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
	docker push bioatlas/backbone:v0.1

