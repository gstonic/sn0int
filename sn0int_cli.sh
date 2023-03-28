#!/bin/bash

read -p "Enter the domain to scan: " domain
# Define the domain to scan
echo "delete old data"
sn0int delete domains where id=1
sn0int delete domains where id=2
sn0int delete domains where id=3
sn0int delete domains where id=4
sn0int delete domains where id=5
echo "" > report.json
# Define the Sn0int commands to run
echo "Executing sn0int add domain"
sn0int add domain $domain 

echo "Executing sn0int run waybackurls"
sn0int run waybackurls 

echo "Executing sn0int run dns-resolve"
sn0int run dns-resolve 

echo "Executing sn0int run url-scan"
sn0int run url-scan 

echo "Executing sn0int export"
sn0int export --format json > report.json

# read in the json file and extract the desired data
data=$(cat report.json | jq -r '.ports[] | [.id, .ip_addr, .port, .status, .banner] | @tsv')

# print the header row of the table
echo -e "ID\tIP_ADDR\t\tPORT\tSTATUS\t\tBANNER"

# loop through the extracted data and print each row of the table
echo "$data" | while read line; do
    echo -e "${line//\//\\t}"
done> results.txt

sn0int run shodan-certs
sn0int select ports > shodan.txt

echo "All commands have finished"
