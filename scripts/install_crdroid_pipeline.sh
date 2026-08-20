#!/bin/bash
set -e

DIR="/mnt/personal file/from w11/phone"
CR_DIR="$DIR/crdroid_install"
cd "$DIR"

echo "=========================================================="
echo " Starting Official crDroid Automated Flashing Pipeline"
echo "=========================================================="

echo "Waiting for phone in Fastboot or ADB Recovery..."
while true; do
  dev_fb=$(fastboot devices | awk '{print $1}')
  dev_adb=$(adb devices | grep -E "recovery|device" | awk '{print $1}')
  if [ -n "$dev_fb" ]; then
    echo "Found Fastboot Device: $dev_fb"
    echo "=== 1. Flashing OrangeFox R12.0 Recovery ==="
    fastboot flash recovery "$CR_DIR/ofox_recovery.img"
    fastboot --disable-verity --disable-verification flash vbmeta "$DIR/vbmeta_patched.img"
    fastboot --disable-verity --disable-verification flash vbmeta_system "$DIR/vbmeta_patched.img"
    fastboot --disable-verity --disable-verification flash vbmeta_vendor "$DIR/vbmeta_patched.img"
    echo "Rebooting into OrangeFox Recovery..."
    fastboot reboot recovery || fastboot reboot
    sleep 10
    break
  elif [ -n "$dev_adb" ]; then
    echo "Found ADB Device in Recovery: $dev_adb"
    break
  fi
  sleep 1
done

echo "Waiting for ADB in Recovery mode..."
while true; do
  state=$(adb get-state 2>/dev/null || true)
  if [ "$state" = "recovery" ] || [ "$state" = "device" ]; then
    echo "Connected to Recovery ADB!"
    break
  fi
  sleep 2
done

echo "=== 2. Formatting Userdata (Removing Encryption) ==="
adb shell "twrp format data 2>&1 || true; umount /data 2>/dev/null || true; mke2fs -t ext4 /dev/block/by-name/userdata"

echo "=== 3. Pushing & Flashing Base Firmware (V12.5.9.0.RCDINXM) ==="
adb push "$CR_DIR/fw_dandelion_V12.5.9.0.RCDINXM.zip" /tmp/firmware.zip
adb shell "twrp install /tmp/firmware.zip"

echo "=== 4. Pushing & Flashing Official crDroid Android ROM ==="
adb push "$CR_DIR/crDroidAndroid-16.0-blossom-v12.11.zip" /tmp/crdroid.zip
adb shell "twrp install /tmp/crdroid.zip"

echo "=== 5. Pushing & Flashing Magisk v27.0 (Root & Play Integrity) ==="
adb push "$DIR/Magisk-v27.0.apk" /tmp/magisk.zip
adb shell "twrp install /tmp/magisk.zip"

echo "=== 6. Wiping Cache & Dalvik ==="
adb shell "twrp wipe cache; twrp wipe dalvik"

echo "=== 7. Rebooting into crDroid! ==="
adb reboot
echo "=========================================================="
echo " crDroid Installation Complete! Phone is Booting!"
echo "=========================================================="
