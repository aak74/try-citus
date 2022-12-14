#!/bin/bash

psql -U try_citus -h 127.0.0.1 -d try_citus -c "\copy companies from 'companies.csv' with csv"
psql -U try_citus -h 127.0.0.1 -d try_citus -c "\copy campaigns from 'campaigns.csv' with csv"
psql -U try_citus -h 127.0.0.1 -d try_citus -c "\copy ads from 'ads.csv' with csv"




