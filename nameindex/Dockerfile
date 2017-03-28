FROM openjdk:7-alpine

RUN mkdir -p /data/lucene/sources
COPY dwca-col-mammals.zip /data/lucene/sources/
RUN	unzip /data/lucene/sources/dwca-col-mammals.zip -d /data/lucene/sources/
RUN rm /data/lucene/sources/dwca-col-mammals.zip

COPY nameindexer.zip /usr/lib/nameindexer/
RUN unzip -o /usr/lib/nameindexer/nameindexer.zip -d /usr/lib/nameindexer
COPY lib/log4j.xml /usr/lib/nameindexer/
COPY nameindexer.sh /usr/lib/nameindexer/nameindexer

RUN chmod 777 /usr/lib/nameindexer/nameindexer && \
	mv /usr/lib/nameindexer/ala-name-matching-2.3.1.jar /usr/lib/nameindexer/nameindexer.jar && \
	cat /usr/lib/nameindexer/nameindexer.jar >> /usr/lib/nameindexer/nameindexer && \
	ln -s /usr/lib/nameindexer/nameindexer /usr/bin/nameindexer

RUN nameindexer --dwca /data/lucene/sources/dwca-col-mammals

VOLUME /data/lucene