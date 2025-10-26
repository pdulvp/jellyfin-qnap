#!/bin/bash

source /qpkg/asserts.sh

source /jellyfin/shared/jellyfin-config.sh
load_config

cp /bin/env /jellyfin/shared/jellyfin-ffmpeg/ffmpeg2
cp /bin/env /jellyfin/shared/jellyfin-ffmpeg/ffprobe2
cp /bin/env /jellyfin/shared/jellyfin-ffmpeg/vainfo2
cp /bin/env /jellyfin/shared/jellyfin/jellyfin2

START=$(/jellyfin/shared/jellyfin/jellyfin | grep XDG_CACHE_HOME)
log_assertion $(contains "$START" "XDG_CACHE_HOME") "XDG_CACHE_HOME must be set on jellyfin"

START=$(/jellyfin/shared/jellyfin/jellyfin | grep MALLOC_TRIM_THRESHOLD_)
log_assertion $(contains "$START" "MALLOC_TRIM_THRESHOLD") "MALLOC_TRIM_THRESHOLD_ must be set on jellyfin"

cp /bin/echo /jellyfin/shared/jellyfin-ffmpeg/ffmpeg2
cp /bin/echo /jellyfin/shared/jellyfin-ffmpeg/ffprobe2
cp /bin/echo /jellyfin/shared/jellyfin-ffmpeg/vainfo2
cp /bin/echo /jellyfin/shared/jellyfin/jellyfin2
