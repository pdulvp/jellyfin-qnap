#!/bin/bash
ARCH=$1
FFMPEG=$2

cd output; /usr/share/qdk2/QDK/bin/qbuild ; cd ..

if [ $ARCH != "amd64" ]; then 
  for filename in output/build/*.qpkg; do mv "$filename" "${filename%%.qpkg}_$ARCH.qpkg"; done;
  for filename in output/build/*.qpkg.md5; do mv "$filename" "${filename%%.qpkg.md5}_$ARCH.qpkg.md5"; done;
fi
if [ $FFMPEG != "ffmpeg6" ]; then 
  for filename in output/build/*.qpkg; do mv "$filename" "${filename%%.qpkg}_$FFMPEG.qpkg"; done;
  for filename in output/build/*.qpkg.md5; do mv "$filename" "${filename%%.qpkg.md5}_$FFMPEG.qpkg.md5"; done;
fi

mv -f output/build/* build
rm -rf output/build
