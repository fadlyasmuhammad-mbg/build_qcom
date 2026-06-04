#!/usr/bin/env bash

git clone --depth=1 \
  -b qcom_sm8250 \
  https://github.com/bengal-upstream/kernel_xiaomi_sm8250.git \
  kernel
  
git clone --depth=1 \
  https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86 \
  clang
  
CLANG_DIR=$(find clang -maxdepth 1 -type d -name "clang-r*" | sort -V | tail -n1)

export PATH="$(pwd)/$CLANG_DIR/bin:$PATH"

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
