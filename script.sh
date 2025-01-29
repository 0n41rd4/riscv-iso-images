#!/bin/bash

# Ensure required environment variables are set
if [ -z "$CD_RISCV64" ] || [ -z "$RISCV64_TEST_IMG" ]; then
  echo "Error: CD_RISCV64 and RISCV64_TEST_IMG must be set."
  exit 1
fi

tmp_dir=$(mktemp -d)
loop_device=$(losetup -fP --show "$RISCV64_TEST_IMG")
mount "${loop_device}p2" "$tmp_dir" || { echo "Failed to mount $RISCV64_TEST_IMG"; exit 1; }
echo "Mounted $RISCV64_TEST_IMG at $tmp_dir"

# Create ISO with an offset so that we can put U-boot between the ISO volume descriptors and the ISO files
xorriso -rockridge "on" -outdev hybrid.iso -volid VOLTEST -joliet "on" \
  -compliance joliet_long_names --append_partition 2 0xef "${CD_RISCV64}/images/boot/grub/efi.img" \
  -boot_image any partition_offset=10240 -boot_image any partition_cyl_align=all \
  -boot_image any efi_path=--interval:appended_partition_2:all:: \
  -boot_image any cat_path=/boot/boot.cat -fs 64m -map "$tmp_dir" / || { echo "Failed to create ISO"; exit 1; }

echo "Plain ISO created successfully using directory: $tmp_dir"

umount "$tmp_dir" || { echo "Failed to unmount $tmp_dir"; exit 1; }
losetup -d "$loop_device" || { echo "Failed to detach loop device $loop_device"; exit 1; }
rmdir "$tmp_dir" || { echo "Failed to remove temporary directory $tmp_dir"; exit 1; }
echo "Unmounted and cleaned up successfully."

# Create a disk with U-Boot
disk_image="hybrid.iso"
parted "${disk_image}" --script mklabel gpt
# Create the first partition (U-Boot), starting at sector 2082 and ending at sector 10273
parted "${disk_image}" --script mkpart primary 2082s 10273s
parted "${disk_image}" --script set 1 boot on
# Create the second partition (U-Boot SPL), starting at sector 10274 and ending at sector 12321
parted "${disk_image}" --script mkpart primary 10274s 12321s

# Set GUID for the first partition (u-boot.itb)
sgdisk "${disk_image}" --typecode=1:2E54B353-1271-4842-806F-E436D6AF6985

# Set GUID for the second partition (u-boot-spl.bin)
sgdisk "${disk_image}" --typecode=2:5B193300-FC78-40CD-8002-E86C45580B47

# Write u-boot.itb to the first partition (starts at sector 2082)
dd if="${CD_RISCV64}/images/boot/u-boot/sifive_unmatched/u-boot.itb" \
   of="${disk_image}" bs=512 seek=2082 conv=notrunc

# Write u-boot-spl.bin to the second partition (starts at sector 10274)
dd if="${CD_RISCV64}/images/boot/u-boot/sifive_unmatched/u-boot-spl.bin" \
   of="${disk_image}" bs=512 seek=10274 conv=notrunc

chmod a+rwx hybrid.iso
echo "Hybrid ISO created successfully."
