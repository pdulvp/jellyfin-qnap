#!/bin/bash
ARCH=$1

cd output; /usr/share/qdk2/QDK/bin/qbuild ; cd ..

if [ $ARCH != "amd64" ]; then 
  for filename in output/build/*.qpkg; do mv "$filename" "${filename%%.qpkg}_$ARCH.qpkg"; done;
fi

mv -f output/build/* build
rm -rf output/build
