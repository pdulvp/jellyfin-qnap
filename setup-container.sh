#!/bin/bash

QDK_VERSION="2.4.0"
apt update && apt install -y wget unzip gnupg ca-certificates jq

wget -O qdk.zip https://github.com/qnap-dev/QDK/archive/refs/tags/v$QDK_VERSION.zip
unzip -d /tmp qdk.zip

cd "/tmp/QDK-$QDK_VERSION"
chmod 755 ./InstallToUbuntu.sh
./InstallToUbuntu.sh install;
