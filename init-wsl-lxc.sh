#!/bin/bash

sudo apt install lxc
sudo systemctl enable lxc-net

echo "[boot]" > /etc/wsl.conf
echo "systemd=true" >> /etc/wsl.conf

wsl --shutdown
wsl

sudo systemctl start lxc-net
