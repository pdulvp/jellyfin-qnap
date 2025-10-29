#!/bin/bash
echo "JELLYFIN_VERSION=10.11.1" >> /.env
VERSION=$(/usr/lib/jellyfin-ffmpeg/ffmpeg -version | cut -d' ' -f3 | head -1 | cut -d'-' -f1 | head -1)
echo "JELLYFIN_FFMPEG_VERSION=$VERSION" >> /.env
env >> /.env
