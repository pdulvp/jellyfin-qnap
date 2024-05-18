#!/bin/bash

if [ `ls -1 jellyfin-web_*_all.deb | wc -l` -ne 1 ]; then
    echo "jellyfin-web_XYZ_all.deb not found or several releases."
    exit
fi

rm -rf jellyfin/shared/jellyfin-web
WEB=`ls -1 jellyfin-web_*_all.deb`
echo $WEB jellyfin-web found.

#Unzip jellyfin-web.deb/data.tar.xz/./usr/lib/ into jellyfin/shared/
rm -rf .tmp-web; mkdir .tmp-web;
cd .tmp-web
ar x ../$WEB data.tar.xz
tar xf data.tar.xz ./usr/share/jellyfin
cd ..
mv .tmp-web/usr/share/jellyfin/web jellyfin/shared/jellyfin-web

exit 0