#!/bin/bash
echo "JELLYFIN_VERSION=10.11.0-rc9" >> /.env
echo "JELLYFIN_FFMPEG=$(/usr/lib/jellyfin-ffmpeg/ffmpeg -version | cut -d' ' -f3 | head -1 | cut -d'-' -f1 | head -1)" >> /.env
