#!/bin/bash

sort -m *.csv > all.csv
#echo "distance,spectrumID,i" > hw4best100.csv
#uniq all.csv > cleaned.csv
cat all.csv | sort -t , -k1 -n | head -100 > hw4best100.csv
