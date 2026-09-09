#!/usr/bin/env bash
# lib/rhkv.sh
# Persistent key value store
# Written by rh 2026-09-08
#
# Environment variables:
# RHKV_FILE
# /path/to/file
#
# Usage:

_rhkv_process() {
  # Usage: _rhkv_process f file
  local f="$1"
  shift
  while IFS= read -r line; do
    [[ $line =~ ^[A-Za-z_]+[A-Za-z0-9_]+=[A-Za-z0-9_[:blank:]]+$ ]] || continue
    "$f" "$line"
  done <"$1"
}

_rhkv_export() {
  # Takes a key=value string and exports to an enrionment variable
  local d='='
  local s="$1"
  local key="${s%%${d}*}"
  local val="${s#*${d}}"
  export "$key"="$val"
}

# Public API
# rhkv_get() {}
# rhkv_del() {}
# rhkv_put() {}

rhkv_lst() {
  # Usage: rhkv_lst myfile.txt
  # Prints all key value pairs

  local file
  file=$1

  local f="echo"

  _rhkv_process "$f" "$file"

}

rhkv_read() {
  # Usage: rhkv_read myfile.txt
  # Exports all key value pairs to the environment

  local file
  file=$1

  local f="_rhkv_export"

  _rhkv_process "$f" "$file"

}
