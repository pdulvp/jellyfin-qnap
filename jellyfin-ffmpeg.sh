#!/bin/bash

ARCH=$1
FFMPEG_VERSION=$2
FFMPEG_TYPE=$3
if [ $(ls -1 jellyfin-ffmpeg*_*-bullseye_*.deb | wc -l) -ne 1 ]; then
    echo -e "jellyfin-ffmpeg*_XYZ-bullseye_*.deb not found or several releases." 1>&2
    exit 1
fi

FFMPEG=$(ls -1 jellyfin-ffmpeg*_*-bullseye_*.deb)
echo $FFMPEG found.

FFMPEG_INFO=`ls -1 jellyfin-ffmpeg*.buildinfo`
echo $FFMPEG_INFO found.

case "$ARCH" in
    armhf) LD_LIB="ld-linux-armhf.so.3" ;;
    arm64) LD_LIB="ld-linux-aarch64.so.1" ;;
    *) LD_LIB="ld-linux-x86-64.so.2" ;;
esac

if [ "$ARCH" == "$NEXT_VERSION" ] && [ "$CURRENT_SHA" == "$NEXT_SHA" ]; then
    echo -e "\033[0;36mNo new release \033[0m"
    exit;
fi

# Unzip jellyfin-ffmpeg.deb/data.tar.xz/./usr/lib/ into output/shared/
mkdir .tmp/ffmpeg
cd .tmp/ffmpeg
ar x ../../$FFMPEG data.tar.xz
tar xf data.tar.xz ./usr/lib/
cd ../..
rm -rf output/shared/jellyfin-ffmpeg
mv .tmp/ffmpeg/usr/lib/jellyfin-ffmpeg output/shared/
rm -rf .tmp/ffmpeg

# Create ffmpeg and ffprobe versions that will rely on required jellyfin-ffmpeg/lib/ld-linux-x86-64.so.2 rather than default one
mv output/shared/jellyfin-ffmpeg/ffmpeg output/shared/jellyfin-ffmpeg/ffmpeg2
mv output/shared/jellyfin-ffmpeg/ffprobe output/shared/jellyfin-ffmpeg/ffprobe2
mv output/shared/jellyfin-ffmpeg/vainfo output/shared/jellyfin-ffmpeg/vainfo2

cat >output/shared/jellyfin-ffmpeg/ffmpeg <<EOL
#!/bin/bash

CONF=/etc/config/qpkg.conf;
QPKG_NAME="jellyfin";
QPKG_ROOT=\`/sbin/getcfg \$QPKG_NAME Install_Path -f \${CONF}\`

source \$QPKG_ROOT/jellyfin-config.sh
jellyfin_ffmpeg_start "\$@"

\$QPKG_ROOT/jellyfin/bin/$LD_LIB --library-path \$QPKG_ROOT/jellyfin-ffmpeg/lib:\$QPKG_ROOT/jellyfin/bin\$QPKGS_PATHS \$QPKG_ROOT/jellyfin-ffmpeg/ffmpeg2 "\$@"
EOL

cat >output/shared/jellyfin-ffmpeg/ffprobe <<EOL
#!/bin/bash

CONF=/etc/config/qpkg.conf;
QPKG_NAME="jellyfin";
QPKG_ROOT=\`/sbin/getcfg \$QPKG_NAME Install_Path -f \${CONF}\`

source \$QPKG_ROOT/jellyfin-config.sh
jellyfin_ffprobe_start "\$@"

\$QPKG_ROOT/jellyfin/bin/$LD_LIB --library-path \$QPKG_ROOT/jellyfin-ffmpeg/lib:\$QPKG_ROOT/jellyfin/bin\$ADDITIONAL_PATHS \$QPKG_ROOT/jellyfin-ffmpeg/ffprobe2 "\$@"
EOL

cat >output/shared/jellyfin-ffmpeg/vainfo <<EOL
#!/bin/bash

CONF=/etc/config/qpkg.conf;
QPKG_NAME="jellyfin";
QPKG_ROOT=\`/sbin/getcfg \$QPKG_NAME Install_Path -f \${CONF}\`

source \$QPKG_ROOT/jellyfin-config.sh
jellyfin_vainfo_start "\$@"

if [ -f \$QPKG_ROOT/jellyfin-ffmpeg/vainfo2 ]; then
  \$QPKG_ROOT/jellyfin/bin/$LD_LIB --library-path \$QPKG_ROOT/jellyfin-ffmpeg/lib:\$QPKG_ROOT/jellyfin/bin\$ADDITIONAL_PATHS \$QPKG_ROOT/jellyfin-ffmpeg/vainfo2 "\$@"
fi

EOL

chmod +x output/shared/jellyfin-ffmpeg/ffmpeg
chmod +x output/shared/jellyfin-ffmpeg/ffprobe
chmod +x output/shared/jellyfin-ffmpeg/vainfo

if [ "$FFMPEG" == "ffmpeg5" ]; then 
  if ! ! ./prefetch-lib-legacy.sh "$FFMPEG_VERSION" "$FFMPEG" "$ARCH"; then
      exit $?
  fi
else
  if ! ./prefetch-lib.sh "$FFMPEG_VERSION" "$FFMPEG_INFO" "$ARCH"; then
      exit $?
  fi
fi

exit 0