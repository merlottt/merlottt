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

setup_brew_path() {
  export PATH="/opt/homebrew/sbin:/opt/homebrew/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

  if command -v brew >/dev/null 2>&1; then
    eval "$(brew shellenv)"
  elif [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

setup_brew_path

if ! command -v brew >/dev/null 2>&1; then
  if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "Homebrew installation is supported only on macOS." >&2
    exit 1
  fi

  echo "Homebrew not found. Installing Homebrew..."
  echo "The installer may ask for your macOS password."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  setup_brew_path
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew installation finished, but brew is still not available in PATH." >&2
  echo "Open a new terminal window and run this script again." >&2
  exit 1
fi

if ! command -v mtr >/dev/null 2>&1; then
  echo "mtr not found. Installing mtr with Homebrew..."
  brew install mtr
  setup_brew_path
fi

if ! command -v mtr >/dev/null 2>&1; then
  echo "mtr installation finished, but mtr is still not available in PATH." >&2
  echo "Try opening a new terminal window and running this script again." >&2
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
