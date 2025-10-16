#!/bin/bash

ARCH=$1
FFMPEG_VERSION=$2
FFMPEG_TYPE=$3
if [ $(ls -1 jellyfin-ffmpeg*_*-bookworm_*.deb | wc -l) -ne 1 ]; then
    echo -e "jellyfin-ffmpeg*_XYZ-bookworm_*.deb not found or several releases." 1>&2
    exit 1
fi

FFMPEG=$(ls -1 jellyfin-ffmpeg*_*-bookworm_*.deb)
echo $FFMPEG found.

FFMPEG_INFO=`ls -1 jellyfin-ffmpeg*.buildinfo`
echo $FFMPEG_INFO found.

case "$ARCH" in
    arm64) LD_LIB="ld-linux-aarch64.so.1" ;;
    *) LD_LIB="ld-linux-x86-64.so.2" ;;
esac

# Unzip jellyfin-ffmpeg.deb/data.tar.xz/./usr/lib/ into output/shared/
mkdir .tmp/ffmpeg
cd .tmp/ffmpeg
ar x ../../$FFMPEG data.tar.xz
tar xf data.tar.xz ./usr/lib/
cd ../..
rm -rf output/shared/jellyfin-ffmpeg
mv .tmp/ffmpeg/usr/lib/jellyfin-ffmpeg output/shared/
rm -rf .tmp/ffmpeg

FFMPEG_VERSION=$2
FFMPEG_TYPE=$3
if [ $(ls -1 jellyfin-ffmpeg*_*-bookworm_*.deb | wc -l) -ne 1 ]; then
    echo -e "jellyfin-ffmpeg*_XYZ-bookworm_*.deb not found or several releases." 1>&2
    exit 1
fi

FFMPEG=$(ls -1 jellyfin-ffmpeg*_*-bookworm_*.deb)
echo $FFMPEG found.

FFMPEG_INFO=`ls -1 jellyfin-ffmpeg*.buildinfo`
echo $FFMPEG_INFO found.

# Unzip jellyfin-ffmpeg.deb/data.tar.xz/./usr/lib/ into output/shared/
mkdir .tmp/ffmpeg
cd .tmp/ffmpeg
ar x ../../$FFMPEG data.tar.xz
tar xf data.tar.xz ./usr/lib/
cd ../..
rm -rf output/shared/jellyfin-ffmpeg
mv .tmp/ffmpeg/usr/lib/jellyfin-ffmpeg output/shared/
rm -rf .tmp/ffmpeg


./jellyfin-ffmpeg-steps.sh "$ARCH"

if ! ./prefetch-lib.sh "$FFMPEG_VERSION" "$FFMPEG_INFO" "$ARCH"; then
  exit $?
fi

exit 0