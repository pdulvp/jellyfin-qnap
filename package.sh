#!/bin/bash

cd output; /usr/share/qdk2/QDK/bin/qbuild ; cd ..
mv -f output/build/* build
rm -rf output/build
