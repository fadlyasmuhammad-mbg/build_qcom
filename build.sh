#!/usr/bin/env bash

git clone --depth=1 \
  -b qcom_sm8250 \
  https://github.com/bengal-upstream/kernel_xiaomi_sm8250.git \
  kernel

clang_dir="$(pwd)/greenforce-clang"
clang_url="https://github.com/greenforce-project/greenforce_clang/releases/download/20260601/gf-clang-10.0.1-20260601.tar.gz"

mkdir -p "${clang_dir}"

wget -O - "${clang_url}" | tar -xz -C "${clang_dir}"

export PATH="${clang_dir}/bin:$PATH"
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
