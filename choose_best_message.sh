#!/usr/bin/env bash

grep -q "Subject: \*\*SPAM\*\*" <(decode_message.pl "$1") && echo "$2" && exit
echo "$1"
