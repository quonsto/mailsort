#!/bin/sh

decode_message.pl "$1" | perl -pe 's/^Subject: \*\*SPAM\*\*/Subject: /g'
