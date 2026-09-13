#!/usr/bin/env bash
# 000_setup.sh
# Written by rh 2026-09-08

source "$SCRIPT_DIR/lib/rhl.sh"
source "$SCRIPT_DIR/lib/rhkv.sh"
rhl_debug "Libraries loaded"

# Functions
cleanup() {
  source "$SCRIPT_DIR/scripts/cleanup.sh"
}

error_exit() {
  rhl_fatal "An error occurred."
  cleanup
}

interrupt_exit() {
  rhl_fatal "Interrupted."
  cleanup
  exit 130
}

trap error_exit ERR
trap interrupt_exit INT TERM

export FILES_DIR=/tmp/rh-linux-install
mkdir -p $FILES_DIR

run_id_gen() {
  rhl_info "Generating run ID"
  local timestamp
  timestamp="$(date +%Y-%M-%dT%H:%m:%S)"

  local uuid
  uuid="$(uuidgen)"

  printf 'run_%s-%s' "$timestamp" "$uuid"
}

_set_env() {
  rhl_info "Setting environment variables"
  export RUN_ID
  if [[ $# -eq 0 ]]; then
    RUN_ID="$(run_id_gen)"
  else
    RUN_ID="$1"
  fi
  export RUN_DIR=${FILES_DIR}/${RUN_ID} && mkdir -p "$RUN_DIR"

  export RHL_LOGFILE=$RUN_DIR/log && touch "$RHL_LOGFILE"
  rhl_init
  export RHKV_MANIFEST=$RUN_DIR/manifest && touch "$RHKV_MANIFEST"
  export RHKV_CHECKPOINTS=$RUN_DIR/checkpoints && touch "$RHKV_CHECKPOINTS"
}

_resume_prompt() {
  echo "Select a run:"

  local -a runs
  mapfile -t runs < <(
    find "$FILES_DIR" \
      -mindepth 1 -maxdepth 1 \
      -type d -name 'run_*' |
      sort -r
  )

  if ((${#runs[@]} == 0)); then
    echo "No runs found."
    _set_env
    return
  fi

  # Add fresh-run option at index 0.
  local -a options=("Start a fresh run" "${runs[@]}")

  local selection
  select selection in "${options[@]}"; do
    case "$REPLY" in
    1)
      _set_env
      break
      ;;
    *)
      if [[ -n "$selection" ]]; then
        _set_env "$(basename "$selection")"
        break
      fi
      echo "Invalid selection." >&2
      ;;
    esac
  done
}

run_count="$(find $FILES_DIR -name "run_*" | wc -l)"
if ((run_count > 0)); then
  _resume_prompt
else
  _set_env
fi
