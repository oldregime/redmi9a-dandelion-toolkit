#!/bin/bash
set -e
echo "=== Restoring OrangeFox Recovery & Preparing Pixel Experience ==="
fastboot flash recovery ../recoveries/orangefox_r12.0_blossom.img
fastboot --disable-verity --disable-verification flash vbmeta ../recoveries/vbmeta_disabled_avb.img
fastboot --disable-verity --disable-verification flash vbmeta_system ../recoveries/vbmeta_disabled_avb.img
fastboot --disable-verity --disable-verification flash vbmeta_vendor ../recoveries/vbmeta_disabled_avb.img
echo "Rebooting into OrangeFox Recovery..."
fastboot reboot recovery || fastboot reboot
echo "Hold Power + Volume UP if recovery does not auto-boot."
