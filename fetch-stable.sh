#!/bin/bash

ARCH=amd64
SERVER_VERSION=$(wget https://repo.jellyfin.org/?path=/server/debian/latest-stable/$ARCH -q -O- | grep -o -P "([a-z0-9\-\.~]+)(?=\+deb.*_$ARCH.buildinfo)" | head -n 1)
echo "SERVER_VERSION=$SERVER_VERSION"
WEB_VERSION=$SERVER_VERSION
echo "WEB_VERSION=$WEB_VERSION"
FFMPEG_VERSION=$(wget https://repo.jellyfin.org/?path=/ffmpeg/debian/latest-7.x/$ARCH -q -O- | grep -o -P "([a-z0-9\-\.~]+)(?=-bullseye_$ARCH.buildinfo)" | head -n 1)
#FFMPEG_VERSION="4.4.1-4"
FFMPEG5_VERSION=$(wget https://repo.jellyfin.org/?path=/ffmpeg/debian/latest-5.x/$ARCH -q -O- | grep -o -P "([a-z0-9\-\.~]+)(?=-bullseye_$ARCH.deb)" | head -n 1)
echo "FFMPEG_VERSION=$FFMPEG_VERSION"
echo "FFMPEG5_VERSION=$FFMPEG5_VERSION"

CURRENT_VERSION=$(cat package.json | grep -o -P "(?<=\"version\"\: \")([^\"])+")
CURRENT_SHA=$(cat package.json | grep -o -P "(?<=\"sha\"\: \")([^\"])+")
echo "CURRENT_VERSION=$CURRENT_VERSION"
echo "CURRENT_SHA=$CURRENT_SHA"

PREFIX=""
NEXT_VERSION=$(echo $SERVER_VERSION @ $WEB_VERSION @ $FFMPEG_VERSION @ $FFMPEG5_VERSION | tr ".-" " " | tr "@" "." | tr "~" "-" | sed "s/ //g")
NEXT_SHA=$(echo $NEXT_VERSION | md5sum | cut -d" " -f 1)
echo "NEXT_VERSION=$NEXT_VERSION"
echo "NEXT_SHA=$NEXT_SHA"

SUFFIX=$(cat package.json | grep -o -P "(?<=\"suffix\"\: \")([^\"])+")
if [ $SUFFIX != "" ]; then 
  SUFFIX="-$SUFFIX"
fi
QPKG_VER=$SERVER_VERSION$SUFFIX
echo "QPKG_VER=$QPKG_VER"

if [ "$CURRENT_VERSION" == "$NEXT_VERSION" ] && [ "$CURRENT_SHA" == "$NEXT_SHA" ]; then
    echo -e "\033[0;36mNo new release \033[0m"
    exit;
fi
echo -e "\033[0;32mDownload new release \033[0m"

get() {
  URL=$1
  KEY=${URL##*/}
  KEY=$(echo $KEY | sed "s/%2B/\+/g")
  echo $KEY
  if [ -f .cache/deb/$KEY ]; then
    cp .cache/deb/$KEY .
    echo -e "\033[0;32mGet from cache \033[0m"
  else
    wget -q $URL
    mkdir -p .cache/deb;
    cp $KEY .cache/deb
  fi
}

proceed() {
  ARCH=$1
  FFMPEG=$2
  echo "Procceed $ARCH $FFMPEG"
  rm -f *.buildinfo
  if [ "$FFMPEG" == "ffmpeg5" ]; then
    FFMPEG_INFO=latest-6.x/$ARCH/jellyfin-ffmpeg_$FFMPEG_VERSION-bullseye_$ARCH.buildinfo
    FFMPEG_DEB=latest-5.x/$ARCH/jellyfin-ffmpeg5_$FFMPEG5_VERSION-bullseye_$ARCH.deb
    FFMPEG_TAG=$FFMPEG5_VERSION
  elif [ "$FFMPEG" == "ffmpeg6" ]; then
    FFMPEG_INFO=latest-6.x/$ARCH/jellyfin-ffmpeg_$FFMPEG_VERSION-bullseye_$ARCH.buildinfo
    FFMPEG_DEB=latest-6.x/$ARCH/jellyfin-ffmpeg6_$FFMPEG_VERSION-bullseye_$ARCH.deb
    FFMPEG_TAG=$FFMPEG5_VERSION
  else
    FFMPEG_INFO=latest-7.x/$ARCH/jellyfin-ffmpeg_$FFMPEG_VERSION-bullseye_$ARCH.buildinfo
    FFMPEG_DEB=latest-7.x/$ARCH/jellyfin-ffmpeg7_$FFMPEG_VERSION-bullseye_$ARCH.deb
    FFMPEG_TAG=$FFMPEG_VERSION
  fi

  SERVER_INFO=latest-stable/$ARCH/jellyfin_$SERVER_VERSION%2Bdeb11_$ARCH.buildinfo
  SERVER_DEB=latest-stable/$ARCH/jellyfin-server_$SERVER_VERSION%2Bdeb11_$ARCH.deb
  WEB_DEB=latest-stable/$ARCH/jellyfin-web_$SERVER_VERSION%2Bdeb11_all.deb

  get "https://repo.jellyfin.org/files/ffmpeg/debian/$FFMPEG_INFO"
  get "https://repo.jellyfin.org/files/server/debian/$SERVER_INFO"

  rm -f jellyfin-server_*.deb*
  rm -f jellyfin-web_*.deb*
  rm -f jellyfin-ffmpeg*_*.deb*

  get "https://repo.jellyfin.org/files/ffmpeg/debian/$FFMPEG_DEB"
  get "https://repo.jellyfin.org/files/server/debian/$SERVER_DEB"
  get "https://repo.jellyfin.org/files/server/debian/$WEB_DEB"

  rm -rf .tmp
  rm -rf output
  mkdir output
  cp -rf packaging/* output

  if ! ./jellyfin-server.sh "$ARCH" "$SERVER_VERSION"; then
      exit $?
  fi

  if ! ./jellyfin-ffmpeg.sh "$ARCH" "$FFMPEG_TAG" "$FFMPEG"; then
      exit $?
  fi

  if ! ./unpack-lib.sh "$SERVER_VERSION-$FFMPEG_TAG-$ARCH"; then
      exit $?
  fi

  # move all libs under bin as jellyfin doesn't support other folders.
  mv .tmp/lib/lib/*-linux-*/* output/shared/jellyfin/bin/
  mv .tmp/lib/usr/lib/*-linux-*/* output/shared/jellyfin/bin/

  if ! ./jellyfin-web.sh; then
      exit $?
  fi

  mkdir -p output/build
  if ! ./package.sh $ARCH $FFMPEG $QPKG_VER; then
      exit $?
  fi
}

if ! proceed "amd64" "ffmpeg7"; then
  exit $?
fi
if ! proceed "amd64" "ffmpeg5"; then
  exit $?
fi
if ! proceed "arm64" "ffmpeg5"; then
  exit $?
fi
if ! proceed "arm64" "ffmpeg7"; then
  exit $?
fi
if ! proceed "armhf" "ffmpeg7"; then
  exit $?
fi
if ! proceed "armhf" "ffmpeg5"; then
  exit $?
fi

json=$(cat package.json | jq ".version = \"$NEXT_VERSION\"")
json=$(echo $json | jq ".sha = \"$NEXT_SHA\"")
json=$(echo $json | jq ".ffmpeg = \"$FFMPEG_VERSION\"")
json=$(echo $json | jq ".ffmpeg5 = \"$FFMPEG5_VERSION\"")
json=$(echo $json | jq ".server = \"$SERVER_VERSION\"")
json=$(echo $json | jq ".web = \"$WEB_VERSION\"")
printf '%s\n' "$json" > package.json
