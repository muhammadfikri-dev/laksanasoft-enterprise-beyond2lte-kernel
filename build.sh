#!/bin/bash
set -e

# ==============================================================================
# ⚡ Laksanasoft Enterprise Kernel Build Pipeline
# Target Device : Samsung Galaxy S10+ (beyond2lte / SM-G975F)
# Operating Sys : LineageOS 23.2 (Android 16)
# Base Source   : Project-Matrixx-New (Branch: ksunext-qpr2 - Official v3.8 base)
# Installer     : Extracted directly from working nhh.zip
# ==============================================================================

WORK_DIR="$(pwd)"
KERNEL_SRC="https://github.com/Project-Matrixx-New/android_kernel_samsung_exynos9820.git"
KERNEL_BRANCH="ksunext-qpr2"
KERNEL_DIR="$WORK_DIR/kernel"
OUT_DIR="$WORK_DIR/out"
ANYKERNEL_DIR="$WORK_DIR/AnyKernel_Base"
RELEASE_DIR="$WORK_DIR/releases"
DEVICE="beyond2lte"
KERNEL_VER="v1.0"
ZIP_NAME="Laksanasoft-Enterprise-${DEVICE}-${KERNEL_VER}-Polly-KernelSU-Next-NetHunter-Anykernel3.zip"

mkdir -p "$RELEASE_DIR" "$OUT_DIR"

echo "================================================================="
echo "⚡ Starting Laksanasoft Enterprise Kernel Build Pipeline"
echo "   Target Device : Samsung Galaxy S10+ ($DEVICE)"
echo "   Target ROM    : LineageOS 23.2 (Android 16)"
echo "   Base Source   : Project-Matrixx-New (Branch: $KERNEL_BRANCH)"
echo "================================================================="

# 1. Fetch Official Kernel Source (Branch ksunext-qpr2) with Submodules
if [ ! -d "$KERNEL_DIR" ]; then
    echo "[*] Cloning kernel source repository (branch: $KERNEL_BRANCH)..."
    git clone --depth=1 -b "$KERNEL_BRANCH" "$KERNEL_SRC" "$KERNEL_DIR"
    echo "[*] Initializing KernelSU-Next submodule (branch: legacy-susfs-v2)..."
    cd "$KERNEL_DIR"
    git submodule update --init --recursive --depth 1 || true
    if [ ! -f "$KERNEL_DIR/KernelSU-Next/kernel/Kconfig" ] || [ ! -f "$KERNEL_DIR/KernelSU-Next/kernel/Makefile" ]; then
        echo "[*] Cloning KernelSU-Next (branch: legacy-susfs-v2)..."
        rm -rf "$KERNEL_DIR/KernelSU-Next"
        git clone --depth=1 -b legacy-susfs-v2 https://github.com/sidex15/KernelSU-Next.git "$KERNEL_DIR/KernelSU-Next"
    fi
    # Strip any strict -Werror from KernelSU build files
    find "$KERNEL_DIR/KernelSU-Next" -type f \( -name "Kbuild" -o -name "Makefile" \) -exec sed -i 's/-Werror//g' {} + 2>/dev/null || true
    cd "$WORK_DIR"
fi

# 2. Setup Toolchain Environment
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="MuhammadFikri"
export KBUILD_BUILD_HOST="Laksanasoft-Enterprise"
export KCFLAGS="-Wno-error -Wno-misleading-indentation"

CLANG_BIN=$(find "$WORK_DIR/toolchain" -name "clang" -type f -perm /111 2>/dev/null | head -n 1)
if [ -n "$CLANG_BIN" ]; then
    TOOLCHAIN_BIN=$(dirname "$CLANG_BIN")
    export PATH="$TOOLCHAIN_BIN:$PATH"
elif [ -d "$WORK_DIR/toolchain/bin" ]; then
    export PATH="$WORK_DIR/toolchain/bin:$PATH"
fi

echo "[*] Verifying compiler environment:"
which clang || true
clang --version || true
which aarch64-linux-gnu-gcc || true

MAKE_FLAGS=(
    ARCH=arm64
    SUBARCH=arm64
    CC=clang
    CROSS_COMPILE=aarch64-linux-gnu-
    CROSS_COMPILE_ARM32=arm-linux-gnueabi-
    CLANG_TRIPLE=aarch64-linux-gnu-
    LLVM=1
    LLVM_IAS=1
    KCFLAGS="-Wno-error -Wno-misleading-indentation"
)

# 3. Base Configuration from Real Working Phone System
echo "[*] Loading clean verified configuration from running S10+ phone..."
if [ -f "$WORK_DIR/configs/phone_running_clean.config" ]; then
    cp "$WORK_DIR/configs/phone_running_clean.config" "$OUT_DIR/.config"
    echo "[+] Successfully loaded phone_running_clean.config"
