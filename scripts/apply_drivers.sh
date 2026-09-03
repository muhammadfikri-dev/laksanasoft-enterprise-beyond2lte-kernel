#!/bin/bash
set -e

# ==============================================================================
# Laksanasoft Enterprise Kernel Patch & Configuration Injector
# ==============================================================================

KERNEL_DIR="$1"
CONFIG_FRAGMENT="$2"

if [ -z "$KERNEL_DIR" ] || [ ! -d "$KERNEL_DIR" ]; then
    echo "ERROR: Kernel directory not provided or does not exist: $KERNEL_DIR"
    exit 1
fi

DEFCONFIG="$KERNEL_DIR/arch/arm64/configs/exynos9820-beyond2lte_defconfig"

if [ ! -f "$DEFCONFIG" ]; then
    echo "ERROR: Target defconfig not found at $DEFCONFIG"
    exit 1
fi

echo "================================================================="
echo "⚡ Injecting Laksanasoft Enterprise Brand & Drivers..."
echo "================================================================="

# 1. Update LOCALVERSION
sed -i 's/CONFIG_LOCALVERSION=.*/CONFIG_LOCALVERSION="-⚡️Laksanasoft-Enterprise-v1.0⚡️+"/g' "$DEFCONFIG"
echo "[+] Updated CONFIG_LOCALVERSION to '-⚡️Laksanasoft-Enterprise-v1.0⚡️+'"

# 2. Append Driver Configurations
if [ -f "$CONFIG_FRAGMENT" ]; then
    echo "[+] Merging driver configurations from $CONFIG_FRAGMENT..."
    cat "$CONFIG_FRAGMENT" >> "$DEFCONFIG"
else
    echo "[-] Warning: Fragment file $CONFIG_FRAGMENT not found, skipping merge."
fi

# 3. Clean up any duplicate keys
echo "[+] Defconfig prepared successfully."
