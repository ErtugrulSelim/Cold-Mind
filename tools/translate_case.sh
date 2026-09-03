#!/usr/bin/env bash
# Runs the pack translator for every shipping language of one case, in turn.
# Sequential on purpose: the endpoint throttles hard, so two languages at once
# only makes both of them retry.
set -u
CASE="$1"; shift
LANGS="${*:-es it fr br pl ru tr}"
DART="C:/Users/selim/flutter/bin/dart"
for lang in $LANGS; do
  echo "=== $lang $CASE ==="
  for pass in 1 2 3; do
    "$DART" run tools/translate_pack.dart "$lang" "$CASE" "${OPTS:-}" && break
    echo "--- $lang pass $pass incomplete, retrying ---"
    sleep 20
  done
done
