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
mkdir -p .tmp/lib/usr/local/lib;
cd .tmp/lib

for file in $(find . -type f -name "*.deb"); do
    echo "--- $file"

    ar x $file data.tar.xz 2>/dev/null
    ar x $file data.tar.gz 2>/dev/null
    ar x $file data.tar.zst 2>/dev/null
    #tar xf data.tar.* --wildcards "*/lib/*.so*" 2>/dev/null
    tar xf data.tar.* --wildcards "*" 2>/dev/null
    
   # for path in ./usr/lib/x86_64-linux-gnu/ ./lib/x86_64-linux-gnu/ ./usr/lib/aarch64-linux-gnu/ ./lib/aarch64-linux-gnu/ ./usr/lib/arm-linux-gnueabihf/ ./lib/arm-linux-gnueabihf/; do
      
   # done

   # if [[ "$file" = *"intel-igc"* ]]; then
    #  tar xf data.tar.*  --wildcards "*/lib/*" 2>/dev/null
   # fi

    rm -f *.tar.*
done

cd ../..
mkdir -p .cache/$KEY;
cp -r .tmp/lib/lib .tmp/lib/usr .cache/$KEY
exit 0
