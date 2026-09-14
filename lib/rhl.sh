#!/usr/bin/env bash
# lib/rhl.sh
# Log messages
# Written by rh 2026-09-07
#
# Environment variables:
#
# RHL_LOGFILE
# /path/to/log/file
#
# RHL_LOGLEVEL
# [DEBUG|INFO|WARN|ERROR|FATAL]
#
# Note: FATAL messages are log-only and do not affect the control flow of the program.
#
# Usage:
# $ export RHL_LOGFILE=/var/log/mylog.file
# $ export RHL_LOGLEVEL=WARN
# $ rhl_init
# $ rhl_error "Oh no..."

_rhl_output=/dev/stderr
_rhl_threshold=1

_rhl_timestamp() {
  # date "+%Y-%m-%d %H:%M:%S"
  printf '%(%Y-%M-%d %H:%m:%S)T\n' -1
}

declare -A _rhl_levels=(
  [DEBUG]=0
  [INFO]=1
  [WARN]=2
  [ERROR]=3
  [FATAL]=4
)

_rhl_header() {
  local level=$1
  local ts
  ts=$(_rhl_timestamp)
  printf "%s\n" "---"
  printf "Caller:     %s\n" "$0"
  printf "Timestamp:  %s\n" "$ts"
  printf "Log level:  %s\n" "$level"
  printf "%s\n" "---"
}

_rhl_log() {
  local level=$1

  local p="${_rhl_levels[$level]}"
  [[ -n "$p" ]] || return 1

  shift

  if ((p >= _rhl_threshold)); then
    local message
    message="$*"

    local timestamp
    timestamp="$(_rhl_timestamp)"

    printf '[%s][%s] %s\n' "$timestamp" "$level" "$message" >>"$_rhl_output"
  fi
}

# Public API
rhl_debug() { _rhl_log DEBUG "$@"; }
rhl_info() { _rhl_log INFO "$@"; }
rhl_warn() { _rhl_log WARN "$@"; }
rhl_error() { _rhl_log ERROR "$@"; }
rhl_fatal() { _rhl_log FATAL "$@"; }

rhl_init() {
  local logfile="${RHL_LOGFILE:-}"
  local level="${RHL_LOGLEVEL:-INFO}" # Default to INFO if not set
  if [[ -n "$logfile" ]]; then
    _rhl_output=$logfile
  else
    echo "\$RHL_LOGFILE is not set. Logging to stderr." >&2
  fi

  _rhl_threshold="${_rhl_levels[$level]}"

  if [[ -z "$_rhl_threshold" ]]; then
    printf 'Invalid RHL_LOGLEVEL: %s\n' "$level" >&2
    return 1
  else
    _rhl_header "$level" >>"$_rhl_output"
  fi
}
