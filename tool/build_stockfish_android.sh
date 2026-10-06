#!/usr/bin/env bash
# Fallback only (docs/plan/05-engine.md §1): builds Stockfish for Android from
# the pinned source tag with the NDK, when an official release asset is
# missing. Normal builds use `dart run tool/fetch_engines.dart --platform
# android`. Run manually; not used by CI.
#
# Usage: ANDROID_NDK_HOME=/path/to/ndk tool/build_stockfish_android.sh
# Output: android/app/src/main/jniLibs/{arm64-v8a,armeabi-v7a}/libstockfish.so
set -euo pipefail

repo="$(cd "$(dirname "$0")/.." && pwd)"
tag="$(sed -n 's/.*"tag": "\(sf_[0-9.]*\)".*/\1/p' "$repo/engine/checksums.json" | head -1)"
: "${ANDROID_NDK_HOME:?set ANDROID_NDK_HOME to an Android NDK (r26 or newer)}"
toolchain="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin"
export PATH="$toolchain:$PATH"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
git clone --depth 1 --branch "$tag" https://github.com/official-stockfish/Stockfish.git "$work/sf"
cd "$work/sf/src"

build() {
  local arch="$1" abi="$2"
  make clean >/dev/null
  # The Makefile downloads the embedded NNUE networks for this tag.
  make -j"$(nproc)" build ARCH="$arch" COMP=ndk
  llvm-strip stockfish
  mkdir -p "$repo/android/app/src/main/jniLibs/$abi"
  cp stockfish "$repo/android/app/src/main/jniLibs/$abi/libstockfish.so"
  echo "Built $abi: $(sha256sum stockfish | cut -d' ' -f1)"
}

build armv8 arm64-v8a
build armv7-neon armeabi-v7a
