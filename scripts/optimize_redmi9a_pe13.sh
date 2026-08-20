#!/usr/bin/env bash
# ==============================================================================
# Redmi 9A (dandelion / blossom) Pixel Experience Android 13 Post-Install Optimizer
# Authored by: Divyansh Joshi (oldregime)
# ==============================================================================

set -euo pipefail

echo "=========================================================="
echo "⚡ Redmi 9A Post-Install Performance Optimizer"
echo "=========================================================="

# Check ADB connection
if ! adb get-state 1>/dev/null 2>&1; then
    echo "❌ Error: Device not detected via ADB. Please enable USB Debugging."
    exit 1
fi

DEVICE_MODEL=$(adb shell getprop ro.product.model | tr -d '\r')
ANDROID_VER=$(adb shell getprop ro.build.version.release | tr -d '\r')

echo "📱 Connected Device: $DEVICE_MODEL (Android $ANDROID_VER)"

echo ""
echo "🚀 [1/6] Uncapping UI Animations to 0.5x for Instant Snappiness..."
adb shell settings put global window_animation_scale 0.5
adb shell settings put global transition_animation_scale 0.5
adb shell settings put global animator_duration_scale 0.5

echo "🌐 [2/6] Configuring Cloudflare 1.1.1.1 Private DNS..."
adb shell settings put global private_dns_mode "hostname"
adb shell settings put global private_dns_specifier "one.one.one.one"

echo "🔋 [3/6] Tuning Standby Doze Timings (Instant Deep Sleep)..."
adb shell settings put global device_idle_constants "inactive_to=30000,sensing_to=0,locating_to=0,location_accuracy=20.0,motion_inactive_to=0,idle_after_inactive_to=0"

echo "🏎️ [4/6] Optimizing Touch Hold Delay & Interaction Response..."
adb shell settings put secure long_press_timeout 250
adb shell settings put secure multi_press_timeout 200

echo "🛡️ [5/6] Whitelisting Essential Background Media & Cloud Sync..."
adb shell dumpsys deviceidle whitelist +com.google.android.apps.photos || true
adb shell dumpsys deviceidle whitelist +app.revanced.android.apps.youtube.music || true
adb shell dumpsys deviceidle whitelist +com.google.android.gms || true

echo "⚡ [6/6] Executing Ahead-Of-Time (AOT) Machine Code Compilation for Critical System Services..."
echo "Compiling System UI..."
adb shell cmd package compile -m speed com.android.systemui || true
echo "Compiling Pixel Launcher..."
adb shell cmd package compile -m speed com.google.android.apps.nexuslauncher || true
echo "Compiling Google Photos..."
adb shell cmd package compile -m speed com.google.android.apps.photos || true

echo ""
echo "=========================================================="
echo "✅ Redmi 9A Optimization Completed Successfully!"
echo "Enjoy lightning fast Pixel Experience on Helio G25."
echo "=========================================================="
