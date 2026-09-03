#!/usr/bin/env bash
# One language, several cases, in turn. Three of these run side by side; more
# than that and the endpoint starts answering 429.
set -u
LANG_CODE="$1"; shift
DART="C:/Users/selim/flutter/bin/dart"
for c in "$@"; do
  echo "######## $LANG_CODE $c ########"
  for pass in 1 2 3; do
    "$DART" run tools/translate_pack.dart "$LANG_CODE" "$c" --concurrency "${CONC:-2}" && break
    echo "--- $LANG_CODE $c pass $pass incomplete, retrying ---"
    sleep 15
  done
done
echo "LANG $LANG_CODE DONE"
