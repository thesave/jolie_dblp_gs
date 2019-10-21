#! /bin/bash
for (( i = 1990; i <= 2019; i++ )); do
  wget "https://dblp1.uni-trier.de/search/publ/api?q=toc%3Adb/conf/concur/concur${i}.bht%3A&h=1000&format=json" -O "concur${i}.json"
done
