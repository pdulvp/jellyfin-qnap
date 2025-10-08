#!/bin/bash
ARCH=$1
FFMPEG=$2
QPKG_VER=$3

sed -i "s/^QPKG_VER=.*$/QPKG_VER=\"$QPKG_VER\"/" output/qpkg.cfg
cd output; /usr/share/QDK/bin/qbuild ; cd ..
cd output; tar --exclude='./build' -cf build/jellyfin_$QPKG_VER.tar .; cd ..

if [ "$ARCH" != "amd64" ]; then 
  for filename in output/build/*.tar; do mv "$filename" "${filename%%.tar}_$ARCH.tar"; done;
  for filename in output/build/*.qpkg; do mv "$filename" "${filename%%.qpkg}_$ARCH.qpkg"; done;
  for filename in output/build/*.qpkg.md5; do mv "$filename" "${filename%%.qpkg.md5}_$ARCH.qpkg.md5"; done;
fi
if [ "$FFMPEG" != "ffmpeg7" ]; then 
  for filename in output/build/*.tar; do mv "$filename" "${filename%%.tar}_$FFMPEG.tar"; done;
  for filename in output/build/*.qpkg; do mv "$filename" "${filename%%.qpkg}_$FFMPEG.qpkg"; done;
  for filename in output/build/*.qpkg.md5; do mv "$filename" "${filename%%.qpkg.md5}_$FFMPEG.qpkg.md5"; done;
fi

mv -f output/build/* build
rm -rf output/build
