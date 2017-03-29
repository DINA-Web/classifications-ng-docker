#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Script for fetching dyntaxa data from SLU

"""

import sys, getopt
import os.path
from suds.client import Client
from suds import WebFault
from ConfigParser import SafeConfigParser
import csv

CFG = "dyntaxa-credentials.cfg"
     
if not os.path.isfile(CFG):
  print("Config file does not exist. Exiting.")
  raise SystemExit(0)
print('Using cfg: ', CFG)

SVC_URL = 'https://taxon.artdatabankensoa.se/TaxonService.svc?wsdl'
client = Client(SVC_URL, timeout=600)

online = client.service.Ping()
if not online:
  print('Service not online. Exiting.')
  raise SystemExit(0)
print("Service " + SVC_URL + " is online, logging in...")

# Read user account credentials from config file
config = SafeConfigParser()
config.read(CFG)
SVC_USER = config.get('Dyntaxa', 'user')
SVC_PASS = config.get('Dyntaxa', 'pass')

login = client.service.Login(SVC_USER, SVC_PASS, SVC_USER, False)

wci = client.factory.create('ns1:WebClientInformation')
wci['Locale'] = login.Locale
wci['Token'] = login.Token

try:
  result = client.service.GetTaxonCategories(wci)
  #print result
except WebFault, e:
  print(e)
  raise SystemExit(0)

taxonRanks = result.WebTaxonCategory
taxonRanks= sorted(taxonRanks, key=lambda taxonRank: taxonRank.Id)

with open('taxonRank.csv', "wb") as csv_file:
    writer = csv.writer(csv_file, delimiter=',')
    writer.writerow(["taxonRankID","taxonRank", "DataFields", "IsMainCategory" , "IsTaxonomic", "ParentId", "SortOrder"])
    for taxonRank in taxonRanks:
        writer.writerow([taxonRank.Id, taxonRank.Name, taxonRank.DataFields, taxonRank.IsMainCategory, taxonRank.IsTaxonomic, taxonRank.ParentId, taxonRank.SortOrder])

client.service.Logout(wci)
print ("Logged out from " + SVC_URL + "... Bye bye.")
