#!/bin/bash
echo "Cloning Kernel Source..."
git clone --depth=1 https://github.com/srbh-Testing/android_kernel_realme_nashc -b inline-rom source

if [ -d "source" ]; then
    echo "Kernel Source Successfully Cloned!"
    cd source
    # Yahan se compilation command chalegi
else
    echo "Failed to clone kernel source!"
    exit 1
fi
