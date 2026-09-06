#!/usr/bin/env bash
# logging.sh
# Logging function
# Written by rh 2026-09-05

set -euo pipefail

log() {
  local log_level=$1
  local message=$2
  local script_name=$(basename "${BASH_SOURCE[1]}")
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "$timestamp [$log_level] [$script_name] $message" | tee -a "$LOGFILE"
}

manifest() {
  local key=$1
  local value=$2
  printf '%s=%s\n' "$key" "$value" >>$MANIFEST_FILE
  export "$key=$value"
}
