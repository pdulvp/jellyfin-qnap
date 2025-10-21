#!/bin/bash
ARCH=$1

#Create redirection for jellyfin
mv /output/shared/jellyfin/jellyfin /output/shared/jellyfin/jellyfin2

case "$ARCH" in
    arm64) LD_LIB="ld-linux-aarch64.so.1" ;;
    *) LD_LIB="ld-linux-x86-64.so.2" ;;
esac

cat >/output/shared/jellyfin/jellyfin <<EOL
#!/bin/bash

CONF=/etc/config/qpkg.conf;
QPKG_NAME="jellyfin";
QPKG_ROOT=\`/sbin/getcfg \$QPKG_NAME Install_Path -f \${CONF}\`

source \$QPKG_ROOT/jellyfin-config.sh
jellyfin_server_start "\$@"

\$QPKG_ROOT/jellyfin/$LD_LIB --library-path \$QPKG_ROOT/jellyfin:\$QPKG_ROOT/jellyfin-ffmpeg/lib\$QPKGS_PATHS \$QPKG_ROOT/jellyfin/jellyfin2 "\$@"
EOL

chmod +x /output/shared/jellyfin/jellyfin

# Add Configuration plugin
mkdir -p /output/shared/database/plugins/Jellyfin.Plugin.QnapConfiguration
NETVERSION=`cat /output/shared/jellyfin/jellyfin.runtimeconfig.json | grep -E "tfm.*" | cut -f4 -d"\""`
echo "NETVERSION=$NETVERSION"

if ! cp /plugins/Jellyfin.Plugin.QnapConfiguration/bin/Release/${NETVERSION}/* "/output/shared/database/plugins/Jellyfin.Plugin.QnapConfiguration/"; then
    echo -e "\033[0;36mError copying plugin. Please generate it before \033[0m"
    exit 1
fi
