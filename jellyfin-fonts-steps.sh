#!/bin/bash
ARCH=$1

#Create redirection for fc-*

case "$ARCH" in
    arm64) LD_LIB="ld-linux-aarch64.so.1" ;;
    *) LD_LIB="ld-linux-x86-64.so.2" ;;
esac

cd /output/shared/fonts/usr/bin
for file in fc-*; do
  mv "$file" "$file"2
  cat >"$file" <<EOL
#!/bin/bash

CONF=/etc/config/qpkg.conf;
QPKG_NAME="jellyfin";
QPKG_ROOT=\`/sbin/getcfg \$QPKG_NAME Install_Path -f \${CONF}\`

export FONTCONFIG_FILE=\$QPKG_ROOT/fonts/etc/fonts/local.conf
export FONTCONFIG_PATH=\$QPKG_ROOT/fonts/etc/fonts/conf.d

source \$QPKG_ROOT/jellyfin-config.sh

PRELOAD=""
if [ ! -z "\$QPKG_LD_PRELOAD" ]; then
  PRELOAD="--preload \$QPKG_LD_PRELOAD"
fi
\$QPKG_ROOT/jellyfin/$LD_LIB --library-path \$QPKG_ROOT/jellyfin\$QPKGS_PATHS \$PRELOAD \$QPKG_ROOT/fonts/usr/bin/${file}2 "\$@"
EOL
  chmod +x $file
done

