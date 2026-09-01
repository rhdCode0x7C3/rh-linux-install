#!/usr/bin/env bash
# 001_partitioning.sh
# Create partitions for Linux install
# Written by rh 2026-09-01

set -euo pipefail

echo "Select the device you want to install Void Linux to:"

readarray drives -t < <(lsblk -d | tail -n +2 | awk '{print $1}')

for drive in drives; do
  echo "1 $drive"
done

read -p "/dev/" INSTALL_DRIVE

exit 0
