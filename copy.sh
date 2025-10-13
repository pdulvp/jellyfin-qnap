#!/bin/bash

rm -rf /mnt/jel/*
mkdir /mnt/jel/lib
mkdir /mnt/jel/usr
mkdir /mnt/jel/usr/lib
mkdir /mnt/jel/jellyfin
find /bin > /mnt/jel/all.txt
find /etc >> /mnt/jel/all.txt
find /usr >> /mnt/jel/all.txt
find /lib >> /mnt/jel/all.txt
find /var >> /mnt/jel/all.txt
cp -r /jellyfin /mnt/jel/jellyfin