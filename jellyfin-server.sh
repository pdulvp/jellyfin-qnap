#!/bin/bash

if [ `ls -1 jellyfin-server_*_amd64.deb | wc -l` -ne 1 ]; then
    echo "jellyfin-server_XYZ_amd64.deb not found or several releases."
    exit
fi

SERVER=`ls -1 jellyfin-server_*_amd64.deb`
echo $SERVER found.

SERVER_INFO=`ls -1 jellyfin_*.buildinfo`
echo $SERVER_INFO found.

#Unzip jellyfin-server.deb/data.tar.xz/./usr/lib/ into jellyfin/shared/
mkdir .tmp-server;
cd .tmp-server
ar x ../$SERVER data.tar.xz
tar xf data.tar.xz ./usr/lib/
cd ..
rm -rf jellyfin/shared/jellyfin
mv .tmp-server/usr/lib/jellyfin jellyfin/shared/
rm -rf .tmp-server;

#Create redirection for jellyfin
mv jellyfin/shared/jellyfin/bin/jellyfin jellyfin/shared/jellyfin/bin/jellyfin2

cat >jellyfin/shared/jellyfin/bin/jellyfin <<EOL
#!/bin/bash

CONF=/etc/config/qpkg.conf;
QPKG_NAME="jellyfin";
QPKG_ROOT=\`/sbin/getcfg \$QPKG_NAME Install_Path -f \${CONF}\`

\$QPKG_ROOT/jellyfin/bin/ld-linux-x86-64.so.2 --library-path \$QPKG_ROOT/jellyfin/bin:\$QPKG_ROOT/jellyfin-ffmpeg/lib \$QPKG_ROOT/jellyfin/bin/jellyfin2 "\$@"
EOL

chmod +x jellyfin/shared/jellyfin/bin/jellyfin

# Add Configuration plugin
mkdir -p jellyfin/shared/database/plugins/Jellyfin.Plugin.QnapConfiguration
NETVERSION=`cat jellyfin/shared/jellyfin/bin/jellyfin.runtimeconfig.json | grep -E "tfm.*" | cut -f4 -d"\""`
echo "NETVERSION=$NETVERSION"
cp configuration/Jellyfin.Plugin.QnapConfiguration/bin/Release/${NETVERSION}/* "jellyfin/shared/database/plugins/Jellyfin.Plugin.QnapConfiguration/"
ls "jellyfin/shared/database/plugins/Jellyfin.Plugin.QnapConfiguration/"

if ! ./prefetch-lib.sh "$SERVER_INFO" "amd64"; then
    exit $?
fi

exit 0