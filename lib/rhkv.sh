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
# Keys must be valid bash variable names

# Regex patterns
_rhkv_varp='[_[:alpha:]][_[:alpha:][:digit:]]*'
_rhkv_kvp="^${_rhkv_varp}=.*$"

# Errors
_rhkv_err_nf() {
  s="$1"
  printf "NOT FOUND: %s\n" "$s"
  return 1
}

_rhkv_err_iv() {
  s="$1"
  printf "INVALID: %s\n" "$s"
  return 1
}

_rhkv_process() {
  # Usage: _rhkv_process f file
  local f="$1"
  shift
  while IFS= read -r line; do
    # [[ $line =~ ^[A-Za-z_]+[A-Za-z0-9_]+=[A-Za-z0-9_[:blank:]]+$ ]] || continue
    [[ $line =~ ${_rhkv_kvp} ]] || continue
    "$f" "$line"
  done <"$1"
}

_rhkv_is_kv() {
  local s="$1"
  [[ $s =~ ${_rhkv_kvp} ]]
}

_rhkv_key_of_kv() {
  # Takes a key=value string and returns the key
  local s="$1"
  if _rhkv_is_kv "$s"; then
    echo "${s%%=*}"
    return 0
  else
    _rhkv_err_iv "$s"
  fi
}

_rhkv_val_of_kv() {
  # Takes a key=value string and returns the value
  local s="$1"
  if _rhkv_is_kv "$s"; then
    echo "${s#*=}"
    return 0
  else
    _rhkv_err_iv "$s"
  fi
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
rhkv_get() {
  # Usage: rhkv_get "ESP_PARTID" myfile.txt
  # Takes a key and returns the associated value
  local key="$1"
  local file="$2"
  local line
  if line="$(grep "$key" "$file")"; then
    _rhkv_val_of_kv "$line"
  else
    _rhkv_err_nf "$key"
  fi
}
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
