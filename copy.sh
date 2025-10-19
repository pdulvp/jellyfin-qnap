#!/bin/bash
cp -r /packaging/* /output/
mkdir -p /output/shared/jellyfin
cp -r /source/jellyfin/* /output/shared/jellyfin/
mv /output/shared/jellyfin/jellyfin-web /output/shared/
cp -r /source/usr/lib/jellyfin-ffmpeg /output/shared/
cp -r /source/usr/lib/x86_64-linux-gnu/* /output/shared/jellyfin/ 2>/dev/null || true
cp -r /source/usr/lib/aarch64-linux-gnu/* /output/shared/jellyfin/ 2>/dev/null || true

mkdir -p /output/shared/bin
mv /output/shared/jellyfin/* /output/shared/bin/
mv /output/shared/bin /output/shared/jellyfin/
