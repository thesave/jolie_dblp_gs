#! /bin/bash
for (( i = 1990; i <= 2019; i++ )); do
  echo "- - - - YEAR $i - - - - "
  cat "json_archive_cit/concur$i.json" \
  | jq '.result.hits.hit[].info' \
  | jq -s -c 'sort_by(.citations | -tonumber)' \
  | jq '.[0:3]' | jq '.[] | "Title : " + .title, "Citations: " + .citations, "Authors: " + if ( .authors.author | type == "string" ) then .authors.author else .authors[] | join(", ") end' 
done