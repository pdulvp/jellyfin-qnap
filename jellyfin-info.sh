#!/bin/bash
JELLYFIN_VERSION=$(strings /jellyfin/jellyfin.dll -el | grep -A1 'ProductVersion' | tail -n1)
echo "JELLYFIN_VERSION=${JELLYFIN_VERSION%.0}" >> /.env

JELLYFIN_FFMPEG_VERSION=$(/usr/lib/jellyfin-ffmpeg/ffmpeg -version | cut -d' ' -f3 | head -1 | cut -d'-' -f1 | head -1)
echo "JELLYFIN_FFMPEG_VERSION=$JELLYFIN_FFMPEG_VERSION" >> /.env

OPENCL_LEGACY_VERSION=$(ls /usr/local/lib/libigc.so.1.* | head -n1 | cut -d'.' -f3- | cut -d'+' -f1)
OPENCL_VERSION=$(ls /usr/local/lib/libigc.so.2.* | head -n1 | cut -d'.' -f3- | cut -d'+' -f1)

echo "OPENCL_LEGACY_VERSION=$OPENCL_LEGACY_VERSION" >> /.env
echo "OPENCL_VERSION=$OPENCL_VERSION" >> /.env

env >> /.env
