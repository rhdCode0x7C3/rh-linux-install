#!/usr/bin/env bash
# 001_partitioning.sh
# Create partitions for Linux install
# Written by rh 2026-09-01

set -euo pipefail

echo "Select the device you want to install Void Linux to:"

readarray drives -t < <(lsblk -dno NAME)

for i in "${!drives[@]}"; do
  drive="${drives[$i]%$'\n'}"
  echo "$i) $drive"
done

exit 0
