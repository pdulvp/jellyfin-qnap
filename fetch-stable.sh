#!/bin/bash

ARCH=amd64
SERVER_KIND=preview
SERVER_VERSION=$(wget https://repo.jellyfin.org/?path=/server/debian/latest-$SERVER_KIND/$ARCH -q -O- | grep -o -P "([a-z0-9\-\.~]+)(?=\+deb11_$ARCH.buildinfo)" | head -n 1)
echo "SERVER_VERSION=$SERVER_VERSION"
WEB_VERSION=$SERVER_VERSION
echo "WEB_VERSION=$WEB_VERSION"
FFMPEG_VERSION=$(wget https://repo.jellyfin.org/?path=/ffmpeg/debian/latest-7.x/$ARCH -q -O- | grep -o -P "([a-z0-9\-\.~]+)(?=-bullseye_$ARCH.buildinfo)" | head -n 1)
echo "FFMPEG_VERSION=$FFMPEG_VERSION"

CURRENT_VERSION=$(cat package.json | grep -o -P "(?<=\"version\"\: \")([^\"])+")
CURRENT_SHA=$(cat package.json | grep -o -P "(?<=\"sha\"\: \")([^\"])+")
echo "CURRENT_VERSION=$CURRENT_VERSION"
echo "CURRENT_SHA=$CURRENT_SHA"

SUFFIX=$(cat package.json | grep -o -P "(?<=\"suffix\"\: \")([^\"])+")
if [ $SUFFIX != "" ]; then 
  SUFFIX="-$SUFFIX"
fi

NEXT_VERSION=$(echo $SERVER_VERSION @ $SUFFIX @ $FFMPEG_VERSION | tr ".-" " " | tr "@" "." | tr "~" "-" | sed "s/ //g")
NEXT_SHA=$(echo $NEXT_VERSION | md5sum | cut -d" " -f 1)
echo "NEXT_VERSION=$NEXT_VERSION"
echo "NEXT_SHA=$NEXT_SHA"

QPKG_VER=$(echo $SERVER_VERSION | cut -f1 -d"-")$SUFFIX
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

gpg_check() {
  if ! gpg --no-default-keyring --keyring ./jellyfin_team.gpg --verify $1; then
    echo "GPG signature verification failed for $1"
    exit 1
  fi
}

sha256sum_check() {
  INFO=$1
  DEB=$2
  SHA=$(sha256sum $DEB | cut -d" " -f1)
  if ! grep $SHA -o $INFO; then
    echo "Wrong SHA for ffmpeg: $SHA"
    exit 1
  fi
}

get_jellyfin_key() {
  # Just to make sure that jellyfin_team.gpg is still valid
  wget -q "https://repo.jellyfin.org/jellyfin_team.gpg.key"
  SHA="$(sha256sum jellyfin_team.gpg.key | cut -d' ' -f1)"
  if [ $SHA != "a0cde241ae297fa6f0265c0bf15ce9eb9ee97c008904a59ab367a67d59532839" ]; then
    echo "Please verify the key integrity"
    exit 1
  fi

  if [ ! -f jellyfin_team.gpg ]; then
    cat jellyfin_team.gpg.key | gpg --dearmor --yes --output jellyfin_team.gpg
  fi
  rm -f jellyfin_team.gpg.key
}

proceed() {
  ARCH=$1
  FFMPEG=$2
  echo "Procceed $ARCH $FFMPEG"
  rm -f *.buildinfo

  FFMPEG_INFO=jellyfin-ffmpeg_$FFMPEG_VERSION-bullseye_$ARCH.buildinfo
  FFMPEG_DEB=jellyfin-ffmpeg7_$FFMPEG_VERSION-bullseye_$ARCH.deb
  FFMPEG_TAG=$FFMPEG_VERSION

  SERVER_INFO=jellyfin_$SERVER_VERSION+deb11_$ARCH.buildinfo
  SERVER_DEB=jellyfin-server_$SERVER_VERSION+deb11_$ARCH.deb
  WEB_DEB=jellyfin-web_$SERVER_VERSION+deb11_all.deb
  
  get "https://repo.jellyfin.org/files/ffmpeg/debian/latest-7.x/$ARCH/$FFMPEG_INFO"
  #gpg_check $FFMPEG_INFO #buildinfo is not signed
  get "https://repo.jellyfin.org/files/server/debian/latest-$SERVER_KIND/$ARCH/$SERVER_INFO"
  gpg_check $SERVER_INFO

  rm -f jellyfin-server_*.deb*
  rm -f jellyfin-web_*.deb*
  rm -f jellyfin-ffmpeg*_*.deb*

  get "https://repo.jellyfin.org/files/ffmpeg/debian/latest-7.x/$ARCH/$FFMPEG_DEB"
  sha256sum_check $FFMPEG_INFO $FFMPEG_DEB
  get "https://repo.jellyfin.org/files/server/debian/latest-$SERVER_KIND/$ARCH/$SERVER_DEB"
  #sha256sum_check $SERVER_INFO $SERVER_DEB   #checksum doesn't match
  get "https://repo.jellyfin.org/files/server/debian/latest-$SERVER_KIND/$ARCH/$WEB_DEB"
  #sha256sum_check $SERVER_INFO $WEB_DEB      #checksum doesn't match
  
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

get_jellyfin_key

if ! proceed "amd64" "ffmpeg7"; then
  exit $?
fi

if ! proceed "arm64" "ffmpeg7"; then
  exit $?
fi

json=$(cat package.json | jq ".version = \"$NEXT_VERSION\"")
json=$(echo $json | jq ".sha = \"$NEXT_SHA\"")
json=$(echo $json | jq ".ffmpeg = \"$FFMPEG_VERSION\"")
json=$(echo $json | jq ".server = \"$SERVER_VERSION\"")
json=$(echo $json | jq ".kind = \"$SERVER_KIND\"")
json=$(echo $json | jq ".web = \"$WEB_VERSION\"")
printf '%s\n' "$json" > package.json
