#!/bin/bash

source /qpkg/asserts.sh
INSTALL_PATH=$(/qpkg/getcfg.sh jellyfin Install_Path -f /jellyfin/shared/jellyfin-config.cfg)
log_assertion $(equals "$INSTALL_PATH" "/jellyfin/shared") "Install_Path shall be the correct one"

source /jellyfin/shared/jellyfin-config.sh

default_config
log_assertion $(not_contains "$QPKGS_PATHS" "/opt/NVIDIA_GPU_DRV/usr/nvidia") "QPKGS_PATHS is empty"

mkdir -p /opt/NVIDIA_GPU_DRV/usr/nvidia
default_config
log_assertion $(contains "$QPKGS_PATHS" "/opt/NVIDIA_GPU_DRV/usr/nvidia") "QPKGS_PATHS contains nvidia if folder exists"

log_assertion $(equals "$TMPDIR" "/jellyfin/shared/cache/tmp") "TMPDIR shall have a default value related to jellyfin"


cat >/jellyfin/shared/user-config.sh <<EOL
#!/bin/bash
user_config(){
  export QPKGS_PATHS="$QPKGS_PATHS:/user_config"
}
EOL
load_config
log_assertion $(contains "$QPKGS_PATHS" "/user_config") "QPKGS_PATHS contains user path if defined"
