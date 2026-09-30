#!/bin/bash

KERNEL_REPO="https://github.com/srbh-Testing/android_kernel_realme_nashc"
DEFCONFIG="nashc_defconfig"

echo "=== 1. Installing System Dependencies ==="
sudo apt-get update -y
sudo apt-get install -y build-essential bc bison flex libssl-dev libncurses5-dev libncursesw5-dev \
                        git zip unzip ccache gcc-aarch64-linux-gnu gcc-arm-linux-gnueabi curl

echo "=== 2. Downloading ZyC Clang 20 ==="
git clone --depth=1 https://gitlab.com/zyc-project/zyc-clang.git clang

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

# Force Host to use system GCC to avoid linker mismatches
export KBUILD_COMPILER_STRING="$(clang --version | head -n 1)"

mkdir -p out

echo "=== 5. Generating Defconfig ==="
make O=out ARCH=arm64 CC=clang HOSTCC=gcc HOSTCXX=g++ CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- $DEFCONFIG

echo "=== 6. Compiling Kernel ==="
make -j$(nproc --all) O=out ARCH=arm64 CC=clang HOSTCC=gcc HOSTCXX=g++ CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi-

if [ -f "out/arch/arm64/boot/Image.gz-dtb" ] || [ -f "out/arch/arm64/boot/Image.gz" ]; then
    echo "=== SUCCESS: Kernel Build Complete! ==="
else
    echo "=== ERROR: Kernel Compilation Failed! ==="
    exit 1
fi
