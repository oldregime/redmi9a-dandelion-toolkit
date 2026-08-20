# 📸 Unlimited Google Photos & FOSS Media Suite Setup

How to configure **Unlimited Original Quality Google Photos Cloud Backup**, **ReVanced YouTube & RVX Music**, and **FOSS Workstation tools** on the unified Pixel Experience 13 (`blossom`) build.

---

## 🌟 1. Unlimited Google Photos Original Quality Backup

The installed Pixel Experience Plus ROM includes built-in Google Pixel framework spoofing (`com.google.android.apps.photos` spoofed to Pixel 1 XL / `sailfish`).

### Verification Steps:
1. Open **Google Photos**.
2. Tap your profile icon on the top right.
3. Check Account Storage status:
   ```
   "This Pixel can back up unlimited photos & videos at no charge."
   ```
4. All media backed up from this device will consume **0 MB** of your 15 GB Google Account quota.

---

## 🎵 2. ReVanced YouTube & RVX Music with GMS Core

Because Pixel Experience includes full microG/GMS support:

1. **Install GMS Core (`app.revanced.android.gms`):**
   * Acts as the microG bridge for Google Account authentication.
2. **Install ReVanced YouTube & RVX Music:**
   * In-app ad blocking.
   * Background audio playback with screen locked.
   * `visionOS` client spoofing enabled in settings to prevent stream buffering.
3. **Whitelist from Doze:**
   ```bash
   adb shell dumpsys deviceidle whitelist +app.revanced.android.apps.youtube.music
   ```

---

## 🚀 3. Continuous Sync Setup with Linux / PC

* **KDE Connect / LocalSend:** Pair over local Wi-Fi for instantaneous file transfer and unified clipboard synchronization.
* **Syncthing:** Automated 2-way folder mirror between PC and Redmi 9A DCIM camera directory for zero-touch cloud backups.
