#!/usr/bin/env bash

git clone --depth=1 \
  -b qcom_sm8250 \
  https://github.com/bengal-upstream/kernel_xiaomi_sm8250 \
  kernel
  
# setup clang
clang_dir="$(pwd)/clang"

mkdir -p "$clang_dir"

clang_url="https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/tags/android-12.0.0_r12/clang-r416183b1.tar.gz"

echo "Downloading AOSP Clang..."

curl -L "$clang_url" | tar -xz -C "$clang_dir"

# detect folder hasil extract
export CLANG_DIR=$(find "$clang_dir" -maxdepth 1 -type d -name "clang*" | head -n1)

export PATH="$CLANG_DIR/bin:$PATH"
export BUILD_ARGS="AS=as CC=clang CROSS_COMPILE=aarch64-linux-gnu-"

echo "=== Compiler ==="
clang --version

cd kernel

make -j"$(nproc --all)" \
     -l"$(nproc --all)" \
     -C $(pwd) \
     O=out \
     ARCH=arm64 \
     ${BUILD_ARGS} \
     vendor/bengal-perf_defconfig

scripts/config \
    --file out/.config \
    -d BUILD_ARM64_DT_OVERLAY

make -j"$(nproc --all)" \
     -l"$(nproc --all)" \
     -C $(pwd) \
     O=out \
     ARCH=arm64 \
     ${BUILD_ARGS} \
     olddefconfig

make -j"$(nproc --all)" \
     -l"$(nproc --all)" \
     -C $(pwd) \
     O=out \
     ARCH=arm64 \
     ${BUILD_ARGS} \
     2>&1 | tee build.log
