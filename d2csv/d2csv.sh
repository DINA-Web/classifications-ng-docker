#!/bin/bash

# ---------------------------------------------------------------------
# __author__ = "Markus Skyttner"
# __license__ = "AGPLv3"
#
# ---------------------------------------------------------------------

ids="$1"

for id in $ids
do
  # this modifies the xml dl; sets a valid xml header
  cat header.xml > temp.xml
  tail -n +6 $id.xml >> temp.xml
  mv temp.xml ul.$id.xml
  mv ul.$id.xml $id.xml
  python d2csv.py --id $id
done

