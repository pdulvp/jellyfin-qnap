#!/bin/bash

SERVER_VERSION=$(wget https://repo.jellyfin.org/?path=/server/debian/latest-stable/amd64 -q -O- | grep -o -P "([a-z0-9\-\.~]+)(?=\+deb.*.dsc)" | head -n 1)
echo "SERVER_VERSION=$SERVER_VERSION"
WEB_VERSION=$SERVER_VERSION
echo "WEB_VERSION=$WEB_VERSION"
FFMPEG_VERSION=$(wget https://repo.jellyfin.org/?path=/ffmpeg/debian/latest-6.x/amd64 -q -O- | grep -o -P "([a-z0-9\-\.~]+)(?=-bullseye_amd64.buildinfo)" | head -n 1)
#FFMPEG_VERSION="4.4.1-4"
echo "FFMPEG_VERSION=$FFMPEG_VERSION"

CURRENT_VERSION=$(cat package.json | grep -o -P "(?<=\"version\"\: \")([^\"])+")
CURRENT_SHA=$(cat package.json | grep -o -P "(?<=\"sha\"\: \")([^\"])+")
echo "CURRENT_VERSION=$CURRENT_VERSION"
echo "CURRENT_SHA=$CURRENT_SHA"

rm -f *.buildinfo
wget "https://repo.jellyfin.org/files/ffmpeg/debian/latest-6.x/amd64/jellyfin-ffmpeg_"$FFMPEG_VERSION"-bullseye_amd64.buildinfo"
wget "https://repo.jellyfin.org/files/server/debian/latest-stable/amd64/jellyfin_"$SERVER_VERSION"%2Bdeb11_amd64.buildinfo"

NEXT_VERSION=$(echo $SERVER_VERSION @ $WEB_VERSION @ $FFMPEG_VERSION | tr ".-" " " | tr "@" "." | tr "~" "-" | sed "s/ //g")
PREFIX=""
NEXT_SHA=$(PREFIX)$(find . -maxdepth 1 -name "jelly*.buildinfo" -exec cat {} \; | grep amd64.deb | md5sum | cut -d" " -f 1)
echo "NEXT_VERSION=$NEXT_VERSION"
echo "NEXT_SHA=$NEXT_SHA"
QPKG_VER=$(echo $SERVER_VERSION)
echo "QPKG_VER=$QPKG_VER"

if [ "$CURRENT_VERSION" == "$NEXT_VERSION" ] && [ "$CURRENT_SHA" == "$NEXT_SHA" ]; then
    echo -e "\033[0;36mNo new release \033[0m"
    exit;
fi
echo -e "\033[0;32mDownload new release \033[0m"

#rm -f jellyfin-server_*.deb*
#rm -f jellyfin-web_*.deb*
#rm -f jellyfin-ffmpeg*_*.deb*

#wget -q "https://repo.jellyfin.org/files/ffmpeg/debian/latest-6.x/amd64/jellyfin-ffmpeg6_"$FFMPEG_VERSION"-bullseye_amd64.deb"
#wget -q "https://repo.jellyfin.org/files/server/debian/latest-stable/amd64/jellyfin-server_"$SERVER_VERSION"%2Bdeb11_amd64.deb"
#wget -q "https://repo.jellyfin.org/files/server/debian/latest-stable/amd64/jellyfin-web_"$SERVER_VERSION"%2Bdeb11_all.deb"

rm -rf .tmp*

rm -rf output
mkdir output
cp -rf packaging/* output

sed -i "s/^QPKG_VER=.*$/QPKG_VER=\"$QPKG_VER\"/" output/qpkg.cfg

if ! ./jellyfin-server.sh; then
    exit $?
fi

if ! ./jellyfin-ffmpeg.sh; then
    exit $?
fi

if ! ./unpack-lib.sh; then
    exit $?
fi

# move all libs under bin as jellyfin doesn't support other folders.
mv .tmp-lib/lib/x86_64-linux-gnu/* output/shared/jellyfin/bin/
mv .tmp-lib/usr/lib/x86_64-linux-gnu/* output/shared/jellyfin/bin/

if ! ./jellyfin-web.sh; then
    exit $?
fi

if ! ./package.sh; then
    exit $?
fi

sed -i "s/$CURRENT_VERSION/$NEXT_VERSION/g" package.json
sed -i "s/$CURRENT_SHA/$NEXT_SHA/g" package.json

DESC="Version based on: \`jellyfin-server_$SERVER_VERSION\` \`jellyfin-web_$WEB_VERSION\` \`jellyfin-ffmpeg_$FFMPEG_VERSION\`"
PKG=$(find output/build/ -name "jellyfin_*${QPKG_VER:0:10}*.qpkg")
./push.sh "${NEXT_VERSION}_${NEXT_SHA:0:8}" "$SERVER_VERSION" "$DESC" "$PKG" "false"