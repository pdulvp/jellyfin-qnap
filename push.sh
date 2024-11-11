#!/bin/bash

VERSION=$(cat package.json | jq -r .version)
VERSION_SHA=$(cat package.json | jq -r .sha)
SERVER_VERSION=$(cat package.json | jq -r .server)
WEB_VERSION=$(cat package.json | jq -r .web)
FFMPEG_VERSION=$(cat package.json | jq -r .ffmpeg)
FFMPEG5_VERSION=$(cat package.json | jq -r .ffmpeg5)
SUFFIX=$(cat package.json | jq -r .suffix)
PRERELEASE=true
if [ $SUFFIX != "" ]; then 
  SUFFIX="-$SUFFIX"
fi
RELEASE_NAME="${SERVER_VERSION}${SUFFIX}"
TAG_VERSION="${VERSION}${SUFFIX}_${VERSION_SHA:0:8}"

LABEL=$RELEASE_NAME
DESC="Version based on: \`jellyfin-server_$SERVER_VERSION\` \`jellyfin-web_$WEB_VERSION\` \`jellyfin-ffmpeg_$FFMPEG_VERSION\` \`jellyfin-ffmpeg5_$FFMPEG5_VERSION\`"

git pull bot HEAD
git config user.email "pdulvp-bot@laposte.net"
git config user.name "pdulvp-bot"
git add "package.json"
git add "jellyfin/qpkg.cfg"
git commit -m "$TAG_VERSION ($SERVER_VERSION)"
git tag "$TAG_VERSION"
git push bot HEAD:master
git push bot "$TAG_VERSION"
git config user.email "pdulvp@laposte.net"
git config user.name "pdulvp"

RELEASE_ID=`curl -i -X POST -H "Content-Type:application/json" -H "Authorization: token $GITHUB_BOT_TOKEN" https://api.github.com/repos/pdulvp/jellyfin-qnap/releases -d "{\"tag_name\":\"$TAG_VERSION\", \"target_commitish\":\"master\",\"name\": \"$RELEASE_NAME\", \"body\": \"$DESC\", \"draft\": false, \"prerelease\": $PRERELEASE}" `
echo "$RELEASE_ID"
RELEASE_ID=`echo $RELEASE_ID | grep -o -P "(?<=\"id\": )\d+" | head -n 1`
echo "RELEASE=$RELEASE_ID"

for FILE in $(find build/ -name "jellyfin_*$RELEASE_NAME*.qpkg"); do
  NAME=$(basename $FILE);
  echo "Publish $FILE"
  curl -X POST \
      -H "Authorization: token $GITHUB_BOT_TOKEN" \
      -H "Content-Type: $(file -b --mime-type $FILE)" \
      --data-binary @$FILE \
      "https://uploads.github.com/repos/pdulvp/jellyfin-qnap/releases/$RELEASE_ID/assets?name=$NAME&label=$NAME" | cat

  if [ -f $FILE.md5 ]; then
    echo "Publish $FILE.md5"
    curl -X POST \
        -H "Authorization: token $GITHUB_BOT_TOKEN" \
        -H "Content-Type: $(file -b --mime-type $FILE.md5)" \
        --data-binary @$FILE.md5 \
        "https://uploads.github.com/repos/pdulvp/jellyfin-qnap/releases/$RELEASE_ID/assets?name=$NAME.md5&label=$NAME.md5" | cat
  fi
done
