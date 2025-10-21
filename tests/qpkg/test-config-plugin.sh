#!/bin/bash

source /qpkg/asserts.sh
INSTALL_PATH=$(/qpkg/getcfg.sh jellyfin Install_Path -f /jellyfin/shared/jellyfin-config.cfg)
log_assertion $(equals "$INSTALL_PATH" "/jellyfin/shared") "Install_Path shall be the correct one"

source /jellyfin/shared/jellyfin-config.sh


sub_test "Test LIBVA_DRIVER_NAME overriden through jellyfin plugin"

mkdir -p /jellyfin/shared/database/plugins/configurations/
LIBVA_DRIVER_NAME=default
cat >/jellyfin/shared/database/plugins/configurations/Jellyfin.Plugin.QnapConfiguration.xml <<EOL
<?xml version="1.0" encoding="utf-8"?>
<PluginConfiguration xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <VaapiDriver>i965</VaapiDriver>
</PluginConfiguration>
EOL
jellyfin_ffmpeg_start
log_assertion $(equals "$LIBVA_DRIVER_NAME" "i965") "VaapiDriver shall be the correct one"


LIBVA_DRIVER_NAME=default
cat >/jellyfin/shared/database/plugins/configurations/Jellyfin.Plugin.QnapConfiguration.xml <<EOL
<?xml version="1.0" encoding="utf-8"?>
<PluginConfiguration xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <VaapiDriver>iHD</VaapiDriver>
</PluginConfiguration>
EOL
jellyfin_ffmpeg_start
log_assertion $(equals "$LIBVA_DRIVER_NAME" "iHD") "VaapiDriver shall be the correct one"


LIBVA_DRIVER_NAME=default
rm -rf /jellyfin/shared/database/plugins/configurations/Jellyfin.Plugin.QnapConfiguration.xml
jellyfin_ffmpeg_start
log_assertion $(equals "$LIBVA_DRIVER_NAME" "default") "VaapiDriver shall be the correct one"
