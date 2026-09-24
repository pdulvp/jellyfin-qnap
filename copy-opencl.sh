#!/bin/bash

cp -r /packaging-opencl/* /output/

#opencl
mkdir -p /output/shared/lib
mkdir -p /output/shared/etc
cp -r /source/usr/lib/x86_64-linux-gnu/intel-opencl /output/shared/lib/
cp -r /source/etc/OpenCL /output/shared/etc/OpenCL
cp -r /source/usr/local/lib/* /output/shared/lib/ 2>/dev/null || true
rm /output/shared/lib/libopencl-clang.so 2>/dev/null || true
ln -sfnr /output/shared/lib/libopencl-clang.so.* /output/shared/lib/libopencl-clang.so 2>/dev/null || true
