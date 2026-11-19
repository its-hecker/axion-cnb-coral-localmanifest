#!/usr/bin/env bash
set -euo pipefail

: "${AXION_BRANCH:=lineage-24.0}"
: "${AXION_BUILD_VARIANT:=userdebug}"
: "${AXION_GMS_VARIANT:=core}"
: "${AXION_BUILD_JOBS:=8}"

[[ -d .repo/manifests ]] || {
  echo "Initialize with: repo init -u https://github.com/AxionAOSP/android.git -b ${AXION_BRANCH} --git-lfs" >&2
  exit 1
}

# A lineage-24.0 branch exists, but as of 2026-11-19 it is still an Android-16 manifest.
# Check actual content, not branch name, before potentially syncing hundreds of repos.
manifest=".repo/manifests/default.xml"
[[ -f "$manifest" ]] || { echo "Missing upstream manifest: $manifest" >&2; exit 1; }
if grep -Eq 'android-16\.0\.0_|refs/heads/lineage-23\.' "$manifest"; then
  echo "STOP: Axion upstream manifest is still Android 16 / LineageOS 23.x." >&2
  echo "Wait for the published Android 17 / LineageOS 24.x manifest before building." >&2
  exit 2
fi
if ! grep -Eq 'android-17|lineage-24\.' "$manifest"; then
  echo "STOP: Could not positively validate Android 17 manifest revisions." >&2
  exit 2
fi

for path in .repo/local_manifests/coral.xml; do
  [[ -f "$path" ]] || { echo "Missing $path" >&2; exit 1; }
done

repo sync -c --fail-fast --no-clone-bundle --no-tags -j4
[[ -f device/google/coral/lineage_coral.mk ]] || { echo "Device tree missing"; exit 1; }
[[ -f vendor/google/coral/camera/tools/prepare_camera.py ]] || { echo "Camera vendor missing"; exit 1; }

git -C kernel/google/msm-4.14 submodule update --init --recursive
git -C vendor/google/coral lfs pull

python3 device/google/coral/faceunlock/tools/apply_framework_fixes.py --check
python3 device/google/coral/faceunlock/tools/apply_framework_fixes.py --apply
python3 vendor/google/coral/camera/tools/prepare_camera.py --check-hashes

source build/envsetup.sh
if [[ "${AXION_GENERATE_KEYS:-0}" == "1" ]]; then
  # Axion recommends gk -s once for private release signing keys.
  gk -s
fi
axion coral "$AXION_BUILD_VARIANT" "$AXION_GMS_VARIANT"
ax -br -j"$AXION_BUILD_JOBS"
