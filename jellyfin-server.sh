#!/bin/bash

if [ `ls -1 jellyfin-server_*_amd64.deb | wc -l` -ne 1 ]; then
    echo "jellyfin-server_XYZ_amd64.deb not found or several releases."
    exit
fi

if [ `ls -1 jellyfin-web_*_all.deb | wc -l` -ne 1 ]; then
    echo "jellyfin-web_XYZ_all.deb not found or several releases."
    exit
fi

WEB=`ls -1 jellyfin-web_*_all.deb`
echo $WEB jellyfin-web found.

SERVER=`ls -1 jellyfin-server_*_amd64.deb`
echo $SERVER found.

#Unzip jellyfin-server.deb/data.tar.xz/./usr/lib/ into jellyfin/shared/
rm -rf .tmp; mkdir .tmp;
cd .tmp
ar x ../$SERVER data.tar.xz
tar xvf data.tar.xz ./usr/lib/
cd ..
rm -rf jellyfin/shared/jellyfin
rm -rf jellyfin/shared/jellyfin-web
mv .tmp/usr/lib/jellyfin jellyfin/shared/


#Unzip jellyfin-web.deb/data.tar.xz/./usr/lib/ into jellyfin/shared/
rm -rf .tmp; mkdir .tmp;
cd .tmp
ar x ../$WEB data.tar.xz
tar xvf data.tar.xz ./usr/share/jellyfin
cd ..
mv .tmp/usr/share/jellyfin/web jellyfin/shared/jellyfin-web

#Add "System.Globalization.Invariant": true into jellyfin/bin/jellyfin.runtimeconfig.json
#https://everythingtech.dev/2021/08/how-to-fix-couldnt-find-a-valid-icu-package-installed-on-the-system-set-the-configuration-flag-system-globalization-invariant-to-true-if-you-want-to-run-with-no-globalization-support/
#Process terminated. Couldn't find a valid ICU package installed on the system. Set the configuration flag System.Globalization.Invariant to true if you want to run with no globalization support.

sed -i 's/"configProperties": {/"configProperties": {\n      "System.Globalization.Invariant": true,/g' jellyfin/shared/jellyfin/bin/jellyfin.runtimeconfig.json

# Add Configuration plugin
mkdir -p jellyfin/shared/database/plugins/Jellyfin.Plugin.QnapConfiguration
NETVERSION=`cat jellyfin/shared/jellyfin/bin/jellyfin.runtimeconfig.json | grep -E "tfm.*" | cut -f4 -d"\""`
echo "NETVERSION=$NETVERSION"
cp configuration/Jellyfin.Plugin.QnapConfiguration/bin/Release/${NETVERSION}/* "jellyfin/shared/database/plugins/Jellyfin.Plugin.QnapConfiguration/"
ls "jellyfin/shared/database/plugins/Jellyfin.Plugin.QnapConfiguration/"