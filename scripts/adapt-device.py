#!/usr/bin/env python3
"""Conservative AxionOS-specific edits on top of Hecker's EvoX coral tree."""
from pathlib import Path
import re

cwd = Path.cwd()
root = cwd if (cwd / "lineage_coral.mk").is_file() else cwd / "device/google/coral"
if not root.is_dir():
    raise SystemExit("Expected device/google/coral; run from an Android source checkout")

product = root / "lineage_coral.mk"
text = product.read_text()
text = re.sub(r"(?m)^EVO_BUILD_TYPE\s*:?=\s*.*\n", "", text)
text = re.sub(r"(?m)^WITH_GMS\s*:?=\s*.*\n", "", text)
text = text.replace("# Infinity-X Build Flags", "# AxionOS coral device configuration")
text = text.replace("# 3D face unlock (Pixel Neural Core) replaces Infinity's camera-based FaceUnlock",
                    "# Preserve Pixel 4's 3D infrared face HAL; disable software selfie FaceUnlock")
text = text.replace("# GoogleCameraCoral replaces Infinity-X's default Aperture app.",
                    "# GoogleCameraCoral from vendor replaces the standard camera app.")
text = text.replace("# RisingOS About Phone properties: market name and camera are in product.prop.\n# RisingChipset below generates ro.rising.chipset; do not define it twice.\n", "")
new = (
    "# AxionOS flags and About Phone details\n"
    "TARGET_DISABLE_EPPE := true\n"
    "TARGET_INCLUDE_AXFX := true\n"
    "AXION_CAMERA_REAR_INFO := 12,16\n"
    "AXION_CAMERA_FRONT_INFO := 8\n"
    "AXION_MAINTAINER := Hecker\n"
    "AXION_PROCESSOR := Snapdragon_855\n\n"
)
if "AXION_MAINTAINER :=" not in text:
    marker = "$(call inherit-product, vendor/lineage/config/common_full_phone.mk)"
    if marker not in text:
        raise SystemExit("Expected Lineage product inheritance not found; refusing unsafe port")
    text = text.replace(marker, new + marker, 1)
product.write_text(text)

# Existing hardware-specific configs, face HIDL, Soli packages, GCam and kernel
# assumptions are preserved. Android 17 compatibility must be validated at build time.
print("AxionOS coral product flags adapted; original hardware support retained.")
