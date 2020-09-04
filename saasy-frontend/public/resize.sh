#!/bin/bash

for file in "$@"; do
 # baseimg=${file%.*}

  baseimg=$(echo "$file" | perl -pe 's/\..*$//;s{^.*/}{}')
  suffix=$(echo "$file" | perl -pe 's/^.*\.//')

  for res in 150 480 720 1440; do
#  for res in 480 720 1440; do
    new="$baseimg-$res.$suffix"
    echo "$new"
    convert "$file" -resize $res "$new"
  done
done
