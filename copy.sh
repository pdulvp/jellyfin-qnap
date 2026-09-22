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

mkdir -p /output/shared/fonts/etc
mkdir -p /output/shared/fonts/usr/bin
mkdir -p /output/shared/fonts/usr/share
cp -r /source/etc/fonts /output/shared/fonts/etc/fonts 2>/dev/null || true
cp -r /source/usr/bin/fc-* /output/shared/fonts/usr/bin 2>/dev/null || true
cp -r /source/usr/share/fonts /output/shared/fonts/usr/share/fonts 2>/dev/null || true
cp -r /source/usr/share/fontconfig /output/shared/fonts/usr/share/fontconfig 2>/dev/null || true

for file in /output/shared/fonts/etc/fonts/conf.d/*.conf; do
  newpath=$(readlink "$file")
  if [[ $newpath == /usr/share/fontconfig/* ]]; then
    ln -sfnr "/output/shared/fonts/$newpath" "$file"
  fi
done
