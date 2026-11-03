# RS-MediaPlayer: open-source components

RS-MediaPlayer for macOS and iOS links the libraries below dynamically. This folder gives what the
LGPL asks for: the exact versions, where their source comes from, how they were built, and the
licence texts, so anyone can rebuild them and relink the app.

| Library | Version | Licence | Source |
|---|---|---|---|
| FFmpeg | 8.1.1 | GNU LGPL 2.1 or later | https://ffmpeg.org/releases/ffmpeg-8.1.1.tar.xz |
| dav1d | 1.5.3 | BSD 2-Clause | https://code.videolan.org/videolan/dav1d/-/archive/1.5.3/dav1d-1.5.3.tar.xz |
| libass | 0.17.4 | ISC | https://github.com/libass/libass/releases/download/0.17.4/libass-0.17.4.tar.xz |
| FreeType | 2.13.3 | FreeType License | https://download.savannah.gnu.org/releases/freetype/freetype-2.13.3.tar.xz |
| FriBidi | 1.0.16 | GNU LGPL 2.1 or later | https://github.com/fribidi/fribidi/releases/download/v1.0.16/fribidi-1.0.16.tar.xz |
| HarfBuzz | 11.2.1 | MIT | https://github.com/harfbuzz/harfbuzz/releases/download/11.2.1/harfbuzz-11.2.1.tar.xz |
| GRDB.swift | 7 | MIT | https://github.com/groue/GRDB.swift |

FFmpeg is configured without GPL or nonfree parts (`CONFIG_GPL 0`, `CONFIG_NONFREE 0`,
`CONFIG_VERSION3 0`). No source file of these libraries was changed.

## Building

- macOS: `scripts/build-ffmpeg.sh`, then `scripts/build-libass.sh`.
- iOS: `scripts/build-ffmpeg-ios.sh` builds for devices and the simulator, then
  `scripts/make-xcframeworks.sh` turns each library into a dynamic framework.

The scripts expect the source archives above in `~/Library/Caches/RS-MediaPlayer/src`.

## Relinking

On macOS the libraries are `.dylib` files in `RS-MediaPlayer.app/Contents/Frameworks`; on iOS they
are frameworks in the app's `Frameworks` folder. Both are loaded through `@rpath`, so a rebuilt
library with the same install name takes the place of the shipped one.

The licence texts are in `licenses/`.
