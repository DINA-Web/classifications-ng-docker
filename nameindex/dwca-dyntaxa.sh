#!/bin/bash

echo "Converting from DOS CR lineendings to Mac/Linux LF lineendings ---> taxon.tsv"
unzip dwca-dyntaxa.zip taxon.txt
tr "\r" "\n" < taxon.txt > taxon.tsv
rm taxon.txt
