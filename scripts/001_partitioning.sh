#!/usr/bin/env bash
# 001_partitioning.sh
# Create partitions for Linux install
# Written by rh 2026-09-01

set -euo pipefail

lsblk

echo "Type the name of the device you want to install Void Linux to:"

read -p "/dev/" INSTALL_DRIVE
export INSTALL_DRIVE

exit 0
