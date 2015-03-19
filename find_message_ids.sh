#!/bin/sh

grep -iR -m 1 ^Message-Id . | perl -pe 'chomp; s/(.*):message-id:\s*(.*)/\2: \1\n/gi'
