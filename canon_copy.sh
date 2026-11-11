#!/bin/bash

# Run as:
# > ./canon_copy.sh /Volumes/EOS_DIGITAL/ /Volumes/MyPassport-NEW-ARCHIVE/CANADA_photos/2024/

set -e
set -C

OIFS="$IFS"
IFS=$'\n'

SOURCE="${1%*/}"
TARGET="${2%*/}"
CANONS=${SOURCE}/DCIM

for dir in $CANONS/*CANON/
do 
  DIR="${dir%*/}"
  for FILE in $DIR/*; do
    DATE=$(stat -f %Sm -t "%Y-%m-%d" $FILE)
    mkdir -p $TARGET/$DATE
    echo "$FILE"
    cp -a -f $FILE $TARGET/$DATE
  done
done  


IFS="$OIFS"


