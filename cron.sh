#!/bin/bash

# CRON Job script for automated backup
# Script which can be added in cron tab

files=`find ~/automate -name "*.json"`

for x in $files
do
	python ./parse_json.py $x | ./backup.sh
done
