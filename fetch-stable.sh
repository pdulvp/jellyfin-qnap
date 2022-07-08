#!/bin/bash

SERVER_VERSION=`wget https://repo.jellyfin.org/releases/server/debian/stable/server/ -q -O- | grep -o -P "([a-z0-9\-\.~]+)(?=.dsc)" | head -n 1`
echo "SERVER_VERSION=$SERVER_VERSION"
WEB_VERSION=`wget https://repo.jellyfin.org/releases/server/debian/stable/web/ -q -O- | grep -o -P "([a-z0-9\-\.~]+)(?=.dsc)" | head -n 1`
echo "WEB_VERSION=$WEB_VERSION"
FFMPEG_VERSION=`wget https://repo.jellyfin.org/releases/server/debian/stable/ffmpeg/ -q -O- | grep -o -P "([a-z0-9\-\.~]+)(?=-bullseye_amd64.buildinfo)" | head -n 1`
FFMPEG_VERSION="4.4.1-4"
echo "FFMPEG_VERSION=$FFMPEG_VERSION"

CURRENT_VERSION=`cat package.json | grep -o -P "(?<=\"version\"\: \")([^\"])+"`
CURRENT_SHA=`cat package.json | grep -o -P "(?<=\"sha\"\: \")([^\"])+"`
echo "CURRENT_VERSION=$CURRENT_VERSION"
echo "CURRENT_SHA=$CURRENT_SHA"

rm -f *.sha256sum
wget -q "https://repo.jellyfin.org/releases/server/debian/versions/jellyfin-ffmpeg/$FFMPEG_VERSION/jellyfin-ffmpeg5_"$FFMPEG_VERSION"-bullseye_amd64.deb.sha256sum"
wget -q "https://repo.jellyfin.org/releases/server/debian/stable/server/jellyfin-server_"$SERVER_VERSION"_amd64.deb.sha256sum"
wget -q "https://repo.jellyfin.org/releases/server/debian/stable/web/jellyfin-web_"$WEB_VERSION"_all.deb.sha256sum"

NEXT_VERSION=`echo $SERVER_VERSION @ $WEB_VERSION @ $FFMPEG_VERSION | tr ".-" " " | tr "@" "." | tr "~" "-" | sed "s/ //g"`
NEXT_SHA=`find . -maxdepth 1 -name "jelly*.deb.sha256sum" -exec cat {} \; | cut -d" " -f 1 | md5sum | cut -d" " -f 1`
echo "NEXT_VERSION=$NEXT_VERSION"
echo "NEXT_SHA=$NEXT_SHA"

QPKG_VER=`echo $SERVER_VERSION`
echo "QPKG_VER=$QPKG_VER"

if [ "$CURRENT_VERSION" == "$NEXT_VERSION" ] && [ "$CURRENT_SHA" == "$NEXT_SHA" ]; then
    echo -e "\033[0;36mNo new release \033[0m"
    exit;
fi
echo -e "\033[0;32mDownload new release \033[0m"

rm -f jellyfin-server_*.deb*
rm -f jellyfin-web_*.deb*
rm -f jellyfin-ffmpeg*_*.deb*

wget -q "https://repo.jellyfin.org/releases/server/debian/stable/server/jellyfin-server_"$SERVER_VERSION"_amd64.deb"
wget -q "https://repo.jellyfin.org/releases/server/debian/stable/web/jellyfin-web_"$WEB_VERSION"_all.deb"
wget -q "https://repo.jellyfin.org/releases/server/debian/versions/jellyfin-ffmpeg/$FFMPEG_VERSION/jellyfin-ffmpeg_"$FFMPEG_VERSION"-bullseye_amd64.deb"

sed -i "s/^QPKG_VER=.*$/QPKG_VER=\"$QPKG_VER\"/" jellyfin/qpkg.cfg

./jellyfin-server.sh
./jellyfin-ffmpeg.sh
./package.sh

sed -i "s/$CURRENT_VERSION/$NEXT_VERSION/g" package.json
sed -i "s/$CURRENT_SHA/$NEXT_SHA/g" package.json

DESC="Version based on: \`jellyfin-server_$SERVER_VERSION\` \`jellyfin-web_$WEB_VERSION\` \`jellyfin-ffmpeg_$FFMPEG_VERSION\`"
PKG=`find jellyfin/build/ -name "jellyfin_*${QPKG_VER:0:10}*.qpkg"`
./push.sh "${NEXT_VERSION}_${NEXT_SHA:0:8}" "$SERVER_VERSION" "$DESC" "$PKG" "false"
