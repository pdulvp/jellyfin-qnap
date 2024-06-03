#!/bin/bash

KEY=$1
if [ -d .cache/$KEY ]; then
  echo -e "\033[0;32mUnpack dependencies $1 from cache \033[0m"
  cp -r .cache/$KEY/lib .cache/$KEY/usr .tmp/lib
  exit 0
fi

echo "Unpack dependencies $1 from debs"
mkdir -p .tmp/lib/lib;
mkdir -p .tmp/lib/usr/lib;
cd .tmp/lib

for file in $(find . -type f -name "*.deb"); do
    echo "--- $file"
    ar x $file data.tar.xz
    tar xf data.tar.xz ./usr/lib/x86_64-linux-gnu/ 2>/dev/null
    tar xf data.tar.xz ./lib/x86_64-linux-gnu/ 2>/dev/null
    tar xf data.tar.xz ./usr/lib/aarch64-linux-gnu/ 2>/dev/null
    tar xf data.tar.xz ./lib/aarch64-linux-gnu/ 2>/dev/null
    tar xf data.tar.xz ./usr/lib/arm-linux-gnueabihf/ 2>/dev/null
    tar xf data.tar.xz ./lib/arm-linux-gnueabihf/ 2>/dev/null
    rm -f *.tar.xz
done

cd ../..
mkdir -p .cache/$KEY;
cp -r .tmp/lib/lib .tmp/lib/usr .cache/$KEY
exit 0
