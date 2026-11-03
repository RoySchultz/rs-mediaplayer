#!/bin/bash
# Builds the LGPL-only FFmpeg + dav1d used by the phase 0 proof.
# Output goes outside Dropbox because FFmpeg's configure rejects paths with spaces.
set -euo pipefail

WORK="${RS_WORK:-$HOME/Library/Caches/RS-MediaPlayer}"
PREFIX="$WORK/prefix"
MIN_MACOS=14.0
export MACOSX_DEPLOYMENT_TARGET=$MIN_MACOS
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"

cd "$WORK/src/dav1d-1.5.3"
rm -rf build
meson setup build \
  --prefix="$PREFIX" --libdir=lib --buildtype=release \
  -Ddefault_library=shared -Denable_tools=false -Denable_tests=false
ninja -C build install
install_name_tool -id "@rpath/libdav1d.7.dylib" "$PREFIX/lib/libdav1d.7.dylib"

if ! pkg-config --exists libxml-2.0; then
  SDK="$(xcrun --show-sdk-path)"
  cat > "$PREFIX/lib/pkgconfig/libxml-2.0.pc" <<EOF
Name: libxml-2.0
Description: libxml2 from the macOS SDK
Version: 2.9.13
Libs: -lxml2
Cflags: -I$SDK/usr/include/libxml2
EOF
fi

cd "$WORK/src/ffmpeg-8.1.1"
./configure \
  --prefix="$PREFIX" \
  --install-name-dir='@rpath' \
  --extra-cflags="-mmacosx-version-min=$MIN_MACOS" \
  --extra-ldflags="-mmacosx-version-min=$MIN_MACOS" \
  --enable-shared --disable-static \
  --disable-programs --disable-doc --disable-debug \
  --disable-indevs --disable-outdevs \
  --disable-autodetect \
  --enable-videotoolbox --enable-audiotoolbox --enable-securetransport \
  --enable-zlib --enable-libxml2 --enable-libdav1d
make -j"$(sysctl -n hw.ncpu)"
make install

echo "--- license and hwaccels"
grep -E 'CONFIG_GPL|CONFIG_NONFREE|CONFIG_LGPLV3|CONFIG_VERSION3' config.h
grep -E 'CONFIG_(H264|HEVC|AV1|VP9|MPEG2|PRORES)_VIDEOTOOLBOX_HWACCEL ' config_components.h
ls -la "$PREFIX/lib"/*.dylib