else
    echo "[-] Fallback: using exynos9820-beyond2lte_defconfig"
    make -C "$KERNEL_DIR" O="$OUT_DIR" "${MAKE_FLAGS[@]}" exynos9820-beyond2lte_defconfig
fi

# 4. Inject Missing Hardware Flashing & Microcontroller Drivers
echo "[*] Injecting technician USB drivers and LLVM Polly..."
"$KERNEL_DIR/scripts/config" --file "$OUT_DIR/.config" --enable CONFIG_USB_SERIAL
"$KERNEL_DIR/scripts/config" --file "$OUT_DIR/.config" --enable CONFIG_USB_SERIAL_CONSOLE
"$KERNEL_DIR/scripts/config" --file "$OUT_DIR/.config" --enable CONFIG_USB_SERIAL_GENERIC
"$KERNEL_DIR/scripts/config" --file "$OUT_DIR/.config" --enable CONFIG_USB_SERIAL_SIMPLE
"$KERNEL_DIR/scripts/config" --file "$OUT_DIR/.config" --enable CONFIG_USB_SERIAL_CH341
"$KERNEL_DIR/scripts/config" --file "$OUT_DIR/.config" --enable CONFIG_USB_SERIAL_CP210X
"$KERNEL_DIR/scripts/config" --file "$OUT_DIR/.config" --enable CONFIG_USB_SERIAL_FTDI_SIO
"$KERNEL_DIR/scripts/config" --file "$OUT_DIR/.config" --enable CONFIG_USB_SERIAL_PL2303
"$KERNEL_DIR/scripts/config" --file "$OUT_DIR/.config" --enable CONFIG_USB_SERIAL_QUALCOMM
"$KERNEL_DIR/scripts/config" --file "$OUT_DIR/.config" --enable CONFIG_USB_SERIAL_OPTION
"$KERNEL_DIR/scripts/config" --file "$OUT_DIR/.config" --enable CONFIG_USB_SERIAL_WWAN
"$KERNEL_DIR/scripts/config" --file "$OUT_DIR/.config" --enable CONFIG_USB_ACM
"$KERNEL_DIR/scripts/config" --file "$OUT_DIR/.config" --enable CONFIG_RT2X00
"$KERNEL_DIR/scripts/config" --file "$OUT_DIR/.config" --enable CONFIG_RT2800USB
"$KERNEL_DIR/scripts/config" --file "$OUT_DIR/.config" --enable CONFIG_LLVM_POLLY
"$KERNEL_DIR/scripts/config" --file "$OUT_DIR/.config" --set-str CONFIG_LOCALVERSION "-⚡️Laksanasoft-Enterprise-${KERNEL_VER}-Polly⚡️+"

# Ensure KSU and SuSFS stay enabled as on the running phone
"$KERNEL_DIR/scripts/config" --file "$OUT_DIR/.config" --enable CONFIG_KSU
"$KERNEL_DIR/scripts/config" --file "$OUT_DIR/.config" --enable CONFIG_KSU_SUSFS
"$KERNEL_DIR/scripts/config" --file "$OUT_DIR/.config" --enable CONFIG_KSU_SUSFS_SUS_MEMFD

echo "[*] Resolving config dependencies with olddefconfig..."
make -C "$KERNEL_DIR" O="$OUT_DIR" "${MAKE_FLAGS[@]}" olddefconfig

# 5. Compile Kernel Binary
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

# 6. Package into AnyKernel3 Flashable Zip (using verified nhh.zip template)
echo "[*] Packaging kernel into AnyKernel3 flashable zip..."
rm -f "$ANYKERNEL_DIR/Image" "$ANYKERNEL_DIR"/*.zip
cp "$IMAGE_PATH" "$ANYKERNEL_DIR/Image"

# Set enterprise branding in anykernel.sh
sed -i 's/kernel.string=.*/kernel.string=⚡️ Laksanasoft Enterprise Kernel (Polly Edition) for Galaxy S10+ (beyond2lte) ⚡️/g' "$ANYKERNEL_DIR/anykernel.sh"
sed -i 's/device.name1=.*/device.name1=beyond2lte/g' "$ANYKERNEL_DIR/anykernel.sh"

chmod -R +x "$ANYKERNEL_DIR/tools"
cd "$ANYKERNEL_DIR"
zip -r9 "$ZIP_NAME" * -x .git\* README.md\*
mv "$ZIP_NAME" "$RELEASE_DIR/"
cd "$WORK_DIR"

echo "================================================================="
echo "⚡ SUCCESS! 100% Compatible Flashable Zip created:"
echo "   $RELEASE_DIR/$ZIP_NAME"
echo "   File Size: $(stat -c%s "$RELEASE_DIR/$ZIP_NAME" 2>/dev/null || stat -f%z "$RELEASE_DIR/$ZIP_NAME" 2>/dev/null) bytes"
echo "================================================================="
