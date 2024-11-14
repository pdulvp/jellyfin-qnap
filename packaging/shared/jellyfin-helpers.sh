#!/bin/sh
CONF=/etc/config/qpkg.conf
QPKG_NAME="jellyfin"
QPKG_ROOT=`/sbin/getcfg $QPKG_NAME Install_Path -f ${CONF}`

set_value(){
  qpkg_field=$1
  value=$2
  
  current_value=`/sbin/getcfg $QPKG_NAME $qpkg_field -f ${CONF}`
  [ ! -z "$value" ] && [ "$current_value" -ne "$value" ] && `/sbin/setcfg $QPKG_NAME $qpkg_field "$value" -f ${CONF}`
}

set_from_config(){
  config_file=$1
  config_field=$2
  qpkg_field=$3
  default_value=$4

  value=$(cat $QPKG_ROOT/$config_file | grep $config_field | cut -f2 -d\> | cut -f1 -d\< )
  [ -z "$value" ] && value=$default_value
  set_value $qpkg_field $value
}
