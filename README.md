# AxionOS for Pixel 4 XL (coral)

Device-side Android 17 preparation based on Hecker's Evolution X coral hardware sources.

**Upstream status (2026-11-19):** AxionAOSP/android has a lineage-24.0 branch, but its default.xml still points to Android 16 and lineage-23.2. This is **not** yet a ready Android 17 build. Do not flash or release these staging sources without a successful build and on-device validation.

## Repositories
- `axion-cnb-coral-dt` — device tree, ported from `evox-coral-dt`
- `axion-cnb-coral-vendor` — proprietary vendor including stock Google Camera
- `axion-cnb-coral-kernel` — floral 4.14 kernel and its KernelSU submodule
- This repository supplies `coral.xml`, the port helper, and guarded build orchestration.

The three hardware repositories are populated on their `cnb-android17-prep` branch by their individual bootstrap GitHub Actions. Their default branches are deliberately left untouched until verified.

## Initial clone and Android 17 readiness check
```bash
mkdir -p ~/axion-coral && cd ~/axion-coral
repo init -u https://github.com/AxionAOSP/android.git -b lineage-24.0 --git-lfs
git clone https://github.com/its-hecker/axion-cnb-coral-localmanifest.git .repo/local_manifests
bash .repo/local_manifests/build.sh
```

The build script **stops before syncing** if upstream lineage-24.0 still targets Android 16. Only continue after Axion's Android 17 branch is actually updated.

## Hardware goals
Keep original 3D IR Face Unlock (not a 2D selfie unlock), Soli Motion Sense, Google Camera 8.7 with required split APKs and vendor HALs. Also preserve coral radio, audio, sensors and partitions; Dolby dependencies are retained from the source tree.

## Known validation gates
- Confirm upstream Android 17 manifest/LineageOS dependencies before attempting a build.
- Run the guarded framework face compatibility patch against the actual Axion 17 frameworks/base. A changed framework requires a reviewed port, not a blind patch.
- Confirm camera APK SHA-256 verification, camera startup, and IR-based biometric enrollment.
- Verify Git LFS radio files are accessible from the new vendor repository. A pointer-only repository is insufficient.
- Verify kernel and vendor module pairing by installing the **full** ROM package, not only boot.img.

No successful Axion Android 17 compilation or boot is claimed here.
