#!/bin/bash

# $1=NAME
# $2=LABEL
# $3=DESC
# $4=FILE
# $5=PRERELEASE

echo $*
git pull bot HEAD
git config user.email "pdulvp-bot@laposte.net"
git config user.name "pdulvp-bot"
git add "package.json"
git add "jellyfin/qpkg.cfg"
git commit -m "$1 ($2)"
git tag "$1"
git push bot HEAD:master
git push bot "$1"
git config user.email "pdulvp@laposte.net"
git config user.name "pdulvp"

RELEASE_ID=`curl -i -X POST -H "Content-Type:application/json" -H "Authorization: token $GITHUB_BOT_TOKEN" https://api.github.com/repos/pdulvp/jellyfin-qnap-intel/releases -d "{\"tag_name\":\"$1\", \"target_commitish\":\"master\",\"name\": \"$2\", \"body\": \"$3\", \"draft\": false, \"prerelease\": $5}" `
echo "$RELEASE_ID"
RELEASE_ID=`echo $RELEASE_ID | grep -o -P "(?<=\"id\": )\d+" | head -n 1`
echo "RELEASE=$RELEASE_ID"

FILE="$4"
NAME=$(basename $FILE);
curl -X POST \
    -H "Authorization: token $GITHUB_BOT_TOKEN" \
    -H "Content-Type: $(file -b --mime-type $FILE)" \
    --data-binary @$FILE \
    "https://uploads.github.com/repos/pdulvp/jellyfin-qnap-intel/releases/$RELEASE_ID/assets?name=$NAME&label=$NAME" | cat

curl -X POST \
    -H "Authorization: token $GITHUB_BOT_TOKEN" \
    -H "Content-Type: $(file -b --mime-type $FILE.md5)" \
    --data-binary @$FILE.md5 \
    "https://uploads.github.com/repos/pdulvp/jellyfin-qnap-intel/releases/$RELEASE_ID/assets?name=$NAME.md5&label=$NAME.md5" | cat
