#!/bin/bash

source /qpkg/asserts.sh

mkdir -p /etc/config/
cat >/etc/config/3rd_pkg_v2.conf <<EOL
[AAAA]
store = AAAA
d = pdulvp releases
u = https://pdulvp.github.io/qnap-store/repos.xml

[BBBB]
store = BBBB
d = pdulvp prereleases
u = https://pdulvp.github.io/qnap-store/repos-prereleases.xml
EOL

/jellyfin/shared/jellyfin.sh link_to_default_store
STORE=$(/qpkg/getcfg.sh jellyfin store)
log_assertion $(contains "$STORE" "AAAA") "store must be linked"

/jellyfin/shared/jellyfin.sh link_to_prerelease_store
STORE=$(/qpkg/getcfg.sh jellyfin store)
log_assertion $(contains "$STORE" "BBBB") "pre-release store must be linked"

