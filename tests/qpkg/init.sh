#!/bin/bash

replace(){
  sed -i "s/\/sbin\/getcfg/\/qpkg\/getcfg\.sh/" "$1"
  sed -i "s/\/sbin\/setcfg/\/qpkg\/setcfg\.sh/" "$1"
}

rm -rf /tmp/cfg-*
rm -rf /jellyfin
mkdir -p /jellyfin
cp -r /source/* /jellyfin/

rm -rf /jellyfin-opencl
mkdir -p /jellyfin-opencl
cp -r /source-opencl/* /jellyfin-opencl/

/qpkg/setcfg.sh jellyfin Install_Path /jellyfin/shared
/qpkg/setcfg.sh jellyfin-opencl Install_Path /jellyfin-opencl/shared

replace /jellyfin/shared/jellyfin.sh
replace /jellyfin/shared/jellyfin/jellyfin
replace /jellyfin/shared/jellyfin-ffmpeg/ffprobe
replace /jellyfin/shared/jellyfin-ffmpeg/ffmpeg 
replace /jellyfin/shared/jellyfin-ffmpeg/vainfo
replace /jellyfin/shared/fonts/usr/bin/fc-list
replace /jellyfin/shared/jellyfin-config.sh
replace /jellyfin-opencl/shared/jellyfin-opencl.sh

cp /bin/echo /jellyfin/shared/jellyfin-ffmpeg/ffmpeg2
cp /bin/echo /jellyfin/shared/jellyfin-ffmpeg/ffprobe2
cp /bin/echo /jellyfin/shared/jellyfin-ffmpeg/vainfo2
cp /bin/echo /jellyfin/shared/jellyfin/jellyfin2
cp /bin/echo /jellyfin/shared/fonts/usr/bin/fc-list2
cp /bin/echo /usr/bin/ps
cp /bin/echo /usr/bin/kill
