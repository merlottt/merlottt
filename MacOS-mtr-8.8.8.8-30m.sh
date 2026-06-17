#!/usr/bin/env bash
set -euo pipefail

TARGET="8.8.8.8"
DURATION_SECONDS=1800
INTERVAL_SECONDS=1
COUNT=$((DURATION_SECONDS / INTERVAL_SECONDS))

LOG_DIR="${LOG_DIR:-$PWD}"
TIMESTAMP="$(date '+%Y-%m-%d_%H-%M-%S')"
LOG_FILE="$LOG_DIR/mtr_${TARGET}_${TIMESTAMP}.log"

export PATH="/opt/homebrew/sbin:/opt/homebrew/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

if ! command -v mtr >/dev/null 2>&1; then
  echo "mtr not found. Install it with: brew install mtr" >&2
  exit 1
fi

MTR_BIN="$(command -v mtr)"
mkdir -p "$LOG_DIR"

{
  echo "mtr target: $TARGET"
  echo "duration: ${DURATION_SECONDS}s"
  echo "interval: ${INTERVAL_SECONDS}s"
  echo "count: $COUNT"
  echo "started: $(date '+%Y-%m-%d %H:%M:%S %Z')"
  echo
} | tee "$LOG_FILE"

echo "Running mtr. This will take about 30 minutes..."
echo "Log file: $LOG_FILE"
echo

sudo "$MTR_BIN" \
  --report \
  --report-wide \
  --show-ips \
  --interval "$INTERVAL_SECONDS" \
  --report-cycles "$COUNT" \
  "$TARGET" | tee -a "$LOG_FILE"

{
  echo
  echo "finished: $(date '+%Y-%m-%d %H:%M:%S %Z')"
} | tee -a "$LOG_FILE"

echo
echo "Done. Log saved to: $LOG_FILE"
