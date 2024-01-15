#!/bin/bash
d1=$(date '+%d/%m/%Y')
d2=$(date '+%d/%m/%Y' -d "1 day")
d3=$(date '+%d/%m/%Y' -d "2 day")
d4=$(date '+%d/%m/%Y' -d "3 day")

cat apache_logs | sed -e "s|17/May/2015|$d1|g" \
                      -e "s|18/May/2015|$d2|g" \
                      -e "s|19/May/2015|$d3|g" \
                      -e "s|20/May/2015|$d4|g" > log2
