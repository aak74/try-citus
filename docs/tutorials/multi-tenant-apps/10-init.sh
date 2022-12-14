#!/bin/bash

set -e

curl https://examples.citusdata.com/tutorial/companies.csv > companies.csv
curl https://examples.citusdata.com/tutorial/campaigns.csv > campaigns.csv
curl https://examples.citusdata.com/tutorial/ads.csv > ads.csv

psql -U citus_user -h 127.0.0.1 -d postgres -c "CREATE DATABASE try_citus;"
