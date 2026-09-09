#!/usr/bin/env bash
# 000_setup.sh
# Written by rh 2026-09-08

run_id_gen() {
  local timestamp
  timestamp="$(date +%s%N)"

  local uuid
  uuid="$(uuidgen)"

  printf '%s-%s' "$timestamp" "$uuid"
}

export RUN_ID=run_id_gen
