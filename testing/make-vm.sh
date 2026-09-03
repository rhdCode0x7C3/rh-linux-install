#!/usr/bin/env bash
# make-vm.sh
# Create a QEMU virtual machine to test the install
# Written by rh 2026-09-02

set -euo pipefail

# Help
help() {
  echo
  echo "Create a virtual machine for testing"
  echo "USAGE: make-vm [-h|name]"
  echo "-h   Print this Help"
  echo
}

if [ $# -eq 0 ]; then
  echo "Bad usage: no arguments supplied"
  help
  exit 1
fi

while getopts ":h" opt; do
  case $opt in
  h) # display Help
    help
    exit
    ;;
  esac
done

# Create the VM disk image in a directory specified by the user
VM_DIR=vm_"$1"
mkdir "$VM_DIR"
qemu-img create -f qcow2 "$VM_DIR"/"$1".img 128G

RUN_FILE="$VM_DIR"/run.sh

# Create the run command in the VM directory
cat >"$RUN_FILE" <<EOF
qemu-system-x86_64 \
  -accel tcg,thread=multi,tb-size=1536 \
  -machine q35 \
  -m 4G -smp 4 \
  -cpu qemu64 \
  -drive if=pflash,format=raw,readonly=on,file=/opt/homebrew/share/qemu/edk2-x86_64-code.fd \
  -hda ~/VM/vmImages/rhsv/rhsv-test/disk.img
EOF

chmod +x "$RUN_FILE"
