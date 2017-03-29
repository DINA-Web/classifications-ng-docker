#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Script for fetching dyntaxa data from SLU

"""

import sys, getopt
import os.path
from suds.client import Client
from suds import WebFault
from ConfigParser import SafeConfigParser

__author__ = "Markus Skyttner"
__license__ = "AGPLv3"

CFG = "dyntaxa-credentials.cfg"
IDS="0"
#IDS = "3000188"
#IDS ="1005908"

manual = "dyntaxa.py --cfg <default:" + CFG + "> --ids '<default:" + IDS + ">'"

try:
  opts, args = getopt.getopt(sys.argv[1:], "hci", ["cfg=", "ids="])
except getopt.GetoptError:
  print(manual)
  sys.exit(2)

for opt, arg in opts:
  if opt in ("-h", "--help", "-?", "--?"):
    print(manual)
    sys.exit()
  elif opt in ("-c", "--cfg"):
     CFG = arg
  elif opt in ("-i", "--ids"):
     IDS = arg
     
if not os.path.isfile(CFG):
  print("Config file does not exist. Exiting.")
  raise SystemExit(0)
print('Using cfg: ', CFG)

id_list = IDS.split(' ')
for i in id_list:
  if not i.isdigit():
    print("The ids need to be numerical taxon ids. Exiting")
    raise SystemExit(0)

XML_OUT = "_".join(id_list) + ".xml"
if os.path.isfile(XML_OUT):
  print("Results file " + XML_OUT + " already exists, already downloaded? Aborting ..")
  exit(0)

SVC_URL = 'https://taxon.artdatabankensoa.se/TaxonService.svc?wsdl'
client = Client(SVC_URL, timeout=600)
#print(client)
#exit(0)

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

ids = client.factory.create('ns3:ArrayOfint')

for id in id_list:
  ids.int.append(id)
#ids.int.append('6001047')

ttss = client.factory.create('ns0:TaxonTreeSearchScope')

search_criteria = client.factory.create('ns1:WebTaxonTreeSearchCriteria')

search_criteria['TaxonIds'] = ids
search_criteria['IsMainRelationRequired'] = True
search_criteria['IsValidRequired'] = True
search_criteria['Scope']=ttss.AllChildTaxa


print "Retrieving ids: " + IDS
try:
  result = client.service.GetTaxonTreesBySearchCriteria(wci, search_criteria)
  #print result
except WebFault, e:
  print(e)
  raise SystemExit(0)
  
print("Writing results to " + XML_OUT)
fo = open(XML_OUT, "wb")
fo.write(bytes(client.last_received()))
fo.close()

client.service.Logout(wci)
print ("Logged out from " + SVC_URL + "... Bye bye.")

