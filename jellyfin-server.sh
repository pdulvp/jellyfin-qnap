#!/bin/bash

ARCH=$1
if [ `ls -1 jellyfin-server_*_*.deb | wc -l` -ne 1 ]; then
    echo "jellyfin-server_XYZ_*.deb not found or several releases."
    exit
fi

SERVER=`ls -1 jellyfin-server_*_*.deb`
echo $SERVER found.

SERVER_INFO=`ls -1 jellyfin_*.buildinfo`
echo $SERVER_INFO found.

#Unzip jellyfin-server.deb/data.tar.xz/./usr/lib/ into output/shared/
mkdir .tmp-server;
cd .tmp-server
ar x ../$SERVER data.tar.xz
tar xf data.tar.xz ./usr/lib/
cd ..
rm -rf output/shared/jellyfin
mv .tmp-server/usr/lib/jellyfin output/shared/
rm -rf .tmp-server;

#Create redirection for jellyfin
mv output/shared/jellyfin/bin/jellyfin output/shared/jellyfin/bin/jellyfin2

cat >output/shared/jellyfin/bin/jellyfin <<EOL
#!/bin/bash

CONF=/etc/config/qpkg.conf;
QPKG_NAME="jellyfin";
QPKG_ROOT=\`/sbin/getcfg \$QPKG_NAME Install_Path -f \${CONF}\`

\$QPKG_ROOT/jellyfin/bin/ld-linux-x86-64.so.2 --library-path \$QPKG_ROOT/jellyfin/bin:\$QPKG_ROOT/jellyfin-ffmpeg/lib \$QPKG_ROOT/jellyfin/bin/jellyfin2 "\$@"
EOL

chmod +x output/shared/jellyfin/bin/jellyfin

# Add Configuration plugin
mkdir -p output/shared/database/plugins/Jellyfin.Plugin.QnapConfiguration
NETVERSION=`cat output/shared/jellyfin/bin/jellyfin.runtimeconfig.json | grep -E "tfm.*" | cut -f4 -d"\""`
echo "NETVERSION=$NETVERSION"

if ! cp plugins/Jellyfin.Plugin.QnapConfiguration/bin/Release/${NETVERSION}/* "output/shared/database/plugins/Jellyfin.Plugin.QnapConfiguration/"; then
    echo -e "\033[0;36mError copying plugin. Please generate it before \033[0m"
    exit 1
fi

ls "output/shared/database/plugins/Jellyfin.Plugin.QnapConfiguration/"

if ! ./prefetch-lib.sh "$SERVER_INFO" "$ARCH"; then
    exit $?
fi

exit 0