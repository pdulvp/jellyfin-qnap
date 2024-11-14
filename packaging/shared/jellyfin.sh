#!/bin/sh
CONF=/etc/config/qpkg.conf
QPKG_NAME="jellyfin"
QPKG_ROOT=`/sbin/getcfg $QPKG_NAME Install_Path -f ${CONF}`
export QNAP_QPKG=$QPKG_NAME
export PATH=$QPKG_ROOT/jellyfin/bin:$QPKG_ROOT/jellyfin-ffmpeg:$PATH

#export LIBVA_DRIVER_NAME_JELLYFIN=i965 #iHD

set_from_config(){
  config_file=$1
  config_field=$2
  qpkg_field=$3
  default_value=$4

  # Set if different
  value=$(cat $QPKG_ROOT/$config_file | grep $config_field | cut -f2 -d\> | cut -f1 -d\< )
  [ -z "$value" ] && value=$default_value
  current_value=`/sbin/getcfg $QPKG_NAME $qpkg_field -f ${CONF}`
  [ ! -z "$value" ] && [ "$current_value" -ne "$value" ] && `/sbin/setcfg $QPKG_NAME $qpkg_field "$value" -f ${CONF}`
}

jellyfin_start(){
  /bin/ln -sf $QPKG_ROOT /opt/$QPKG_NAME
  /bin/ln -sf $QPKG_ROOT/jellyfin-ffmpeg /usr/lib/jellyfin-ffmpeg

  ENABLED=$(/sbin/getcfg $QPKG_NAME Enable -u -d FALSE -f $CONF)

  set_from_config "conf/network.xml" "InternalHttpPort" "Web_Port" "8096"
  set_from_config "conf/network.xml" "InternalHttpsPort" "Web_SSL_Port" "8920"

  mkdir -p $QPKG_ROOT/logs
  $QPKG_ROOT/jellyfin-ffmpeg/vainfo > $QPKG_ROOT/logs/vainfo-$(date -d "today" +"%Y%m%d%H%M").log
  $QPKG_ROOT/jellyfin/bin/jellyfin --datadir=$QPKG_ROOT/database --cachedir=$QPKG_ROOT/cache --webdir=$QPKG_ROOT/jellyfin-web --configdir=$QPKG_ROOT/conf --logdir=$QPKG_ROOT/logs --ffmpeg=$QPKG_ROOT/jellyfin-ffmpeg/ffmpeg --package-name=pdulvp &
  sleep 10
}

jellyfin_stop(){
  ps aux | grep -ie jellyfin/bin/ld-linux | grep -v grep | awk '{print $1}' | xargs kill -9
  rm -rf /opt/$QPKG_NAME
  rm -rf /usr/lib/jellyfin-ffmpeg
}

case "$1" in
  start)
    ENABLED=$(/sbin/getcfg $QPKG_NAME Enable -u -d FALSE -f $CONF)
    if [ "$ENABLED" != "TRUE" ]; then
        echo "$QPKG_NAME is disabled."
        exit 1
    fi
    jellyfin_start
    ;;

  stop)
    jellyfin_stop
    ;;

  restart)
    $0 stop
    $0 start
    ;;

  *)
    echo "Usage: $0 {start|stop|restart}"
    exit 1
esac

exit 0
