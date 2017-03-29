#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Script for converting dyntaxa-xml to csv for estonian taxonomy modul

"""
import sys, getopt
import os.path
import xml.etree.cElementTree as cElementTree

__author__ = "Markus Skyttner"
__license__ = "AGPLv3"

#ID = str(3000188)
ID = str(0)
FIELDS = "AlertStatusId, Author, CategoryId, ChangeStatusId, CommonName, CreatedBy, CreatedDate, Guid, Id, IsGraded, IsInRevision, IsPublished, IsValid, ModifiedBy, ModifiedDate, ScientificName, SortOrder, ValidFromDate, ValidToDate"
manual = "d2csv.py --id <default:" + ID + "> --fields '<default:" + FIELDS + ">'"

try:
  opts, args = getopt.getopt(sys.argv[1:], "hci", ["id=", "fields="])
except getopt.GetoptError:
  print manual
  sys.exit(2)

for opt, arg in opts:
  if opt in ("-h", "--help", "-?", "--?"):
    print manual
    sys.exit()
  elif opt in ("-i", "--id"):
     ID = arg
  elif opt in ("-f", "--fields"):
     FIELDS = arg

if not ID.isdigit():
  print "The id need to be a numerical taxon id from Dyntaxa. Exiting"
  raise SystemExit(0)

XML = ID + ".xml"
CSV = ID + ".csv"
     
if not os.path.isfile(XML):
  print "XML file does not exist. Exiting."
  raise SystemExit(0)

if os.path.isfile(CSV):
  print "CSV file already exist. Will overwrite it."

print "Starting to convert " + XML + " to " + CSV + " using fields " + FIELDS
field_list = FIELDS.split(', ')

global count
count = 0

def ns_tag(tag):
  return str(cElementTree.QName('http://schemas.datacontract.org/2004/07/' +
    'ArtDatabanken.WebService.Data', tag))

def ns_attr(attr):
  return str(cElementTree.QName("http://www.w3.org/2001/XMLSchema-instance", attr))
  
def get_field(elem, field):
  res = elem.findtext(ns_tag(field)) or ""
  return res
  
def show_console_progress(count):
  if count % 100 == 0:
    sys.stdout.write(".")
  if count % 1000 == 0:
    sys.stdout.write(str(count))
  sys.stdout.flush()
  
def geturi(prefix, namespaces):
  for p, uri in reversed(namespaces):
    if p == prefix:
      return uri
  return None # not found  
  
fo = open(CSV, "w")
fo.write("\t".join(field_list) + "\n")

events = ("end", "start-ns", "end-ns")
namespaces = []
for event, elem in cElementTree.iterparse(XML, events):
  if event == "start-ns":
    namespaces.append(elem)
  elif event == "end-ns":
    namespaces.pop()
  elif elem.tag == ns_tag("Children") :
    isLeaf = elem.get(ns_attr("nil"), False)
  elif event == "end" and elem.tag == ns_tag("Taxon"):
    # TODO use elem.attrib
    count += 1
    fields = []
    show_console_progress(count)
    for field in field_list:
      res = get_field(elem, field)
      fields.append(res)
    row = "\t".join(fields) + "\n"
    fo.write(row.encode("utf8"))
    
fo.close()

def iterparent(tree):
  for parent in tree.getiterator(ns_tag("WebTaxonTreeNode")):
    for child in parent:
      yield parent, child

tree = cElementTree.parse(XML)
for parent, child in iterparent(tree):
#  children = child.find(ns_tag("Children"))
#  if children is not None:
#    isLeaf = children.get(ns_attr("nil"), False)
  taxon = child.find(ns_tag("Taxon"))
  if taxon is not None:
    fid = get_field(taxon, "Id")
    print fid

parent_map = dict((c, p) for p in tree.getiterator() for c in p)

print "Namespaces: " + ", ".join(namespaces)
print "Done. Total count of taxa in " + CSV + " is: " + str(count)
