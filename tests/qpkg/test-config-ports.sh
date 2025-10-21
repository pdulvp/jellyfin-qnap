#!/bin/bash

source /qpkg/asserts.sh

default_config
PORT=$(/qpkg/getcfg.sh jellyfin Web_Port)
log_assertion $(contains "$PORT" "8096") "must be default port"
PORT=$(/qpkg/getcfg.sh jellyfin Web_SSL_Port)
log_assertion $(equals "$PORT" "-1") "Web_SSL_Port must be unset"


mkdir -p /jellyfin/shared/conf/
cat >/jellyfin/shared/conf/network.xml <<EOL
<?xml version="1.0" encoding="utf-8"?>
<NetworkConfiguration xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <EnableHttps>false</EnableHttps>
  <InternalHttpPort>8987</InternalHttpPort>
  <InternalHttpsPort>8986</InternalHttpsPort>
</NetworkConfiguration>
EOL
default_config
PORT=$(/qpkg/getcfg.sh jellyfin Web_Port)
log_assertion $(equals "$PORT" "8987") "Web_Port must be jellyfin one"
PORT=$(/qpkg/getcfg.sh jellyfin Web_SSL_Port)
log_assertion $(equals "$PORT" "-1") "Web_SSL_Port must be unset"


mkdir -p /jellyfin/shared/conf/
cat >/jellyfin/shared/conf/network.xml <<EOL
<?xml version="1.0" encoding="utf-8"?>
<NetworkConfiguration xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <EnableHttps>True</EnableHttps>
  <InternalHttpPort>8987</InternalHttpPort>
</NetworkConfiguration>
EOL
default_config
PORT=$(/qpkg/getcfg.sh jellyfin Web_SSL_Port)
log_assertion $(equals "$PORT" "8920") "Web_SSL_Port must be default one"


mkdir -p /jellyfin/shared/conf/
cat >/jellyfin/shared/conf/network.xml <<EOL
<?xml version="1.0" encoding="utf-8"?>
<NetworkConfiguration xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <EnableHttps>True</EnableHttps>
  <InternalHttpPort>8987</InternalHttpPort>
  <InternalHttpsPort>8933</InternalHttpsPort>
</NetworkConfiguration>
EOL
default_config
PORT=$(/qpkg/getcfg.sh jellyfin Web_SSL_Port)
log_assertion $(equals "$PORT" "8933") "Web_SSL_Port must be jellyfin one"


