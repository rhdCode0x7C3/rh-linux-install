#!/usr/bin/env bash
# make-vm.sh
# Create a QEMU virtual machine to test the install
# Written by rh 2026-09-02

set -euo pipefail

qemu-system-x86_64 \
  -accel tcg,thread=multi,tb-size=1536 \
  -machine q35 \
  -m 4G -smp 4 \
  -cpu qemu64 \
  -drive if=pflash,format=raw,readonly=on,file=/opt/homebrew/share/qemu/edk2-x86_64-code.fd \
  -hda ~/VM/vmImages/rhsv/rhsv-test/disk.img
