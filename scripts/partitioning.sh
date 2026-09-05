#!/usr/bin/env bash
# 001_partitioning.sh
# Create partitions for Linux install
# Written by rh 2026-09-01

set -euo pipefail

lsblk -de 7,11 -o NAME,MODEL,SIZE,TRAN,SERIAL,UUID

echo -e "\nSelect the disk you want to install Void Linux to:\n"

readarray -t disks < <(lsblk -dne 7,11 -o NAME)

select disk in "${disks[@]}"; do
  if [[ -z $disk ]]; then
    echo "Invalid input: Select a number between 1 and ${#disks[@]}"
  else
    DISK_DEVNAME="/dev/$disk"
    DISK_ID=""

    for id in /dev/disk/by-id/*; do
      [[ -e "$id" ]] || continue

      if [[ "$(readlink -f "$id")" == "$DISK_DEVNAME" ]]; then
        DISK_ID="${id##*/}"
        break
      fi
    done

    if [[ -z $DISK_ID ]]; then
      echo "Error: Could not determine persistent ID for $DISK_DEVNAME" >&2
      exit 1
    fi

    echo "Void Linux will be installed to '$DISK_DEVNAME'"
    echo "Disk ID: $DISK_ID"
    break
  fi
done

exit 0
