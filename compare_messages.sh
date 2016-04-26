#!/usr/bin/env bash

EXTRA_IGNORE='^x-originalarrivaltime: '
EXTRA_IGNORE2='^x-originalarrivaltime: '
EXTRA_IGNORE3='^x-originalarrivaltime: '
EXTRA_IGNORE4='^x-originalarrivaltime: '
EXTRA_IGNORE5='^x-originalarrivaltime: '
EXTRA_IGNORE6='^x-originalarrivaltime: '
if [ x"$3" == "xspam_mode" ]; then
    EXTRA_IGNORE='^Content-Type: text/plain;charset='
    EXTRA_IGNORE2='^	charset="'
    EXTRA_IGNORE3='^Date: '
    EXTRA_IGNORE4='^From: '
    EXTRA_IGNORE5='^Return-Path: '
    EXTRA_IGNORE6='^To: '
fi

diff -uw \
    -I '^X-OlkEid: ' \
    -I '^Bcc: ' \
    -I '^x-originalarrivaltime: ' \
    -I '^x-bayesian-words: ' \
    -I '^x-bayesian-result: ' \
    -I '^x-uid: ' \
    -I '^Keywords: ' \
    -I '^X-Mailer: ' \
    -I '^x-tff-cgpsa-filter: ' \
    -I '^x-tff-cgpsa-version: ' \
    -I '^x-spampal: ' \
    -I '^x-spam-flag: ' \
    -I '^x-mimeole: ' \
    -I '^x-loop: ' \
    -I '^Return-Path: ' \
    -I '^.*----=_NextPart_' \
    -I '^x-felis-deliver-id: ' \
    -I '^x-felis-queue-id: ' \
    -I '^x-sender: ' \
    -I '^[Xx]-[Ss]pam-[Ss]tatus: ' \
    -I '^[Xx]-[Ss]pam-[Rr]eport: ' \
    -I '^x-recipient: ' \
    -I '^Disposition-Notification-To: ' \
    -I '^x-spamcheck: ' \
    -I '^[Xx]-[Ss]pam-[Ll]evel: ' \
    -I '^List-Help: ' \
    -I '^List-Subscribe: ' \
    -I '^List-Unsubscribe: ' \
    -I '^x-original-to: ' \
    -I '^x-envelope-to: ' \
    -I '^Thread-Index: ' \
    -I '^x-rav-antivirus: ' \
    -I '^x-antivirus: ' \
    -I '^x-antivirus-status: ' \
    -I '^x-antivirus-wms: ' \
    -I '^x-antivirus-wms-mail-from: ' \
    -I '^x-antivirus-wms-moved-x-spam-status: ' \
    -I '^x-antivirus-wms-moved-x-spam-level: ' \
    -I '^x-antivirus-wms-moved-x-spam-report: ' \
    -I '^x-antivirus-wms-moved-x-spam-flag: ' \
    -I '^[Xx]-[Vv]irus-[Ss]canned: ' \
    -I '^x-virus-status: ' \
    -I '^x-cron-env: ' \
    -I '^x-server: ' \
    -I '^x-authentication-warning: ' \
    -I '^x-scanned-by: ' \
    -I '^x-mime-autoconverted: ' \
    -I '^x-mimetrack: ' \
    -I '^x-sieve: ' \
    -I '^x-sku-spf-passed: ' \
    -I '^x-mdaemon-deliver-to: ' \
    -I '^x-wlist-pattern: ' \
    -I '^Content-Language: ' \
    -I '^x-spampal-timeout: ' \
    -I '^x-dspam-confidence: ' \
    -I '^x-dspam-signature: ' \
    -I '^x-dspam-probability: ' \
    -I '^x-dspam-processed: ' \
    -I '^x-dspam-result: ' \
    -I '^x-spamtest-version: ' \
    -I '^x-spamtest-info: ' \
    -I '^x-spamtest-status: ' \
    -I '^[Xx]-[Ss]pam-[Cc]hecker-[Vv]ersion: ' \
    -I '^x-source-ip: ' \
    -I '^x-originating-ip: ' \
    -I '^x-proxy-ip: ' \
    -I '^Importance: ' \
    -I '^X-Priority: ' \
    -I '^X-MSMail-Priority: ' \
    -I '^X-MS-TNEF-Correlator: ' \
    -I '^x-ms-has-attach: ' \
    -I '^eJ8+I...AQaQCAAEAAAAAAABAAEAAQeQBgAIAAAA4wQAAAAAAADnAAEIgAcA..AAAElQTS5.....' \
    -I "$EXTRA_IGNORE" \
    -I "$EXTRA_IGNORE2" \
    -I "$EXTRA_IGNORE3" \
    -I "$EXTRA_IGNORE4" \
    -I "$EXTRA_IGNORE5" \
    -I "$EXTRA_IGNORE6" \
  <(unify_message.sh "$1") <(unify_message.sh "$2")
