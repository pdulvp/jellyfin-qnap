#!/bin/bash

ARCH=$1

case "$ARCH" in
    arm64) LD_LIB="ld-linux-aarch64.so.1" ;;
    *) LD_LIB="ld-linux-x86-64.so.2" ;;
esac

# Create ffmpeg and ffprobe versions that will rely on required jellyfin-ffmpeg/lib/ld-linux-x86-64.so.2 rather than default one
mv /output/shared/jellyfin-ffmpeg/ffmpeg /output/shared/jellyfin-ffmpeg/ffmpeg2
mv /output/shared/jellyfin-ffmpeg/ffprobe /output/shared/jellyfin-ffmpeg/ffprobe2
mv /output/shared/jellyfin-ffmpeg/vainfo /output/shared/jellyfin-ffmpeg/vainfo2

cat >/output/shared/jellyfin-ffmpeg/ffmpeg <<EOL
#!/bin/bash

CONF=/etc/config/qpkg.conf;
QPKG_NAME="jellyfin";
QPKG_ROOT=\`/sbin/getcfg \$QPKG_NAME Install_Path -f \${CONF}\`

source \$QPKG_ROOT/jellyfin-config.sh
jellyfin_ffmpeg_start "\$@"

PRELOAD=""
if [ ! -z "\$QPKG_LD_PRELOAD" ]; then
  PRELOAD="--preload \$QPKG_LD_PRELOAD"
fi
\$QPKG_ROOT/jellyfin/$LD_LIB --library-path \$QPKG_ROOT/jellyfin-ffmpeg/lib:\$QPKG_ROOT/jellyfin\$QPKGS_PATHS \$PRELOAD \$QPKG_ROOT/jellyfin-ffmpeg/ffmpeg2 "\$@"
EOL

cat >/output/shared/jellyfin-ffmpeg/ffprobe <<EOL
#!/bin/bash

CONF=/etc/config/qpkg.conf;
QPKG_NAME="jellyfin";
QPKG_ROOT=\`/sbin/getcfg \$QPKG_NAME Install_Path -f \${CONF}\`

source \$QPKG_ROOT/jellyfin-config.sh
jellyfin_ffprobe_start "\$@"

PRELOAD=""
if [ ! -z "\$QPKG_LD_PRELOAD" ]; then
  PRELOAD="--preload \$QPKG_LD_PRELOAD"
fi
\$QPKG_ROOT/jellyfin/$LD_LIB --library-path \$QPKG_ROOT/jellyfin-ffmpeg/lib:\$QPKG_ROOT/jellyfin\$QPKGS_PATHS \$PRELOAD \$QPKG_ROOT/jellyfin-ffmpeg/ffprobe2 "\$@"
EOL

cat >/output/shared/jellyfin-ffmpeg/vainfo <<EOL
#!/bin/bash

CONF=/etc/config/qpkg.conf;
QPKG_NAME="jellyfin";
QPKG_ROOT=\`/sbin/getcfg \$QPKG_NAME Install_Path -f \${CONF}\`

source \$QPKG_ROOT/jellyfin-config.sh
jellyfin_vainfo_start "\$@"

PRELOAD=""
if [ ! -z "\$QPKG_LD_PRELOAD" ]; then
  PRELOAD="--preload \$QPKG_LD_PRELOAD"
fi
if [ -f \$QPKG_ROOT/jellyfin-ffmpeg/vainfo2 ]; then
  \$QPKG_ROOT/jellyfin/$LD_LIB --library-path \$QPKG_ROOT/jellyfin-ffmpeg/lib:\$QPKG_ROOT/jellyfin\$QPKGS_PATHS \$PRELOAD \$QPKG_ROOT/jellyfin-ffmpeg/vainfo2 "\$@"
fi

EOL

chmod +x /output/shared/jellyfin-ffmpeg/ffmpeg
chmod +x /output/shared/jellyfin-ffmpeg/ffprobe
chmod +x /output/shared/jellyfin-ffmpeg/vainfo
