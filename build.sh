#!/bin/bash
set -e

# ==============================================================================
# ⚡ Laksanasoft Enterprise Kernel Build Script
# Device : Samsung Galaxy S10+ (beyond2lte / SM-G975F)
# SoC    : Exynos 9820
# ==============================================================================

WORK_DIR="$(pwd)"
KERNEL_SRC="https://github.com/Project-Matrixx-New/android_kernel_samsung_exynos9820.git"
KERNEL_BRANCH="ksunext-susfs"
KERNEL_DIR="$WORK_DIR/kernel"
OUT_DIR="$WORK_DIR/out"
ANYKERNEL_REPO="https://github.com/LeDrew2017/Anykernel.git"
ANYKERNEL_DIR="$WORK_DIR/AnyKernel"
RELEASE_DIR="$WORK_DIR/releases"
DEVICE="beyond2lte"
DEFCONFIG="exynos9820-beyond2lte_defconfig"
KERNEL_VER="v1.0"
ZIP_NAME="Laksanasoft-Enterprise-${DEVICE}-${KERNEL_VER}-KernelSU-Next-NetHunter-Anykernel3.zip"

mkdir -p "$RELEASE_DIR"

echo "================================================================="
echo "⚡ Starting Laksanasoft Enterprise Kernel Build Pipeline"
echo "   Target Device : Samsung Galaxy S10+ ($DEVICE)"
echo "   Base Source   : Project-Matrixx-New (FreeRunner v3.8 base)"
echo "================================================================="

# 1. Fetch Kernel Source if not present
if [ ! -d "$KERNEL_DIR" ]; then
    echo "[*] Cloning kernel source repository (branch: $KERNEL_BRANCH)..."
    git clone --depth=1 -b "$KERNEL_BRANCH" "$KERNEL_SRC" "$KERNEL_DIR"
fi

# 2. Fetch AnyKernel3 if not present
if [ ! -d "$ANYKERNEL_DIR" ]; then
    echo "[*] Cloning AnyKernel3 repository..."
    git clone --depth=1 "$ANYKERNEL_REPO" "$ANYKERNEL_DIR"
fi

# 3. Patch Defconfig & Inject Laksanasoft Drivers
echo "[*] Applying Laksanasoft Enterprise driver configurations..."
bash "$WORK_DIR/scripts/apply_drivers.sh" "$KERNEL_DIR" "$WORK_DIR/configs/laksanasoft_technician.config"

# 4. Set Architecture and Toolchain Environment
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="MuhammadFikri"
export KBUILD_BUILD_HOST="Laksanasoft-Enterprise"

# Toolchain detection
if [ -d "$WORK_DIR/toolchain/bin" ]; then
    export PATH="$WORK_DIR/toolchain/bin:$PATH"
fi

mkdir -p "$OUT_DIR"

# Explicit Make flags to prevent x86 host fallback on GitHub Actions runners
MAKE_FLAGS=(
    ARCH=arm64
    SUBARCH=arm64
    CC=clang
    CROSS_COMPILE=aarch64-linux-gnu-
    CROSS_COMPILE_ARM32=arm-linux-gnueabi-
    CLANG_TRIPLE=aarch64-linux-gnu-
    LLVM=1
    LLVM_IAS=1
)

# 5. Generate .config
echo "[*] Generating defconfig..."
make -C "$KERNEL_DIR" O="$OUT_DIR" "${MAKE_FLAGS[@]}" "$DEFCONFIG"

