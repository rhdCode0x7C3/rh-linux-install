#!/usr/bin/env bash
# install.sh
# Install Void Linux
# Written by rh 2026-09-02

set -euo pipefail

export ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[@]}")" && pwd)"

source "$ROOT_DIR/scripts/logging.sh"

# Destroy previous logfiles and create a new one
rm -f /tmp/rh-linux-install.log.*
export LOGFILE=$(mktemp /tmp/rh-linux-install.log.XXXXXX)
log DEBUG "Created log file at $LOGFILE"

# Destroy previous manifests and create a new one
rm -f /tmp/rh-linux-install.manifest.*
export MANIFEST_FILE=$(mktemp /tmp/rh-linux-install.manifest.XXXXXX)
log DEBUG "Created manifest file at $MANIFEST_FILE"

# Create a tempfile (gets destroyed when the script exits)
export TEMPFILE=$(mktemp /tmp/rh-linux-install.tmp.XXXXXX)
log DEBUG "Created temp file at $TEMPFILE"

# Functions

cleanup() {
  log DEBUG "Cleaning up..."
  "$ROOT_DIR/scripts/cleanup.sh"
}

error_exit() {
  log FATAL "An error occurred."
  cleanup
}

interrupt_exit() {
  log FATAL "Interrupted."
  cleanup
  exit 130
}

run_script() {
  local name=$1
  local script=$2
  local exit_code

  shift 2
  "$script" "$@"
  exit_code=$?

  manifest "${name}_EXIT" "$exit_code"

  return "$exit_code"
}

trap error_exit ERR
trap interrupt_exit INT TERM

run_script SETUP "$ROOT_DIR/scripts/setup.sh"

log INFO "Starting installation"

run_script PARTITIONING "$ROOT_DIR/scripts/partitioning.sh"

run_script CLEANUP "$ROOT_DIR/scripts/cleanup.sh"

log INFO "Installation complete"

exit 0
