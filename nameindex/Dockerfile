FROM openjdk:7-alpine

RUN mkdir -p /data/lucene/sources/dwca-dyntaxa
COPY dwca-dyntaxa.zip /data/lucene/sources/
RUN	unzip /data/lucene/sources/dwca-dyntaxa.zip -d /data/lucene/sources/dwca-dyntaxa
RUN rm /data/lucene/sources/dwca-dyntaxa.zip

COPY nameindexer.zip /usr/lib/nameindexer/
RUN unzip -o /usr/lib/nameindexer/nameindexer.zip -d /usr/lib/nameindexer
COPY lib/log4j.xml /usr/lib/nameindexer/
COPY nameindexer.sh /usr/lib/nameindexer/nameindexer



RUN chmod 777 /usr/lib/nameindexer/nameindexer && \
	mv /usr/lib/nameindexer/ala-name-matching-2.3.1.jar /usr/lib/nameindexer/nameindexer.jar && \
	cat /usr/lib/nameindexer/nameindexer.jar >> /usr/lib/nameindexer/nameindexer && \
	ln -s /usr/lib/nameindexer/nameindexer /usr/bin/nameindexer

# java –jar ala-name-matching-2.1.jar --all \
# --dwca /data/names/dwca-col \
# --target /data/lucene/testdwc-namematching \
# --irmng /data/names/irmng/IRMNG_DWC_HOMONYMS \
# --common /data/names/col_vernacular.txt
RUN nameindexer --dwca /data/lucene/sources/dwca-dyntaxa

VOLUME /data/lucene
 