#!/bin/bash

mkdir -p .tmp-lib/lib;
mkdir -p .tmp-lib/usr/lib;
cd .tmp-lib
echo "Unpack dependencies"

for file in $(find . -type f -name "*.deb"); do
    echo "--- $file"
    ar x $file data.tar.xz
    tar xvf data.tar.xz ./usr/lib/x86_64-linux-gnu/
    tar xvf data.tar.xz ./lib/x86_64-linux-gnu/
    rm -f *.tar.xz
done

cd ..

if ! [ -d .tmp-lib/usr/lib/x86_64-linux-gnu ] && ! [ -d .tmp-lib/lib/x86_64-linux-gnu ]; then
    exit 1
fi

exit 0
