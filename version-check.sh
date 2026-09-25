#!/bin/bash

CURRENT_VERSION=$(cat package.json | jq -r .version)
SUFFIX=$(cat package.json | jq -r .suffix)

if [ $SUFFIX != "" ]; then 
  SUFFIX=".$SUFFIX"
fi

NEXT_VERSION=$(echo $SERVER_VERSION @ $SUFFIX @ $FFMPEG_VERSION | tr ".-" " " | tr "@" "." | tr "~" "-" | sed "s/ //g")
QPKG_VER=$(echo $SERVER_VERSION)$SUFFIX

echo "CURRENT_VERSION=$CURRENT_VERSION"
echo "NEXT_VERSION=$NEXT_VERSION"
echo "QPKG_VER=$QPKG_VER"

if [ "$CURRENT_VERSION" == "$NEXT_VERSION" ]; then
    echo -e "\033[0;36mNo new release \033[0m"
    exit;
fi
echo -e "\033[0;32mDownload new release \033[0m"
