#!/usr/bin/env bash
# 001_partitioning.sh
# Create partitions for Linux install
# Written by rh 2026-09-01

set -euo pipefail
source "$ROOT_DIR/scripts/logging.sh"

# Select a disk to install to
select_disk() {
  echo -e "\n"
  lsblk -de 7,11 -o NAME,MODEL,SIZE,TRAN,SERIAL,UUID

  echo -e "\nSelect the disk you want to install Void Linux to:\n"

  readarray -t disks < <(lsblk -dne 7,11 -o NAME)
  select disk in "${disks[@]}"; do
    if [[ -z $disk ]]; then
      echo "Invalid input: Select a number between 1 and ${#disks[@]}"
    else
      manifest DISK_DEVNAME "/dev/$disk"
      DISK_ID=""

      for id in /dev/disk/by-id/*; do
        [[ -e "$id" ]] || continue

        if [[ "$(readlink -f "$id")" == "$DISK_DEVNAME" ]]; then
          manifest DISK_ID "${id##*/}"
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
}

# Create disk partitions
make_partitions() {
  read -r -p "Are you sure? All data on $DISK_DEVNAME will be destroyed. [YES/no]" CONFIRM
  if [[ $CONFIRM == "YES" ]]; then
    sfdisk "$DISK_DEVNAME" <"$ROOT_DIR/config/sfdisk"
  fi

  udevadm settle

  partitions=()
  for id in /dev/disk/by-id/"$DISK_ID"-part*; do
    [[ -e "$id" ]] || continue
    partitions+=("${id##*/}")
  done

  if [[ "${#partitions[@]}" != 3 ]]; then
    log "ERROR" "Incorrect number of partitions on install disk: ${#partitions[@]}"
    exit 1
  else
    manifest ESP_PARTID "${partitions[0]}"
    manifest BOOT_PARTID "${partitions[1]}"
    manifest SYSTEM_PARTID "${partitions[2]}"
  fi
  log INFO "Disk partitions created successfully"
}

CONFIRM="no"

while [[ "$CONFIRM" != "YES" ]]; do
  select_disk
  make_partitions
done
exit 0
