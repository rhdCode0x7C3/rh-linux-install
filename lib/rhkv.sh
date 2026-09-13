#!/usr/bin/env bash
# lib/rhkv.sh
# Persistent key value store
# Written by rh 2026-09-08
#
# Usage:
# Keys must be valid bash variable names
# Values are arbitrary single line strings
# API:
# rhkv_get KEY FILE
# rhkv_del KEY FILE
# rhkv_put KEY VALUE FILE (overwrites existing values)
# rhkv_lst FILE

# Regex patterns
_rhkv_keyp='[_[:alpha:]][_[:alpha:][:digit:]]*'

# Errors
_rhkv_err_nf() {
  local s="$1"
  printf "NOT FOUND: %s\n" "$s" >&2
  return 1
}

_rhkv_err_iv() {
  local s="$1"
  printf "INVALID: %s\n" "$s" >&2
  return 1
}

# Private utility functions
_rhkv_is_key() {
  local s="$1"
  [[ "$s" =~ ^${_rhkv_keyp}$ ]]
}

_rhkv_is_kv() {
  local s="$1"
  [[ "$s" =~ ^${_rhkv_keyp}=.*$ ]]
}

_rhkv_val_of_kv() {
  # Takes a key=value string and returns the value
  local s="$1"
  if _rhkv_is_kv "$s"; then
    printf '%s\n' "${s#*=}"
    return 0
  else
    _rhkv_err_iv "$s"
  fi
}

# Public API
rhkv_get() {
  # Usage: rhkv_get "ESP_PARTID" myfile.txt
  # Takes a key and returns the associated value
  local key="$1" file="$2" line

  _rhkv_is_key "$key" || {
    _rhkv_err_iv "$key"
    return 1
  }

  if line="$(grep -m 1 "^${key}=" "$file")"; then
    _rhkv_val_of_kv "$line"
  else
    _rhkv_err_nf "$key"
  fi
}
rhkv_del() {
  # Usage: rhkv_del "ROOT_PARTID" myfile.txt
  # Takes a key and deletes the key=value pair from the file
  local key="$1" file="$2" line_n

  _rhkv_is_key "$key" || {
    _rhkv_err_iv "$key"
    return 1
  }

  if line_n="$(grep -nm 1 "^${key}=" "$file")"; then
    line_n="${line_n%%:*}"
    sed -i "${line_n}d" "$file"
    return 0
  fi
  _rhkv_err_nf "$key"
  return 1
}

rhkv_put() {
  # Usage: rhkv_put HOSTNAME "my server" myfile.txt
  # Note: existing keys will be overwritten
  local key="$1" val="$2" file="$3"
  # found=0: key has not been read
  # found=1: key has been read
  local tmp found=0 line

  # Check the key is valid
  _rhkv_is_key "$key" || {
    _rhkv_err_iv "$key"
    return 1
  }

  # Check the file exists
  # If not, create it
  [[ -f "$file" ]] || touch "$file"

  # Create a temp file
  # Return 1 if this fails
  tmp=$(mktemp "${file}.XXXXXX") || return 1

  # Read lines from stdin
  while IFS= read -r line || [[ -n $line ]]; do
    # If the key in this line matches the supplied key
    if [[ $line == "$key="* ]]; then
      # And if the key has not been read
      if ((!found)); then
        # Print "key=val" to stdout
        printf '%s=%s\n' "$key" "$val"
        found=1
      fi
    else
      # Copy the line to stdout
      printf '%s\n' "$line"
    fi
    # $file goes to this block's stdin
    # stdout goes to $tmp
  done <"$file" >"$tmp"

  # If the key has not been read
  if ((!found)); then
    # Append "key=val" to $tmp
    printf '%s=%s\n' "$key" "$val" >>"$tmp"
  fi

  mv -- "$tmp" "$file" || {
    rm -f -- "$tmp"
    return 1
  }
}

rhkv_lst() {
  # Usage: rhkv_lst myfile.txt
  # Prints all key value pairs

  local file="$1"

  while IFS= read -r line || [[ -n $line ]]; do
    _rhkv_is_kv "$line" || continue
    printf "%s\n" "$line"
  done <"$file"

}
