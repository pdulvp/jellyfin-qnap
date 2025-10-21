#!/bin/bash

source /qpkg/asserts.sh

START=$(/jellyfin/shared/jellyfin-ffmpeg/vainfo "ok")
log_assertion $(equals "$START" "ok") "vainfo2 must be called"

START=$(/jellyfin/shared/jellyfin-ffmpeg/ffprobe "ok")
log_assertion $(equals "$START" "ok") "ffprobe2 must be called"

START=$(/jellyfin/shared/jellyfin-ffmpeg/ffmpeg "ok")
log_assertion $(equals "$START" "ok") "ffmpeg2 must be called"

START=$(/jellyfin/shared/jellyfin/jellyfin "ok")
log_assertion $(equals "$START" "ok") "jellyfin2 must be called"
