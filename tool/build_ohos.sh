#!/bin/bash
set -euo pipefail

# Build isar native library for OpenHarmony OS (ohos)
# Requires: OHOS_NDK_HOME env var pointing to the OpenHarmony SDK root
#   e.g. /path/to/openharmony/native
#
# Usage:
#   bash tool/build_ohos.sh            # default: aarch64 (arm64)
#   bash tool/build_ohos.sh arm64      # explicit arm64
#   bash tool/build_ohos.sh x86_64     # x86_64 (for simulator/testing)

OHOS_NDK="${OHOS_NDK_HOME:?Set OHOS_NDK_HOME to the OpenHarmony native SDK path}"
LLVM_DIR="$OHOS_NDK/llvm"
SYSROOT="$OHOS_NDK/sysroot"

if [ ! -d "$LLVM_DIR" ]; then
    echo "Error: LLVM toolchain not found at $LLVM_DIR"
    exit 1
fi

export PATH="$LLVM_DIR/bin:$PATH"

ARCH="${1:-arm64}"

setup_aarch64() {
    local target="aarch64-unknown-linux-ohos"
    rustup target add "$target"

    export CC_aarch64_unknown_linux_ohos="$LLVM_DIR/bin/aarch64-unknown-linux-ohos-clang"
    export AR_aarch64_unknown_linux_ohos="$LLVM_DIR/bin/llvm-ar"
    export CARGO_TARGET_AARCH64_UNKNOWN_LINUX_OHOS_LINKER="$LLVM_DIR/bin/aarch64-unknown-linux-ohos-clang"
    export CARGO_TARGET_AARCH64_UNKNOWN_LINUX_OHOS_AR="$LLVM_DIR/bin/llvm-ar"

    echo "Building for aarch64-unknown-linux-ohos..."
    cargo build --target "$target" --features sqlcipher-vendored --release
    mv "target/$target/release/libisar.so" "libisar_ohos_arm64-v8a.so"
}

setup_x86_64() {
    local target="x86_64-unknown-linux-ohos"
    rustup target add "$target"

    export CC_x86_64_unknown_linux_ohos="$LLVM_DIR/bin/x86_64-unknown-linux-ohos-clang"
    export AR_x86_64_unknown_linux_ohos="$LLVM_DIR/bin/llvm-ar"
    export CARGO_TARGET_X86_64_UNKNOWN_LINUX_OHOS_LINKER="$LLVM_DIR/bin/x86_64-unknown-linux-ohos-clang"
    export CARGO_TARGET_X86_64_UNKNOWN_LINUX_OHOS_AR="$LLVM_DIR/bin/llvm-ar"

    echo "Building for x86_64-unknown-linux-ohos..."
    cargo build --target "$target" --features sqlcipher-vendored --release
    mv "target/$target/release/libisar.so" "libisar_ohos_x86_64.so"
}

case "$ARCH" in
    arm64)  setup_aarch64 ;;
    x86_64) setup_x86_64 ;;
    *)      echo "Unknown arch: $ARCH (supported: arm64, x86_64)"; exit 1 ;;
esac

echo "Build complete."
