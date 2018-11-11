#! /bin/bash
for (( i = 1990; i <= 2018; i++ )); do
  wget "https://dblp.uni-trier.de/search/publ/api?q=toc%3Adb/conf/concur/concur${i}.bht%3A&format=json" -O "concur${i}.json"
done
