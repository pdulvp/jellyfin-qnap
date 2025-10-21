#!/bin/bash
CONF=/etc/config/qpkg.conf
QPKG_NAME="jellyfin"
QPKG_ROOT=`/sbin/getcfg $QPKG_NAME Install_Path -f ${CONF}`
CMD_SETCFG="/sbin/setcfg"

set_qpkg_field(){
  qpkg_field=$1
  value=$2
  current_value=`/sbin/getcfg ${QPKG_NAME} ${qpkg_field} -f ${CONF}`
  [ ! -z "${value}" ] && [ "${current_value}" != "${value}" ] && `${CMD_SETCFG} "${QPKG_NAME}" "${qpkg_field}" "${value}" -f "${CONF}"`
}

get_from_config(){
  config_file=$1
  config_field=$2
  if [ -f "$config_file" ]; then
    value=$(cat "$QPKG_ROOT/${config_file}" | grep "${config_field}" | cut -f2 -d\> | cut -f1 -d\< )
    echo "${value}"
  else
    echo ""
  fi
}

set_from_config(){
  config_file=$1
  config_field=$2
  qpkg_field=$3
  default_value=$4
  value=$(get_from_config "${config_file}" "${config_field}")
  [ -z "${value}" ] && value="${default_value}"
  set_qpkg_field "${qpkg_field}" "${value}"
}

default_config(){
  set_from_config "conf/network.xml" "InternalHttpPort" "Web_Port" "8096"

  https_enabled=$(get_from_config "conf/network.xml" "EnableHttps")
  if [ "$https_enabled" == "True" ]; then
    set_from_config "conf/network.xml" "InternalHttpsPort" "Web_SSL_Port" "8920"
  else
    set_qpkg_field "Web_SSL_Port" "-1"
  fi
  
  export TMPDIR="$QPKG_ROOT/cache/tmp"
  export QPKGS_PATHS=""
  if [ -d /opt/NVIDIA_GPU_DRV/usr/nvidia ]; then
    QPKGS_PATHS=":/opt/NVIDIA_GPU_DRV/usr/nvidia"
  fi
  export QPKGS_PATHS="$QPKGS_PATHS"
}

load_config(){
  default_config
  if [ -f "$QPKG_ROOT/user-config.sh" ]; then 
    source $QPKG_ROOT/user-config.sh;
    user_config
  fi
}

jellyfin_ffmpeg_start() {
  ## Look at the config for which VaapiDriver to use from the Jellyfin.Plugin.QnapConfiguration if installed
  LIBVA_FROM_CONFIG=`[ -f $QPKG_ROOT/database/plugins/configurations/Jellyfin.Plugin.QnapConfiguration.xml ] && cat $QPKG_ROOT/database/plugins/configurations/Jellyfin.Plugin.QnapConfiguration.xml | grep -E "<VaapiDriver>([^<]+)</VaapiDriver>" | cut -d">" -f2 | cut -d"<" -f1`
  if [ ! -z "${LIBVA_FROM_CONFIG}" ]; then
      if [ "$LIBVA_FROM_CONFIG" != "defaultValue" ]; then
          export LIBVA_DRIVER_NAME_JELLYFIN="$LIBVA_FROM_CONFIG"
          export LIBVA_DRIVER_NAME="$LIBVA_FROM_CONFIG"
      fi
  fi
  return 0
}

read_ini_file() {
  local ini_file=$1
  local section=$2
  local key=$3

  value=$(awk -F ' = ' -v section="$section" -v key="$key" '
  $0 ~ "\\[" section "\\]" { in_section=1; next }
  $0 ~ "^\\[" { in_section=0 }
  in_section && $1 == key { print $2; exit }
  ' "$ini_file")
  echo "$value"
}

find_store() {
  local ini_file="/etc/config/3rd_pkg_v2.conf"
  local url=$1
	
	SECTIONS=`cat $ini_file | grep "\[.*\]"`
	for section in ${SECTIONS//[\[\]]}; do 
		store_url=$(read_ini_file "$ini_file" "$section" "u")
		if [ $store_url == "$url" ]; then
			echo $section
			exit
		fi
	done
}

jellyfin_ffprobe_start() {
  ## Look at the config for which VaapiDriver to use from the Jellyfin.Plugin.QnapConfiguration if installed
  LIBVA_FROM_CONFIG=`[ -f $QPKG_ROOT/database/plugins/configurations/Jellyfin.Plugin.QnapConfiguration.xml ] && cat $QPKG_ROOT/database/plugins/configurations/Jellyfin.Plugin.QnapConfiguration.xml | grep -E "<VaapiDriver>([^<]+)</VaapiDriver>" | cut -d">" -f2 | cut -d"<" -f1`
  if [ ! -z "${LIBVA_FROM_CONFIG}" ]; then
      if [ "$LIBVA_FROM_CONFIG" != "defaultValue" ]; then
          export LIBVA_DRIVER_NAME_JELLYFIN="$LIBVA_FROM_CONFIG"
          export LIBVA_DRIVER_NAME="$LIBVA_FROM_CONFIG"
      fi
  fi
  return 0
}

jellyfin_vainfo_start() {
  return 0
}

jellyfin_server_start() {
  return 0
}
