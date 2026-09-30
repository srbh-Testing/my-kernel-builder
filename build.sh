#!/bin/bash

# Configuration
KERNEL_REPO="https://github.com/srbh-Testing/android_kernel_realme_nashc"
DEFCONFIG="nashc_defconfig"

echo "=== 1. Installing System Dependencies ==="
sudo apt-get update -y
sudo apt-get install -y build-essential bc bison flex libssl-dev libncurses5-dev libncursesw5-dev \
                        git zip unzip ccache gcc-aarch64-linux-gnu gcc-arm-linux-gnueabi curl

echo "=== 2. Downloading Clang 20 Toolchain (r547379) ==="
mkdir -p clang
curl -s https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/main/clang-r547379.tar.gz | tar -xz -C clang || \
git clone --depth=1 https://gitlab.com/panchajanya1999/azure-clang.git clang

echo "=== 3. Cloning Kernel Source ==="
git clone --depth=1 $KERNEL_REPO source

if [ ! -d "source" ]; then
    echo "=== ERROR: Failed to clone Kernel Source! ==="
    exit 1
fi

cd source

echo "=== 4. Setting Up Environment ==="
export PATH="$(pwd)/../clang/bin:$PATH"
export ARCH=arm64
export SUBARCH=arm64
export CC=clang
export LLVM=1
export LLVM_IAS=1
export CROSS_COMPILE=aarch64-linux-gnu-
export CROSS_COMPILE_ARM32=arm-linux-gnueabi-

mkdir -p out

echo "=== 5. Generating Defconfig ==="
make O=out $DEFCONFIG

echo "=== 6. Compiling Kernel ==="
make -j$(nproc --all) O=out

if [ -f "out/arch/arm64/boot/Image.gz-dtb" ] || [ -f "out/arch/arm64/boot/Image.gz" ]; then
    echo "=== SUCCESS: Kernel Build Complete! ==="
else
    echo "=== ERROR: Kernel Compilation Failed! ==="
    exit 1
fi
