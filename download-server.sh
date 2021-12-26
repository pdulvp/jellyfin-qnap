#!/bin/bash

SERVER_VERSION=`wget https://repo.jellyfin.org/releases/server/debian/stable-pre/server/ -q -O- | grep -o -P "([a-z0-9\-\.]+)(?=.dsc)" | head -n 1`
echo "server=$SERVER_VERSION"
WEB_VERSION=`wget https://repo.jellyfin.org/releases/server/debian/stable-pre/web/ -q -O- | grep -o -P "([a-z0-9\-\.]+)(?=.dsc)" | head -n 1`
echo "web=$WEB_VERSION"
FFMPEG_VERSION=`wget https://repo.jellyfin.org/releases/server/debian/ffmpeg/ -q -O- | grep -o -P "([a-z0-9\-\.]+)(?=-bullseye_amd64.buildinfo)" | head -n 1`
echo "ffmpeg=$FFMPEG_VERSION"

exit
CURRENT_VERSION=`cat package.json | grep -o -P "(?<=\"version\"\: \").*([\d\.])+"`
NEXT_VERSION=`echo $SERVER_VERSION @ $WEB_VERSION @ $FFMPEG_VERSION | tr ".-" " " | tr "@" "." | sed "s/ //g"`
find . -maxdepth 1 -name "jelly*.deb" -printf "%f-%TY%Tm%Td@"


if [ "$CURRENT_VERSION" == "$NEXT_VERSION" ]; then
    echo "No new release"
    exit;
else
    echo "Download new release"
fi


rm -f jellyfin-server_*.deb*
rm -f jellyfin-web_*.deb*
rm -f jellyfin-ffmpeg_*.deb*

#wget "https://repo.jellyfin.org/releases/server/debian/stable/server/jellyfin-server_"$SERVER_VERSION"_amd64.deb"
wget "https://repo.jellyfin.org/releases/server/debian/stable/server/jellyfin-server_"$SERVER_VERSION"_amd64.deb.sha256sum"
#wget "https://repo.jellyfin.org/releases/server/debian/stable/web/jellyfin-web_"$WEB_VERSION"_all.deb"
wget "https://repo.jellyfin.org/releases/server/debian/stable/web/jellyfin-web_"$WEB_VERSION"_all.deb.sha256sum"
#wget "https://repo.jellyfin.org/releases/server/debian/ffmpeg/jellyfin-ffmpeg_"$FFMPEG_VERSION"-bullseye_amd64.deb"
wget "https://repo.jellyfin.org/releases/server/debian/ffmpeg/jellyfin-ffmpeg_"$FFMPEG_VERSION"-bullseye_amd64.deb.sha256sum"
exit
./jellyfin-server.sh
./jellyfin-ffmpeg.sh
./package.sh

echo "$CURRENT_VERSION $NEXT_VERSION"
sed -i "s/$CURRENT_VERSION/$NEXT_VERSION/g" package.json
