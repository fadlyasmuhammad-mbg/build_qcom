#!/usr/bin/env bash

git clone --depth=1 \
  -b qcom_sm6115-rt \
  https://github.com/bengal-upstream/kernel_xiaomi_sm8250 \
  kernel
  
# setup clang
#bash <(wget -qO- https://raw.githubusercontent.com/greenforce-project/greenforce_clang/refs/heads/main/get_clang.sh)
#export PATH="$(pwd)/greenforce-clang/bin:$PATH"
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
