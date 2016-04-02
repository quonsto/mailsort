#!/bin/sh

find ../byid -name files | while read -t 1 file; do
  #echo $file | perl -pe 's/\n/\0/g' | xargs -0 -n 1 cat | 
  cat $file |
    ( dispatch_message.pl && rm $file ) || ( echo $file; exit 1 ) || exit 1
done
