#!/usr/bin/env bash
# Runs translate_case.sh for several cases back to back, waiting first for a
# marker file to report the previous run finished. Sequential on purpose: the
# endpoint throttles per key, so two runs at once only make each other retry.
set -u
WAIT_FOR="${WAIT_FOR:-}"
if [ -n "$WAIT_FOR" ]; then
  echo "waiting for $WAIT_FOR to report EXIT..."
  while ! grep -q "^EXIT " "$WAIT_FOR" 2>/dev/null; do sleep 30; done
  echo "previous run finished."
fi
for c in "$@"; do
  echo "######## $c ########"
  bash tools/translate_case.sh "$c"
done
echo "QUEUE DONE"
