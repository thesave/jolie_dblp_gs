#! /bin/bash
for (( i = 1990; i <= 2018; i++ )); do
  wget "https://dblp.uni-trier.de/search/publ/api?q=toc%3Adb%2Fconf%2Fconcur%2Fconcur${i}.bht%3A&h=1000&format=bib1&rd=1a" -O "concur${i}.bib"
done
