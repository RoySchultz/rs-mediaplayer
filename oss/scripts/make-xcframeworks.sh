#!/bin/bash
# Turns the iOS builds of build-ffmpeg-ios.sh into one dynamic framework per library and an
# XCFramework per library in Vendor/iOS, with slices for devices and the simulator. The headers go
# to Vendor/iOS/include once, laid out as in the Mac prefix, so the C layer includes them unchanged.
set -euo pipefail

WORK="${RS_WORK:-$HOME/Library/Caches/RS-MediaPlayer}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/Vendor/iOS"
STAGE="$WORK/ios/frameworks"
MIN_IOS=17.0
LIBS="libavformat libavcodec libavutil libswscale libswresample libavfilter libdav1d libass libfreetype libfribidi libharfbuzz"

rm -rf "$STAGE" "$OUT"
mkdir -p "$STAGE" "$OUT"

for SDK in iphoneos iphonesimulator; do
  PREFIX="$WORK/ios/$SDK/prefix"
  case "$SDK" in
    iphoneos) PLATFORM=iPhoneOS ;;
    iphonesimulator) PLATFORM=iPhoneSimulator ;;
  esac
  for NAME in $LIBS; do
    SOURCE="$(readlink -f "$PREFIX/lib/$NAME.dylib")"
    FW="$STAGE/$SDK/$NAME.framework"
    mkdir -p "$FW"
    cp "$SOURCE" "$FW/$NAME"
    chmod u+w "$FW/$NAME"
    install_name_tool -id "@rpath/$NAME.framework/$NAME" "$FW/$NAME"
    # Dependencies on the other libraries point into their frameworks.
    for dep in $(otool -L "$FW/$NAME" | awk 'NR>1{print $1}' | grep -E '^(@rpath/|'"$PREFIX"'/lib/)lib' || true); do
      base="${dep##*/}"
      other="${base%%.*}"
      install_name_tool -change "$dep" "@rpath/$other.framework/$other" "$FW/$NAME"
    done
    cat > "$FW/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key><string>en</string>
    <key>CFBundleExecutable</key><string>$NAME</string>
    <key>CFBundleIdentifier</key><string>com.royschultz.rsmediaplayer.$(echo "$NAME" | tr -d '_')</string>
    <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
    <key>CFBundleName</key><string>$NAME</string>
    <key>CFBundlePackageType</key><string>FMWK</string>
    <key>CFBundleShortVersionString</key><string>1.0</string>
    <key>CFBundleVersion</key><string>1</string>
    <key>CFBundleSupportedPlatforms</key><array><string>$PLATFORM</string></array>
    <key>MinimumOSVersion</key><string>$MIN_IOS</string>
</dict>
</plist>
EOF
  done
done

for NAME in $LIBS; do
  xcodebuild -create-xcframework \
    -framework "$STAGE/iphoneos/$NAME.framework" \
    -framework "$STAGE/iphonesimulator/$NAME.framework" \
    -output "$OUT/$NAME.xcframework" > /dev/null
done

cp -R "$WORK/ios/iphoneos/prefix/include" "$OUT/include"

echo "--- check"
for NAME in $LIBS; do
  slices=$(plutil -p "$OUT/$NAME.xcframework/Info.plist" | grep -c LibraryIdentifier)
  echo "$NAME slices=$slices $(lipo -archs "$OUT/$NAME.xcframework/ios-arm64/$NAME.framework/$NAME")"
done
otool -L "$OUT/libavformat.xcframework/ios-arm64/libavformat.framework/libavformat" | head -12
