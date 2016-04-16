#!/usr/bin/env bash

diff -uw \
    -I '^X-OlkEid: ' \
    -I '^x-originalarrivaltime: ' \
    -I '^x-bayesian-words: ' \
    -I '^x-bayesian-result: ' \
    -I '^Keywords: ' \
    -I '^x-spampal: ' \
    -I '^x-mimeole: ' \
    -I '^Return-Path: ' \
    -I '^.*----=_NextPart_' \
    -I '^x-felis-deliver-id: ' \
    -I '^x-sender: ' \
    -I '^x-spam-status: ' \
    -I '^x-recipient: ' \
    -I '^x-spamcheck: ' \
    -I '^x-spam-level: ' \
    -I '^List-Help: ' \
    -I '^List-Subscribe: ' \
    -I '^List-Unsubscribe: ' \
    -I '^x-original-to: ' \
    -I '^Thread-Index: ' \
    -I '^x-antivirus-wms: ' \
    -I '^x-antivirus-wms-mail-from: ' \
    -I '^[Xx]-[Vv]irus-[Ss]canned: ' \
    -I '^x-virus-status: ' \
    -I '^x-authentication-warning: ' \
    -I '^x-scanned-by: ' \
    -I '^X-MS-TNEF-Correlator: ' \
    -I '^eJ8+I...AQaQCAAEAAAAAAABAAEAAQeQBgAIAAAA4wQAAAAAAADnAAEIgAcA..AAAElQTS5.....' \
  <(unify_message.sh "$1") <(unify_message.sh "$2")