# Ensure critical technician driver flags are explicitly turned on in generated .config
echo "[*] Verifying critical technician driver flags..."
"$KERNEL_DIR/scripts/config" --file "$OUT_DIR/.config" --enable CONFIG_USB_SERIAL
"$KERNEL_DIR/scripts/config" --file "$OUT_DIR/.config" --enable CONFIG_USB_SERIAL_CH341
"$KERNEL_DIR/scripts/config" --file "$OUT_DIR/.config" --enable CONFIG_USB_SERIAL_CP210X
"$KERNEL_DIR/scripts/config" --file "$OUT_DIR/.config" --enable CONFIG_USB_SERIAL_FTDI_SIO
"$KERNEL_DIR/scripts/config" --file "$OUT_DIR/.config" --enable CONFIG_USB_SERIAL_PL2303
"$KERNEL_DIR/scripts/config" --file "$OUT_DIR/.config" --enable CONFIG_USB_SERIAL_QUALCOMM
"$KERNEL_DIR/scripts/config" --file "$OUT_DIR/.config" --enable CONFIG_USB_ACM
"$KERNEL_DIR/scripts/config" --file "$OUT_DIR/.config" --enable CONFIG_RT2X00
"$KERNEL_DIR/scripts/config" --file "$OUT_DIR/.config" --enable CONFIG_RT2800USB
"$KERNEL_DIR/scripts/config" --file "$OUT_DIR/.config" --enable CONFIG_ATH9K_HTC
"$KERNEL_DIR/scripts/config" --file "$OUT_DIR/.config" --enable CONFIG_88XXAU
"$KERNEL_DIR/scripts/config" --file "$OUT_DIR/.config" --enable CONFIG_USB_CONFIGFS_F_HID
"$KERNEL_DIR/scripts/config" --file "$OUT_DIR/.config" --enable CONFIG_USB_CONFIGFS_MASS_STORAGE
"$KERNEL_DIR/scripts/config" --file "$OUT_DIR/.config" --set-str CONFIG_LOCALVERSION "-⚡️Laksanasoft-Enterprise-${KERNEL_VER}⚡️+"

# Apply olddefconfig to resolve any dependencies
make -C "$KERNEL_DIR" O="$OUT_DIR" "${MAKE_FLAGS[@]}" olddefconfig

# 6. Compile Kernel
echo "[*] Starting compilation with $(nproc) cores..."
BUILD_START=$(date +%s)
make -C "$KERNEL_DIR" O="$OUT_DIR" "${MAKE_FLAGS[@]}" -j"$(nproc)"
BUILD_END=$(date +%s)

IMAGE_PATH="$OUT_DIR/arch/arm64/boot/Image"
if [ ! -f "$IMAGE_PATH" ]; then
    echo "[-] ERROR: Compilation failed! Image not found at $IMAGE_PATH"
    exit 1
fi

DURATION=$((BUILD_END - BUILD_START))
echo "[+] Build completed successfully in $((DURATION / 60))m $((DURATION % 60))s!"

# 7. Package into AnyKernel3 Flashable Zip
echo "[*] Packaging kernel into AnyKernel3 flashable zip..."
rm -f "$ANYKERNEL_DIR/Image" "$ANYKERNEL_DIR"/*.zip
cp "$IMAGE_PATH" "$ANYKERNEL_DIR/Image"

# Customize anykernel.sh branding
sed -i 's/kernel.string=.*/kernel.string=⚡️ Laksanasoft Enterprise Kernel for Galaxy S10+ (beyond2lte) ⚡️/g' "$ANYKERNEL_DIR/anykernel.sh"
sed -i 's/device.name1=.*/device.name1=beyond2lte/g' "$ANYKERNEL_DIR/anykernel.sh"

cd "$ANYKERNEL_DIR"
zip -r9 "$ZIP_NAME" * -x .git\* README.md\*
mv "$ZIP_NAME" "$RELEASE_DIR/"
cd "$WORK_DIR"

echo "================================================================="
echo "⚡ SUCCESS! Flashable Zip created:"
echo "   $RELEASE_DIR/$ZIP_NAME"
echo "   File Size: $(stat -c%s "$RELEASE_DIR/$ZIP_NAME" 2>/dev/null || stat -f%z "$RELEASE_DIR/$ZIP_NAME" 2>/dev/null) bytes"
echo "================================================================="
