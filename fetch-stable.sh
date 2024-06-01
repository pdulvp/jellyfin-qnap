#!/bin/bash

ARCH=amd64
SERVER_VERSION=$(wget https://repo.jellyfin.org/?path=/server/debian/latest-stable/$ARCH -q -O- | grep -o -P "([a-z0-9\-\.~]+)(?=\+deb.*_$ARCH.buildinfo)" | head -n 1)
echo "SERVER_VERSION=$SERVER_VERSION"
WEB_VERSION=$SERVER_VERSION
echo "WEB_VERSION=$WEB_VERSION"
FFMPEG_VERSION=$(wget https://repo.jellyfin.org/?path=/ffmpeg/debian/latest-6.x/$ARCH -q -O- | grep -o -P "([a-z0-9\-\.~]+)(?=-bullseye_$ARCH.buildinfo)" | head -n 1)
#FFMPEG_VERSION="4.4.1-4"
echo "FFMPEG_VERSION=$FFMPEG_VERSION"

CURRENT_VERSION=$(cat package.json | grep -o -P "(?<=\"version\"\: \")([^\"])+")
CURRENT_SHA=$(cat package.json | grep -o -P "(?<=\"sha\"\: \")([^\"])+")
echo "CURRENT_VERSION=$CURRENT_VERSION"
echo "CURRENT_SHA=$CURRENT_SHA"

PREFIX=""
NEXT_VERSION=$(echo $SERVER_VERSION @ $WEB_VERSION @ $FFMPEG_VERSION | tr ".-" " " | tr "@" "." | tr "~" "-" | sed "s/ //g")
NEXT_SHA=$PREFIX$(echo $NEXT_VERSION | md5sum | cut -d" " -f 1)
echo "NEXT_VERSION=$NEXT_VERSION"
echo "NEXT_SHA=$NEXT_SHA"

if [ "$CURRENT_VERSION" == "$NEXT_VERSION" ] && [ "$CURRENT_SHA" == "$NEXT_SHA" ]; then
    echo -e "\033[0;36mNo new release \033[0m"
    exit;
fi
echo -e "\033[0;32mDownload new release \033[0m"

for ARCH in armhf arm64 amd64; do

  rm -f *.buildinfo
  FFMPEG_INFO=latest-6.x/$ARCH/jellyfin-ffmpeg_"$FFMPEG_VERSION"-bullseye_$ARCH.buildinfo
  FFMPEG_DEB=latest-6.x/$ARCH/jellyfin-ffmpeg6_"$FFMPEG_VERSION"-bullseye_$ARCH.deb

  SERVER_INFO=latest-stable/$ARCH/jellyfin_"$SERVER_VERSION"%2Bdeb11_$ARCH.buildinfo
  SERVER_DEB=latest-stable/$ARCH/jellyfin-server_"$SERVER_VERSION"%2Bdeb11_$ARCH.deb
  WEB_DEB=latest-stable/$ARCH/jellyfin-web_"$SERVER_VERSION"%2Bdeb11_all.deb

  wget "https://repo.jellyfin.org/files/ffmpeg/debian/$FFMPEG_INFO"
  wget "https://repo.jellyfin.org/files/server/debian/$SERVER_INFO"

  rm -f jellyfin-server_*.deb*
  rm -f jellyfin-web_*.deb*
  rm -f jellyfin-ffmpeg*_*.deb*

  wget -q "https://repo.jellyfin.org/files/ffmpeg/debian/$FFMPEG_DEB"
  wget -q "https://repo.jellyfin.org/files/server/debian/$SERVER_DEB"
  wget -q "https://repo.jellyfin.org/files/server/debian/$WEB_DEB"

  rm -rf .tmp*
  rm -rf output
  mkdir output
  cp -rf packaging/* output

  sed -i "s/^QPKG_VER=.*$/QPKG_VER=\"$SERVER_VERSION\"/" output/qpkg.cfg

  if ! ./jellyfin-server.sh "$ARCH"; then
      exit $?
  fi

  if ! ./jellyfin-ffmpeg.sh "$ARCH"; then
      exit $?
  fi

  if ! ./unpack-lib.sh; then
      exit $?
  fi

  # move all libs under bin as jellyfin doesn't support other folders.
  mv .tmp-lib/lib/*-linux-*/* output/shared/jellyfin/bin/
  mv .tmp-lib/usr/lib/*-linux-*/* output/shared/jellyfin/bin/

  if ! ./jellyfin-web.sh; then
      exit $?
  fi

  mkdir -p output/build
  if ! ./package.sh $ARCH; then
      exit $?
  fi

done

cat package.json | jq ".version = \"$NEXT_VERSION\"" | jq ".sha = \"$NEXT_SHA\"" | jq ".ffmpeg = \"$FFMPEG_VERSION\"" | jq ".server = \"$SERVER_VERSION\"" | jq ".web = \"$WEB_VERSION\"" > package.json

./push.sh
