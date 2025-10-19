#!/bin/bash
ARCH=$1
FFMPEG=$2
QPKG_VER=$3
cd /output; tar --exclude='./build' -cf /output/build/jellyfin_$QPKG_VER.tar .; cd ..

if [ "$ARCH" != "amd64" ]; then 
  for filename in /output/build/*.tar; do mv "$filename" "${filename%%.tar}_$ARCH.tar"; done;
  for filename in /output/build/*.qpkg; do mv "$filename" "${filename%%.qpkg}_$ARCH.qpkg"; done;
  for filename in /output/build/*.qpkg.md5; do mv "$filename" "${filename%%.qpkg.md5}_$ARCH.qpkg.md5"; done;
fi
if [ "$FFMPEG" != "ffmpeg7" ]; then 
  for filename in /output/build/*.tar; do mv "$filename" "${filename%%.tar}_$FFMPEG.tar"; done;
  for filename in /output/build/*.qpkg; do mv "$filename" "${filename%%.qpkg}_$FFMPEG.qpkg"; done;
  for filename in /output/build/*.qpkg.md5; do mv "$filename" "${filename%%.qpkg.md5}_$FFMPEG.qpkg.md5"; done;
fi

mv -f /output/build/* /builds
rm -rf /output/build
