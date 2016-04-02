#!/usr/bin/env bash

diff -uw \
    -I '^X-OlkEid:' \
    -I '^x-originalarrivaltime:' \
    -I '^x-bayesian-words:' \
    -I '^x-bayesian-result:' \
    -I '^Keywords:' \
    -I '^x-spampal:' \
    -I '^x-mimeole:' \
    -I '^Return-Path:' \
    -I '^.*----=_NextPart_' \
    -I '^x-felis-deliver-id:' \
  <(unify_message.sh "$1") <(unify_message.sh "$2")
