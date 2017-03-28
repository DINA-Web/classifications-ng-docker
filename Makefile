#!make

all: clean build up

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