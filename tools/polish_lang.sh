#!/usr/bin/env bash
# One language, several cases, in turn — the polish equivalent of translate_lang.sh.
set -u
LANG_CODE="$1"; shift
DART="C:/Users/selim/flutter/bin/dart"
for c in "$@"; do
  echo "######## polish $LANG_CODE $c ########"
  for pass in 1 2 3; do
    "$DART" run tools/polish_pack.dart "$LANG_CODE" "$c" --concurrency "${CONC:-1}" && break
    echo "--- $LANG_CODE $c pass $pass incomplete, retrying ---"
    sleep 15
  done
done
echo "POLISH $LANG_CODE DONE"
