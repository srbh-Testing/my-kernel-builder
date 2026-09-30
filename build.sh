#!/bin/bash

# Configuration
KERNEL_REPO="https://github.com/srbh-Testing/android_kernel_realme_nashc"
DEFCONFIG="nashc_defconfig"

echo "=== 1. Downloading Toolchain (AOSP Clang 12) ==="
git clone --depth=1 https://github.com/kdrag0n/proton-clang.git clang || git clone --depth=1 https://gitlab.com/panchajanya1999/azure-clang.git clang

echo "=== 2. Cloning Kernel Source ==="
git clone --depth=1 $KERNEL_REPO source

if [ ! -d "source" ]; then
    echo "=== ERROR: Failed to clone Kernel Source! ==="
    exit 1
fi

cd source

echo "=== 3. Setting Up Build Environment ==="
export PATH="$(pwd)/../clang/bin:$PATH"
export ARCH=arm64
export SUBARCH=arm64
export CC="ccache clang"
export CROSS_COMPILE=aarch64-linux-gnu-
export CROSS_COMPILE_ARM32=arm-linux-gnueabi-

# Create Output Directory
mkdir -p out

echo "=== 4. Generating Defconfig ==="
make O=out $DEFCONFIG

echo "=== 5. Starting Kernel Compilation ==="
make -j$(nproc --all) O=out

if [ -f "out/arch/arm64/boot/Image.gz-dtb" ] || [ -f "out/arch/arm64/boot/Image.gz" ]; then
    echo "=== SUCCESS: Kernel Build Complete! ==="
else
    echo "=== ERROR: Kernel Compilation Failed! ==="
    exit 1
fi
