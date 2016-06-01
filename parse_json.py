# Using python to parse json file because it is already installed on servers
import json
import sys
from pprint import pprint

jdata = open(sys.argv[1])

data = json.load(jdata)

keylist = data.keys()
keylist.sort()

for key in keylist:
	print data[key]

jdata.close()
sys.exit()
