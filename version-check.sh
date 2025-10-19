#!/bin/bash

CURRENT_VERSION=$(cat package.json | jq -r .version)
CURRENT_SHA=$(cat package.json | jq -r .sha)
SUFFIX=$(cat package.json | jq -r .suffix)

if [ $SUFFIX != "" ]; then 
  SUFFIX="-$SUFFIX"
fi

NEXT_VERSION=$(echo $SERVER_VERSION @ $SUFFIX @ $FFMPEG_VERSION | tr ".-" " " | tr "@" "." | tr "~" "-" | sed "s/ //g")
NEXT_SHA=$(echo $NEXT_VERSION | md5sum | cut -d" " -f 1)
QPKG_VER=$(echo $SERVER_VERSION | cut -f1 -d"-")$SUFFIX

echo "CURRENT_VERSION=$CURRENT_VERSION"
echo "CURRENT_SHA=$CURRENT_SHA"
echo "NEXT_VERSION=$NEXT_VERSION"
echo "NEXT_SHA=$NEXT_SHA"
echo "QPKG_VER=$QPKG_VER"

if [ "$CURRENT_VERSION" == "$NEXT_VERSION" ] && [ "$CURRENT_SHA" == "$NEXT_SHA" ]; then
    echo -e "\033[0;36mNo new release \033[0m"
    exit;
fi
echo -e "\033[0;32mDownload new release \033[0m"
