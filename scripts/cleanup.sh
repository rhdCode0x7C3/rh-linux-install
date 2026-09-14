#!/usr/bin/env bash
# cleanup.sh
# Written by rh 2026-09-02

rhl_info "Cleaning up..."

# Commenr
prune_runfiles() {
  local n_runs_to_retain=5

  local -a runs
  mapfile -t runs < <(
    find "$FILES_DIR" \
      -mindepth 1 \
      -maxdepth 1 \
      -type d \
      -name 'run_*' \
      -printf '%f\n' |
      sort -r
  )

  if ((${#runs[@]} <= n_runs_to_retain)); then
    rhl_info "Nothing to prune (${#runs[@]} runs)"
    return 0
  fi

  local run
  for run in "${runs[@]:n_runs_to_retain}"; do
    rhl_info "Removing $run"
    rm -rf -- "${FILES_DIR:?}/$run"
  done
}

rhl_info "Pruning runfiles"
prune_runfiles
