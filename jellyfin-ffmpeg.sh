#!/bin/bash

ARCH=$1
if [ $(ls -1 jellyfin-ffmpeg*_*-bullseye_*.deb | wc -l) -ne 1 ]; then
    echo -e "jellyfin-ffmpeg*_XYZ-bullseye_*.deb not found or several releases." 1>&2
    exit 1
fi

FFMPEG=$(ls -1 jellyfin-ffmpeg*_*-bullseye_*.deb)
echo $FFMPEG found.

FFMPEG_INFO=`ls -1 jellyfin-ffmpeg*.buildinfo`
echo $FFMPEG_INFO found.

# Unzip jellyfin-ffmpeg.deb/data.tar.xz/./usr/lib/ into output/shared/
mkdir .tmp-ffmpeg
cd .tmp-ffmpeg
ar x ../$FFMPEG data.tar.xz
tar xvf data.tar.xz ./usr/lib/
cd ..
rm -rf output/shared/jellyfin-ffmpeg
mv .tmp-ffmpeg/usr/lib/jellyfin-ffmpeg output/shared/
rm -rf .tmp-ffmpeg

# Create ffmpeg and ffprobe versions that will rely on required jellyfin-ffmpeg/lib/ld-linux-x86-64.so.2 rather than default one
mv output/shared/jellyfin-ffmpeg/ffmpeg output/shared/jellyfin-ffmpeg/ffmpeg2
mv output/shared/jellyfin-ffmpeg/ffprobe output/shared/jellyfin-ffmpeg/ffprobe2
mv output/shared/jellyfin-ffmpeg/vainfo output/shared/jellyfin-ffmpeg/vainfo2

cat >output/shared/jellyfin-ffmpeg/ffmpeg <<EOL
#!/bin/bash

CONF=/etc/config/qpkg.conf;
QPKG_NAME="jellyfin";
QPKG_ROOT=\`/sbin/getcfg \$QPKG_NAME Install_Path -f \${CONF}\`

## Look at the config for which VaapiDriver to use from the Jellyfin.Plugin.QnapConfiguration if installed
LIBVA_FROM_CONFIG=\`[ -f \$QPKG_ROOT/database/plugins/configurations/Jellyfin.Plugin.QnapConfiguration.xml ] && cat \$QPKG_ROOT/database/plugins/configurations/Jellyfin.Plugin.QnapConfiguration.xml | grep -E "<VaapiDriver>([^<]+)</VaapiDriver>" | cut -d">" -f2 | cut -d"<" -f1\`
if [ ! -z \${LIBVA_FROM_CONFIG} ]; then
    if [ "\$LIBVA_FROM_CONFIG" != "defaultValue" ]; then
        export LIBVA_DRIVER_NAME_JELLYFIN="\$LIBVA_FROM_CONFIG"
        export LIBVA_DRIVER_NAME="\$LIBVA_FROM_CONFIG"
    fi
fi

ADDITIONAL_PATHS=""
if [ -d /opt/NVIDIA_GPU_DRV/usr/nvidia ]; then
  ADDITIONAL_PATHS=":/opt/NVIDIA_GPU_DRV/usr/nvidia"
fi

\$QPKG_ROOT/jellyfin/bin/ld-linux-x86-64.so.2 --library-path \$QPKG_ROOT/jellyfin-ffmpeg/lib:\$QPKG_ROOT/jellyfin/bin\$ADDITIONAL_PATHS \$QPKG_ROOT/jellyfin-ffmpeg/ffmpeg2 "\$@"
EOL

cat >output/shared/jellyfin-ffmpeg/ffprobe <<EOL
#!/bin/bash

CONF=/etc/config/qpkg.conf;
QPKG_NAME="jellyfin";
QPKG_ROOT=\`/sbin/getcfg \$QPKG_NAME Install_Path -f \${CONF}\`

## Look at the config for which VaapiDriver to use from the Jellyfin.Plugin.QnapConfiguration if installed
LIBVA_FROM_CONFIG=\`[ -f \$QPKG_ROOT/database/plugins/configurations/Jellyfin.Plugin.QnapConfiguration.xml ] && cat \$QPKG_ROOT/database/plugins/configurations/Jellyfin.Plugin.QnapConfiguration.xml | grep -E "<VaapiDriver>([^<]+)</VaapiDriver>" | cut -d">" -f2 | cut -d"<" -f1\`
if [ ! -z \${LIBVA_FROM_CONFIG} ]; then
    if [ "\$LIBVA_FROM_CONFIG" != "defaultValue" ]; then
        export LIBVA_DRIVER_NAME_JELLYFIN="\$LIBVA_FROM_CONFIG"
        export LIBVA_DRIVER_NAME="\$LIBVA_FROM_CONFIG"
    fi
fi

ADDITIONAL_PATHS=""
if [ -d /opt/NVIDIA_GPU_DRV/usr/nvidia ]; then
  ADDITIONAL_PATHS=":/opt/NVIDIA_GPU_DRV/usr/nvidia"
fi
\$QPKG_ROOT/jellyfin/bin/ld-linux-x86-64.so.2 --library-path \$QPKG_ROOT/jellyfin-ffmpeg/lib:\$QPKG_ROOT/jellyfin/bin\$ADDITIONAL_PATHS \$QPKG_ROOT/jellyfin-ffmpeg/ffprobe2 "\$@"
EOL

cat >output/shared/jellyfin-ffmpeg/vainfo <<EOL
#!/bin/bash

CONF=/etc/config/qpkg.conf;
QPKG_NAME="jellyfin";
QPKG_ROOT=\`/sbin/getcfg \$QPKG_NAME Install_Path -f \${CONF}\`


ADDITIONAL_PATHS=""
if [ -d /opt/NVIDIA_GPU_DRV/usr/nvidia ]; then
  ADDITIONAL_PATHS=":/opt/NVIDIA_GPU_DRV/usr/nvidia"
fi
\$QPKG_ROOT/jellyfin/bin/ld-linux-x86-64.so.2 --library-path \$QPKG_ROOT/jellyfin-ffmpeg/lib:\$QPKG_ROOT/jellyfin/bin\$ADDITIONAL_PATHS \$QPKG_ROOT/jellyfin-ffmpeg/vainfo2 "\$@"
EOL

chmod +x output/shared/jellyfin-ffmpeg/ffmpeg
chmod +x output/shared/jellyfin-ffmpeg/ffprobe
chmod +x output/shared/jellyfin-ffmpeg/vainfo

if ! ./prefetch-lib.sh "$FFMPEG_INFO" "$ARCH"; then
    exit $?
fi
exit 0