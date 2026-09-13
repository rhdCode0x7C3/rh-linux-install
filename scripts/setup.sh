#!/usr/bin/env bash
# 000_setup.sh
# Written by rh 2026-09-08

export SCRIPT_DIR
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"

source "$SCRIPT_DIR/lib/rhl.sh"
source "$SCRIPT_DIR/lib/rhkv.sh"

run_id_gen() {
  local timestamp
  timestamp="$(date +%s%N)"

  local uuid
  uuid="$(uuidgen)"

  printf '%s-%s' "$timestamp" "$uuid"
}

export RUN_ID=run_id_gen
export FILES_DIR=/tmp/rh_linux_install && mkdir -p $FILES_DIR

export RHL_LOGFILE=$FILES_DIR/${RUN_ID}/log && touch $RHL_LOGFILE
export RHKV_MANIFEST=$FILES_DIR/${RUN_ID}/manifest && touch $RHKV_MANIFEST
export RHKV_CHECKPOINTS=$FILES_DIR/${RUN_ID}/checkpoints && touch $RHKV_CHECKPOINTS
