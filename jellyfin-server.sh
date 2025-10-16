#!/bin/bash
ARCH=$1
SERVER_VERSION=$2
if [ `ls -1 jellyfin-server_*_*.deb | wc -l` -ne 1 ]; then
    echo "jellyfin-server_XYZ_*.deb not found or several releases."
    exit
fi

SERVER=`ls -1 jellyfin-server_*_*.deb`
echo $SERVER found.

SERVER_INFO=`ls -1 jellyfin_*.buildinfo`
echo $SERVER_INFO found.

#Unzip jellyfin-server.deb/data.tar.xz/./usr/lib/ into output/shared/
mkdir -p .tmp/server;
cd .tmp/server

ar x ../../$SERVER data.tar.xz
tar xf data.tar.xz ./usr/lib/
cd ../..
rm -rf output/shared/jellyfin
mv .tmp/server/usr/lib/jellyfin output/shared/
rm -rf .tmp/server;

./jellyfin-server-steps.sh "$ARCH"

if ! ./prefetch-lib.sh "$SERVER_VERSION" "$SERVER_INFO" "$ARCH"; then
    exit $?
fi

exit 0