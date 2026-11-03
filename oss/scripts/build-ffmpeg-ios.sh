#!/bin/bash
# Builds the LGPL-only FFmpeg, dav1d and libass with its libraries for iOS: one prefix per SDK
# (iphoneos and iphonesimulator, arm64 only). Same versions and options as build-ffmpeg.sh and
# build-libass.sh for the Mac. scripts/make-xcframeworks.sh turns the result into frameworks.
# Output goes outside Dropbox because FFmpeg's configure rejects paths with spaces.
set -euo pipefail

WORK="${RS_WORK:-$HOME/Library/Caches/RS-MediaPlayer}"
MIN_IOS=17.0
DAV1D=1.5.3
FFMPEG=8.1.1
FREETYPE=2.13.3
FRIBIDI=1.0.16
HARFBUZZ=11.2.1
LIBASS=0.17.4
JOBS="$(sysctl -n hw.ncpu)"
SDKS="${*:-iphoneos iphonesimulator}"

for SDK in $SDKS; do
  case "$SDK" in
    iphoneos) TARGET="arm64-apple-ios$MIN_IOS"; SUBSYSTEM=ios ;;
    iphonesimulator) TARGET="arm64-apple-ios$MIN_IOS-simulator"; SUBSYSTEM=ios-simulator ;;
    *) echo "unknown SDK $SDK"; exit 1 ;;
  esac
  SYSROOT="$(xcrun --sdk "$SDK" --show-sdk-path)"
  BASE="$WORK/ios/$SDK"
  PREFIX="$BASE/prefix"
  SRC="$BASE/src"
  rm -rf "$BASE"
  mkdir -p "$SRC" "$PREFIX/lib/pkgconfig"
  # Fresh sources per SDK: FFmpeg can't build out of a tree that was configured for the Mac.
  for archive in dav1d-$DAV1D ffmpeg-$FFMPEG freetype-$FREETYPE fribidi-$FRIBIDI harfbuzz-$HARFBUZZ libass-$LIBASS; do
    tar xf "$WORK/src/$archive.tar.xz" -C "$SRC"
  done

  export PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig"
  unset PKG_CONFIG_PATH MACOSX_DEPLOYMENT_TARGET
  CC="$(xcrun --sdk "$SDK" -f clang)"
  CXX="$(xcrun --sdk "$SDK" -f clang++)"
  FLAGS="-target $TARGET -isysroot $SYSROOT"

  cat > "$BASE/cross.txt" <<EOF
[binaries]
c = ['$CC', '-target', '$TARGET', '-isysroot', '$SYSROOT']
cpp = ['$CXX', '-target', '$TARGET', '-isysroot', '$SYSROOT']
objc = ['$CC', '-target', '$TARGET', '-isysroot', '$SYSROOT']
ar = '$(xcrun --sdk "$SDK" -f ar)'
strip = '$(xcrun --sdk "$SDK" -f strip)'
pkg-config = 'pkg-config'

[host_machine]
system = 'darwin'
subsystem = '$SUBSYSTEM'
cpu_family = 'aarch64'
cpu = 'arm64'
endian = 'little'
EOF
  MESON=(meson setup build --cross-file "$BASE/cross.txt" --prefix="$PREFIX" --libdir=lib --buildtype=release -Ddefault_library=shared)

  cd "$SRC/dav1d-$DAV1D"
  "${MESON[@]}" -Denable_tools=false -Denable_tests=false
  ninja -C build install

  cd "$SRC/freetype-$FREETYPE"
  "${MESON[@]}" -Dbrotli=disabled -Dbzip2=disabled -Dharfbuzz=disabled -Dpng=disabled -Dzlib=disabled
  ninja -C build install

  cd "$SRC/fribidi-$FRIBIDI"
  "${MESON[@]}" -Ddocs=false -Dbin=false -Dtests=false
  ninja -C build install

  cd "$SRC/harfbuzz-$HARFBUZZ"
  "${MESON[@]}" -Dglib=disabled -Dgobject=disabled -Dcairo=disabled -Dicu=disabled -Dfreetype=disabled \
    -Dcoretext=enabled -Dtests=disabled -Ddocs=disabled -Dutilities=disabled
  ninja -C build install

  cd "$SRC/libass-$LIBASS"
  ./configure --prefix="$PREFIX" --host=aarch64-apple-darwin --enable-shared --disable-static \
    --disable-fontconfig --disable-asm --enable-coretext --disable-libunibreak \
    CC="$CC" CFLAGS="-O2 $FLAGS" LDFLAGS="$FLAGS"
  make -j"$JOBS"
  make install

  # libxml2 and zlib come from the iOS SDK.
  cat > "$PREFIX/lib/pkgconfig/libxml-2.0.pc" <<EOF
Name: libxml-2.0
Description: libxml2 from the iOS SDK
Version: 2.9.13
Libs: -lxml2
Cflags: -I$SYSROOT/usr/include/libxml2
EOF

  cd "$SRC/ffmpeg-$FFMPEG"
  ./configure \
    --prefix="$PREFIX" \
    --install-name-dir='@rpath' \
    --enable-cross-compile --target-os=darwin --arch=aarch64 \
    --cc="$CC" --cxx="$CXX" --sysroot="$SYSROOT" \
    --extra-cflags="-target $TARGET" --extra-ldflags="-target $TARGET" \
    --enable-shared --disable-static \
    --disable-programs --disable-doc --disable-debug \
    --disable-indevs --disable-outdevs \
    --disable-autodetect \
    --enable-videotoolbox --enable-audiotoolbox --enable-securetransport \
    --enable-zlib --enable-libxml2 --enable-libdav1d
  make -j"$JOBS"
  make install

  echo "--- $SDK license"
  grep -E 'CONFIG_GPL|CONFIG_NONFREE|CONFIG_VERSION3' config.h
  grep -E 'CONFIG_(H264|HEVC)_VIDEOTOOLBOX_HWACCEL ' config_components.h
done
