#!/bin/bash
# Builds libass and the libraries it needs into the same prefix as FFmpeg.
# All four allow closed-source distribution when linked dynamically; none is GPL-only.
set -euo pipefail

WORK="${RS_WORK:-$HOME/Library/Caches/RS-MediaPlayer}"
PREFIX="$WORK/prefix"
SRC="$WORK/src"
MIN_MACOS=14.0
export MACOSX_DEPLOYMENT_TARGET=$MIN_MACOS
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"

FREETYPE=2.13.3
FRIBIDI=1.0.16
HARFBUZZ=11.2.1
LIBASS=0.17.4

fetch() { # url
  local name="${1##*/}"
  [ -f "$SRC/$name" ] || curl -fsSL -o "$SRC/$name" "$1"
  tar xf "$SRC/$name" -C "$SRC"
}

fetch "https://download.savannah.gnu.org/releases/freetype/freetype-$FREETYPE.tar.xz"
fetch "https://github.com/fribidi/fribidi/releases/download/v$FRIBIDI/fribidi-$FRIBIDI.tar.xz"
fetch "https://github.com/harfbuzz/harfbuzz/releases/download/$HARFBUZZ/harfbuzz-$HARFBUZZ.tar.xz"
fetch "https://github.com/libass/libass/releases/download/$LIBASS/libass-$LIBASS.tar.xz"

cd "$SRC/freetype-$FREETYPE"
rm -rf build
meson setup build --prefix="$PREFIX" --libdir=lib --buildtype=release -Ddefault_library=shared \
  -Dbrotli=disabled -Dbzip2=disabled -Dharfbuzz=disabled -Dpng=disabled -Dzlib=disabled
ninja -C build install

cd "$SRC/fribidi-$FRIBIDI"
rm -rf build
meson setup build --prefix="$PREFIX" --libdir=lib --buildtype=release -Ddefault_library=shared \
  -Ddocs=false -Dbin=false -Dtests=false
ninja -C build install

cd "$SRC/harfbuzz-$HARFBUZZ"
rm -rf build
meson setup build --prefix="$PREFIX" --libdir=lib --buildtype=release -Ddefault_library=shared \
  -Dglib=disabled -Dgobject=disabled -Dcairo=disabled -Dicu=disabled -Dfreetype=disabled \
  -Dcoretext=enabled -Dtests=disabled -Ddocs=disabled -Dutilities=disabled
ninja -C build install

cd "$SRC/libass-$LIBASS"
./configure --prefix="$PREFIX" --enable-shared --disable-static \
  --disable-fontconfig --disable-asm --enable-coretext --disable-libunibreak \
  CFLAGS="-O2 -mmacosx-version-min=$MIN_MACOS" LDFLAGS="-mmacosx-version-min=$MIN_MACOS"
make -j"$(sysctl -n hw.ncpu)"
make install

# Autotools writes absolute install names; the app loads everything through @rpath.
for lib in "$PREFIX"/lib/libass*.dylib "$PREFIX"/lib/libfreetype*.dylib "$PREFIX"/lib/libfribidi*.dylib "$PREFIX"/lib/libharfbuzz*.dylib; do
  [ -L "$lib" ] && continue
  name="${lib##*/}"
  short=$(otool -D "$lib" | tail -1 | sed 's#.*/##')
  chmod u+w "$lib"
  install_name_tool -id "@rpath/$short" "$lib"
  for dep in $(otool -L "$lib" | awk 'NR>1{print $1}' | grep "^$PREFIX/lib/" || true); do
    install_name_tool -change "$dep" "@rpath/${dep##*/}" "$lib"
  done
  codesign --force --sign - "$lib" 2>/dev/null
done
otool -L "$PREFIX"/lib/libass.dylib | head -12
