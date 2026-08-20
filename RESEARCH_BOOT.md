# COMPREHENSIVE RESEARCH REPORT: Xiaomi Redmi 9A (dandelion / dandelion_in) GSI & Custom ROM Booting Investigation

**Target Device:** Xiaomi Redmi 9A / 9i / 9AT / 10A  
**Codenames:** `dandelion`, `dandelion_in` (Unified Device Family: `garden` / `blossom` / MT6765 / MT6762G)  
**SoC:** MediaTek Helio G25 (MT6762G / MT6765, 8x ARM Cortex-A53)  
**Stock Baseline:** MIUI 12.0.x / 12.5.x (Android 10 Q / Android 11 R Vendor)  

---

## Executive Summary

The Xiaomi Redmi 9A (`dandelion`) has a critical architectural characteristic that causes standard GSIs to fail to boot:
1. **Architectural Mismatch (ARM64 vs. A64 / ARM32_Binder64):** Although the MediaTek Helio G25 SoC has a 64-bit CPU architecture (ARMv8-A Cortex-A53), Xiaomi shipped the stock MIUI 12 (Android 10) firmware with a **64-bit kernel paired with a 32-bit userland and 64-bit binder IPC** (`arm32_binder64` / **`A64`**). Flashing a standard `arm64` GSI over stock vendor causes immediate linker/HAL crashes and reboots into Fastboot.
2. **Dynamic Partitions (`super.img`) & Fastboot vs. Fastbootd:** `dandelion` natively uses dynamic partitioning. Flashing `system.img` in standard bootloader Fastboot mode fails or corrupts the super partition metadata. Flashing must occur inside **`fastbootd`** (userspace Fastboot).
3. **Android Verified Boot (AVB 2.0) & dm-verity:** If `vbmeta.img` is not flashed with verification disabled flags (`--disable-verity --disable-verification`), the bootloader flags a verification error (`RED STATE` / AVB verification fail) and drops back to Fastboot or hangs on the Redmi logo.

---

## 1. Root Cause Analysis: Why GSIs Drop into Fastboot or Hang on Splash

### A. Architecture Mismatch (`arm64` vs. `arm32_binder64` / `A64`)
* **The Root Cause:** The Helio G25 CPU is 64-bit, but Xiaomi's stock Android 10 vendor libraries (`/vendor/lib`, camera HAL, audio HAL, RIL daemons) are compiled entirely as **32-bit ARM** binaries communicating over a **64-bit Binder interface** (`arm32_binder64` or `A64`).
* **Failure Symptom:** Flashing an `arm64-ab` GSI forces 64-bit Android system daemons and `surfaceflinger`/`init` to attempt loading 32-bit vendor HALs or binder drivers. The ABI mismatch causes `init` to abort, resulting in a fatal kernel panic or immediate watchdog reboot back into Fastboot mode.
* **Solution:** When booting over stock MIUI 12 / Android 10 vendor, users **MUST** flash **`a64_bvN` / `a64_bgN` / `a64_bvs` / `a64_bgn`** GSIs (`arm32_binder64-ab`).

### B. Bootloader Fastboot vs. Userspace `fastbootd` (Dynamic Partitions / `super.img`)
* **The Root Cause:** Redmi 9A launched with Android 10 and utilizes Android Dynamic Partitions (`super` partition containing `system`, `vendor`, and `product` logical sub-partitions).
* **Failure Symptom:** Standard bootloader Fastboot operates at the physical partition level. Executing `fastboot flash system system.img` in bootloader mode returns partition errors or corrupts the dynamic partition table.
* **Solution:** Enter userspace **`fastbootd`** mode via `fastboot reboot fastboot`. Only in `fastbootd` does the OS recognize and resize logical dynamic partitions.

### C. AVB 2.0 / `dm-verity` Verification Failure
* **The Root Cause:** Xiaomi's bootloader enforces Android Verified Boot (AVB 2.0).
* **Failure Symptom:** If AVB is not explicitly disabled, the bootloader fails verification during early init and triggers a fallback loop or immediate bootloader recovery trip into Fastboot.
* **Solution:** Disable AVB verification using `fastboot --disable-verity --disable-verification flash vbmeta vbmeta.img` or patched vbmeta with `flags=3`.

---

## 2. Matrix of Tested Custom ROMs & GSIs for Dandelion

| Type | Name / Developer | Architecture | Partition Type | VNDK Type | Boot Status & Notes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **GSI** | **AndyCGYan LineageOS 20.0 Light** | `a64` (`a64_bvN-vndklite`) | A/B (system-as-root) | `vndklite` | **Boots flawlessly** on MIUI 12 vendor. Stable RIL & Wi-Fi. |
| **GSI** | **AndyCGYan LineageOS 18.1 Light** | `a64` (`a64_bvS-vndklite`) | A/B (system-as-root) | `vndklite` | **Boots cleanly**. Exceptional RAM management on 2GB/3GB models. |
| **GSI** | **TrebleDroid / Ponces AOSP 13 / 14** | `a64` (`a64_bvN`) | A/B (system-as-root) | `vndklite` | **Boots**. Smooth performance; requires phh MTK patches. |
| **GSI** | **Any ARM64 GSI (e.g. `arm64_bvN`)** | `arm64` | A/B | Any | ❌ **FAILS / BOOTLOOP** over stock vendor due to 32-bit HAL ABI mismatch. |

---

## Primary References & Sources
1. **Phhusson Treble Experimentations:** [phhusson/treble_experimentations](https://github.com/phhusson/treble_experimentations)
2. **TrebleDroid Source & Wiki:** [TrebleDroid Releases](https://github.com/TrebleDroid)
3. **AndyCGYan LineageOS GSI Builds:** [AndyCGYan/lineage_build_unified](https://github.com/AndyCGYan/lineage_build_unified)
4. **PitchBlack Recovery Project (dandelion):** [PBRP/android_device_xiaomi_dandelion-pbrp](https://github.com/PitchBlackRecoveryProject/android_device_xiaomi_dandelion-pbrp)
5. **Redmi MT6765 Unified Device Tree:** [Redmi-MT6765/android_device_xiaomi_dandelion](https://github.com/Redmi-MT6765/android_device_xiaomi_dandelion)
