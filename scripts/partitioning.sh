#!/usr/bin/env bash
# 001_partitioning.sh
# Create partitions for Linux install
# Written by rh 2026-09-01

set -euo pipefail

lsblk -de 7,11 -o NAME,MODEL,SIZE,UUID

echo -e "\nSelect the disk you want to install Void Linux to:\n"

readarray -t drives < <(lsblk -dne 7,11 -o NAME)

select drive in "${drives[@]}"; do
  if [[ -z $drive ]]; then
    echo "Invalid input: Select a number between 1 and ${#drives[@]}"
  else
    DISK_DEVNAME="/dev/$drive"
    # DISK_UUID=$(blkid "$DISK_DEVNAME")
    echo "Void Linux will be installed to '$DISK_DEVNAME'"
    # echo "'$DISK_DEVNAME' is '$DISK_UUID'"
    break
  fi
done

exit 0
