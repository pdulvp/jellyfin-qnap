#!/bin/bash

replace(){
  sed -i "s/\/sbin\/getcfg/\/qpkg\/getcfg\.sh/" "$1"
  sed -i "s/\/sbin\/setcfg/\/qpkg\/setcfg\.sh/" "$1"
}

rm -rf /tmp/cfg-*
rm -rf /jellyfin
mkdir -p /jellyfin
cp -r /source/* /jellyfin/

/qpkg/setcfg.sh jellyfin Install_Path /jellyfin/shared

replace /jellyfin/shared/jellyfin.sh
replace /jellyfin/shared/jellyfin/jellyfin
replace /jellyfin/shared/jellyfin-ffmpeg/ffprobe
replace /jellyfin/shared/jellyfin-ffmpeg/ffmpeg 
replace /jellyfin/shared/jellyfin-ffmpeg/vainfo
replace /jellyfin/shared/jellyfin-config.sh

cp /bin/echo /jellyfin/shared/jellyfin-ffmpeg/ffmpeg2
cp /bin/echo /jellyfin/shared/jellyfin-ffmpeg/ffprobe2
cp /bin/echo /jellyfin/shared/jellyfin-ffmpeg/vainfo2
cp /bin/echo /jellyfin/shared/jellyfin/jellyfin2
cp /bin/echo /usr/bin/ps
cp /bin/echo /usr/bin/kill
