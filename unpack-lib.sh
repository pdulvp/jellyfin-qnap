#!/bin/bash

mkdir .tmp-lib;
mkdir -p "$1"
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

mv .tmp-lib/usr/lib/x86_64-linux-gnu/* "$1"
mv .tmp-lib/lib/x86_64-linux-gnu/* "$1"
exit 0
