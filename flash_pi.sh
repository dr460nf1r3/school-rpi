#!/usr/bin/env bash
# shellcheck disable=SC2164
# Parameters
CURRENT_DL=https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2023-05-03/2023-05-03-raspios-bullseye-arm64-lite.img.xz
CURRENT_IMG=2023-05-03-raspios-bullseye-arm64-lite.img
SDCARD_PATH=/dev/sdX
WORK_DIR=./tmp

# Check for root rights
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Create work dir
mkdir -p "$WORK_DIR" \
    && pushd "$WORK_DIR" || exit 1

# Get current image if not present
if [ ! -f "$CURRENT_IMG" ]; then
    wget "$CURRENT_DL" || exit 2
    tar xfv "$CURRENT_IMG".xz || exit 3
fi

# Write image to sd card & remove image if success
dd if="$CURRENT_IMG" of="$SDCARD_PATH" status=progress bs=1M \
    && rm "$CURRENT_IMG" || exit 4

# Return to previous dir
popd 

# Mount sd card
mkdir -p /mnt/sdcard/{boot,root}
mount "$SDCARD_PATH"1 /mnt/sdcard/boot
mount "$SDCARD_PATH"2 /mnt/sdcard/root

# Copy files
umount "$SDCARD_PATH"1 "$SDCARD_PATH"2 
rm -r /mnt/sdcard
