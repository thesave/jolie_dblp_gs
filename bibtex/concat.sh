#!/usr/bin/env bash

from=1990
to=2019
root="archive"
prefix="concur"
ext=".bib"
in_serie=1
years=""
tmp_file="bib.tmp"
for (( i = "$from"; i <= "$to"; i++ )); do
  years="${years}-${i}"
  cat ${root}/${prefix}${i}${ext} >> $tmp_file
  echo $i
  ((in_serie+=1))
  if [[ $in_serie == 6 || $i == "$to" ]]; then
    ((series+=1))
    in_serie=1
    mv $tmp_file ${prefix}${years}${ext}
    years=""
  fi
done