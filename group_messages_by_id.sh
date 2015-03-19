#!/bin/sh

find . -type f | while read -t 1 file; do 
  MESSAGE_ID=`echo $file | perl -pe 's/\n/\0/g' | xargs -0 -n 1 grep -m 1 '^Message-ID:'` || continue
  MESSAGE_ID=`echo $MESSAGE_ID | perl -pe 's/^Message-ID:\s*//; s/^<//; s/>$//'`
  HASH=`md5 -qs "$MESSAGE_ID"`
  DIR=`echo $HASH | perl -pe 's/^(..)(..)/\1\/\2\//'`
  mkdir -p ../byid/"$DIR"
  echo "$MESSAGE_ID" >> ../byid/"$DIR"/messageid
  echo "$file" >> ../byid/"$DIR"/files
done
