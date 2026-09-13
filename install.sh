#!/usr/bin/env bash
# install.sh
# Install Void Linux
# Written by rh 2026-09-02

set -euo pipefail

export SCRIPT_DIR
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"

source "$SCRIPT_DIR/scripts/setup.sh"

# run_script PARTITIONING "$ROOT_DIR/scripts/partitioning.sh"
#
# run_script CLEANUP "$ROOT_DIR/scripts/cleanup.sh"

cleanup
rhl_info "Installation complete"

exit 0
