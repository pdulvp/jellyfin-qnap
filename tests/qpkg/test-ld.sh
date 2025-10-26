#!/bin/bash

source /qpkg/asserts.sh

source /jellyfin/shared/jellyfin-config.sh
load_config

sub_test "Test overridden default app are properly launching the default ones"

START=$(/jellyfin/shared/jellyfin-ffmpeg/vainfo "ok")
log_assertion $(equals "$START" "ok") "vainfo2 must be called"

START=$(/jellyfin/shared/jellyfin-ffmpeg/ffprobe "ok")
log_assertion $(equals "$START" "ok") "ffprobe2 must be called"

START=$(/jellyfin/shared/jellyfin-ffmpeg/ffmpeg "ok")
log_assertion $(equals "$START" "ok") "ffmpeg2 must be called"

START=$(/jellyfin/shared/jellyfin/jellyfin "ok")
log_assertion $(equals "$START" "ok") "jellyfin2 must be called"


sub_test "Test preload variable properly added in ld"

mv /jellyfin/shared/jellyfin/ld-linux-x86-64.so.2 /jellyfin/shared/jellyfin/ld-linux-x86-64.so.bak
cp /bin/echo /jellyfin/shared/jellyfin/ld-linux-x86-64.so.2

START=$(/jellyfin/shared/jellyfin-ffmpeg/vainfo)
log_assertion $(contains "$START" "jellyfin/libjemalloc") "preload must be set on vainfo"

START=$(/jellyfin/shared/jellyfin-ffmpeg/ffprobe)
log_assertion $(contains "$START" "jellyfin/libjemalloc") "preload must be set on ffprobe"

START=$(/jellyfin/shared/jellyfin-ffmpeg/ffmpeg)
log_assertion $(contains "$START" "jellyfin/libjemalloc") "preload must be set on ffmpeg"

START=$(/jellyfin/shared/jellyfin/jellyfin)
log_assertion $(contains "$START" "jellyfin/libjemalloc") "preload must be set on jellyfin"

mv /jellyfin/shared/jellyfin/ld-linux-x86-64.so.bak /jellyfin/shared/jellyfin/ld-linux-x86-64.so.2
