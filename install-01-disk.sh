#!/usr/bin/env bash
# install.sh
# Install Void Linux
# Written by rh 2026-09-02

set -euo pipefail

cleanup() {
  ./scripts/cleanup.sh
}

error_exit() {
  echo "An error occurred." >&2
  cleanup
}

interrupt_exit() {
  echo "Interrupted." >&2
  cleanup
  exit 130
}

trap error_exit ERR
trap interrupt_exit INT TERM

./scripts/setup.sh
./scripts/partitioning.sh

./scripts/cleanup.sh
