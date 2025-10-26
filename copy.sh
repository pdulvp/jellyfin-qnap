#!/bin/bash

cp -r /packaging/* /output/
mkdir -p /output/shared/jellyfin
cp -r /source/jellyfin/* /output/shared/jellyfin/
cp -r /source/usr/lib/jellyfin-ffmpeg /output/shared/
mkdir -p /output/shared/etc/OpenCL
cp -r /source/etc/OpenCL /output/shared/etc/
touch /output/shared/etc/OpenCL/.jellyfin
cp -r /source/usr/lib/x86_64-linux-gnu/* /output/shared/jellyfin/ 2>/dev/null || true
cp -r /source/usr/lib/aarch64-linux-gnu/* /output/shared/jellyfin/ 2>/dev/null || true
