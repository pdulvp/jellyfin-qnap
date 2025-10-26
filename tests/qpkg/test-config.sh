#!/bin/bash

source /qpkg/asserts.sh
INSTALL_PATH=$(/qpkg/getcfg.sh jellyfin Install_Path -f /jellyfin/shared/jellyfin-config.cfg)
log_assertion $(equals "$INSTALL_PATH" "/jellyfin/shared") "Install_Path shall be the correct one"

source /jellyfin/shared/jellyfin-config.sh


sub_test "Test QPKGS_PATHS default config without nvidia folder"
default_config
log_assertion $(not_contains "$QPKGS_PATHS" "/opt/NVIDIA_GPU_DRV/usr/nvidia") "QPKGS_PATHS is empty"


sub_test "Test QPKGS_PATHS default config with nvidia folder"
mkdir -p /opt/NVIDIA_GPU_DRV/usr/nvidia
default_config
log_assertion $(contains "$QPKGS_PATHS" "/opt/NVIDIA_GPU_DRV/usr/nvidia") "QPKGS_PATHS contains nvidia if folder exists"


sub_test "Test QPKGS_PATHS customized through user_config"
cat >/jellyfin/shared/user-config.sh <<EOL
#!/bin/bash
user_config(){
  export QPKGS_PATHS="$QPKGS_PATHS:/user_config"
}
EOL
load_config
log_assertion $(contains "$QPKGS_PATHS" "/user_config") "QPKGS_PATHS contains user path if defined"


sub_test "Test TMPDIR default config"
log_assertion $(equals "$TMPDIR" "/jellyfin/shared/cache/tmp") "TMPDIR shall have a default value related to jellyfin"



sub_test "Test QPKG_LD_PRELOAD default config with jemalloc"
default_config
log_assertion $(contains "$QPKG_LD_PRELOAD" "libjemalloc") "QPKG_LD_PRELOAD contains libjemalloc"

sub_test "Test QPKG_LD_PRELOAD default config without jemalloc"
mv /jellyfin/shared/jellyfin/libjemalloc.so.2 /jellyfin/shared/jellyfin/libjemalloc.so.bak
default_config
mv /jellyfin/shared/jellyfin/libjemalloc.so.bak /jellyfin/shared/jellyfin/libjemalloc.so.2
log_assertion $(not_contains "$QPKG_LD_PRELOAD" "libjemalloc") "QPKG_LD_PRELOAD not contains libjemalloc"
