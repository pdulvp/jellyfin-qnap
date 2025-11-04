#!/bin/bash
JELLYFIN_VERSION=$(strings /jellyfin/jellyfin.dll -el | grep -A1 'ProductVersion' | tail -n1)
echo "JELLYFIN_VERSION=$JELLYFIN_VERSION" >> /.env

JELLYFIN_FFMPEG_VERSION=$(/usr/lib/jellyfin-ffmpeg/ffmpeg -version | cut -d' ' -f3 | head -1 | cut -d'-' -f1 | head -1)
echo "JELLYFIN_FFMPEG_VERSION=$JELLYFIN_FFMPEG_VERSION" >> /.env

env >> /.env
