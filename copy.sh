#!/bin/bash

rm -rf /mnt/jel/*
mkdir /mnt/jel/lib
mkdir /mnt/jel/usr
mkdir /mnt/jel/usr/lib
mkdir /mnt/jel/jellyfin
ls /
find /bin > /mnt/jel/all.txt
find /etc >> /mnt/jel/all.txt
find /usr >> /mnt/jel/all.txt
find /lib >> /mnt/jel/all.txt
find /var >> /mnt/jel/all.txt


cd /mnt/shared

  rm -rf .tmp
  rm -rf output
  mkdir output
  cp -rf packaging/* output

cp -r /jellyfin /mnt/shared/output/shared/
mv /mnt/shared/output/shared/jellyfin/jellyfin-web /mnt/shared/output/shared/
cp -r /usr/lib/x86_64-linux-gnu/* /mnt/shared/output/shared/jellyfin/
cp -r /usr/lib/jellyfin-ffmpeg /mnt/shared/output/shared/

mkdir -p /mnt/shared/output/shared/bin
mv /mnt/shared/output/shared/jellyfin/* /mnt/shared/output/shared/bin/
mv /mnt/shared/output/shared/bin /mnt/shared/output/shared/jellyfin/