#!/usr/bin/env bash

git clone --depth=1 \
  -b qcom_sm8250 \
  https://github.com/bengal-upstream/kernel_xiaomi_sm8250 \
  kernel
  
# setup clang
clang_dir="$(pwd)/clang"

mkdir -p "$clang_dir"

clang_url="https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/9c58a6fe9b3a84143a3ebd54f9e59328be769f5a/clang-r596125.tar.gz"

echo "Downloading AOSP Clang..."

curl -L "$clang_url" | tar -xz -C "$clang_dir"

# detect folder hasil extract
export CLANG_DIR=$(find "$clang_dir" -maxdepth 1 -type d -name "clang*" | head -n1)

export PATH="$CLANG_DIR/bin:$PATH"
export BUILD_ARGS="LLVM=1 LLVM_IAS=1"

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

make -j"$(nproc --all)" \
     -l"$(nproc --all)" \
     -C $(pwd) \
     O=out \
     ARCH=arm64 \
     ${BUILD_ARGS} \
     2>&1 | tee build.log
