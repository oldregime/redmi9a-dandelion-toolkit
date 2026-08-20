# 📋 TECHNICAL POST-MORTEM & ROOT CAUSE ANALYSIS: Xiaomi Redmi 9A Custom ROM & GSI Flashing

**Device:** Xiaomi Redmi 9A / 9i (`dandelion` / `dandelion_in`, Model `M2006C3LI`)  
**SoC:** MediaTek Helio G25 (MT6762G / MT6765, 8x Cortex-A53)  
**Stock OS Base:** MIUI 12.0.26.0.QCDINXM (Android 10 Q Vendor / Linux Kernel 4.9.190)  
**Date:** August 20, 2026  

---

## 1. Executive Summary & Why Custom ROM / GSI Booting Failed

During our custom ROM flashing attempts, we achieved:
- ✅ **Bootloader Instant Unlocking:** Successfully bypassed Xiaomi's 168-hour server lock using the MediaTek BROM `seccfg` exploit (`mtkclient`).
- ✅ **Hardware Partition Protection:** Dumped and verified raw backups of all security and calibration partitions (`nvram`, `nvdata`, `proinfo`, `protect1`, `protect2`, `seccfg`, `md1img`).
- ✅ **Dynamic Partition Operations:** Successfully manipulated dynamic partitions inside `fastbootd`.
- ✅ **Working Custom Recovery:** Flashed and booted **TWRP 3.7.0** on the device with working touch and root ADB shell access.

However, booting generic system images (LineageOS 20 Android 13, LineageOS 18.1 Android 11) repeatedly dropped back to Fastboot due to **three interlocking MediaTek architecture constraints** specific to the Redmi 9A:

---

## 2. Deep Root Cause Breakdown

### A. The 64-bit Kernel / 32-bit Vendor ABI Trap (A64 vs. ARM64)
* **The Trap:** The Helio G25 SoC has a 64-bit CPU architecture. However, to save RAM on budget 2GB/3GB models, Xiaomi compiled all stock MIUI 12 vendor HAL binaries (`/vendor/lib`, graphics `gralloc`, camera `libcameracustom`, audio, RIL) as **32-bit ARM binaries** communicating over a **64-bit Binder IPC** (`arm32_binder64` / `A64`).
* **Why `ARM64` GSIs Failed:** Flashing standard `arm64_bvN` GSIs forced 64-bit Android system daemons (`init`, `surfaceflinger`, `mediaserver`) to attempt linking against 32-bit vendor libraries. The dynamic linker crashed immediately on boot, triggering an instant kernel panic that dropped the phone into Fastboot.

### B. Linux Kernel 4.9 vs. Modern Android eBPF Requirements (Android 13 vs Android 10)
* **The Constraint:** The Redmi 9A stock kernel is **Linux 4.9.190**. In Android 12, 13, and 14, Google mandated kernel `eBPF` network filtering and updated `seccomp` syscalls in early `init`.
* **Failure Mechanism:** Linux Kernel 4.9 lacks these backported eBPF maps. When Android 13 (`LineageOS 20`) `init` starts, it attempts to load BPF programs, receives `ENOSYS (Function not implemented)`, and aborts, triggering a hardware watchdog reboot to the bootloader.

### C. The Dynamic Partition (`super.img`) Table Constraint
* **The Constraint:** Xiaomi’s `super` partition contains three logical partitions: `system`, `vendor`, and `product`.
* **Failure Mechanism:** The stock `boot.img` ramdisk and Device Tree Blob (DTB) hardcode mount entries for `product`. When `product` was deleted in `fastbootd` to create space for larger GSI system images, the kernel's first-stage mount failed because it could not resolve the expected `/product` dynamic partition, causing a boot abort.

### D. Multi-Table Android Verified Boot (AVB 2.0)
* **The Constraint:** Unlike Qualcomm devices that often use a single `vbmeta.img`, Redmi 9A uses **three separate AVB verification partitions**: `vbmeta`, `vbmeta_system`, and `vbmeta_vendor`.
* **Failure Mechanism:** If `vbmeta_system` or `vbmeta_vendor` retains stock verification signatures while `/system` or `/vendor` is modified, LittleKernel (lk2) rejects the partition signature during early boot and drops straight into Fastboot mode.

---

## 3. The Working Solution: What the Community Uses

According to XDA Developers and 4PDA threads (e.g. *Thread 4675879* and *crDroid v9.1*):
1. **Custom Recovery as Base:** Flashing **TWRP 3.7.0** or **OrangeFox R11.1** for `dandelion`.
2. **Vendor Upgrade:** Flashing a dedicated **Vendor R** flashable zip (which replaces the 32-bit Android 10 vendor with a full 64-bit Android 11 vendor tree).
3. **Flashing Dedicated Custom ROM ZIPs:** Instead of raw GSI system images, flashing unified `garden/blossom` device-specific custom ROM zip packages in TWRP that include a matched kernel and device trees.

---

## 4. Current Restoration Execution

To return the phone to 100% stable, fully functional condition:
* We are flashing the **Official Xiaomi Factory Fastboot ROM** (`dandelion_in_global_images_V12.0.26.0.QCDINXM`).
* This writes clean, factory-calibrated partitions:
  * `preloader`, `lk`, `lk2`, `boot`, `recovery`, `dtbo`, `tee1`, `tee2`
  * Complete original `super.img` (`system` + `vendor` + `product`)
  * `vbmeta`, `vbmeta_system`, `vbmeta_vendor`, `md1img`, `cust`, `userdata`
* All calibration and IMEI partitions (`nvram`, `nvdata`, `proinfo`) remain preserved and verified.

---
*Report archived at `/mnt/personal file/from w11/phone/REDMI9A_FLASHING_POSTMORTEM_AND_ANALYSIS.md`.*
