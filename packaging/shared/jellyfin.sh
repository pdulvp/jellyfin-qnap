#!/bin/sh
CONF=/etc/config/qpkg.conf
QPKG_NAME="jellyfin"
QPKG_ROOT=`/sbin/getcfg $QPKG_NAME Install_Path -f ${CONF}`
CMD_SETCFG="/sbin/setcfg"

PDULVP_STORE="https://pdulvp.github.io/qnap-store/repos.xml"
PDULVP_PRE_STORE="https://pdulvp.github.io/qnap-store/repos-prereleases.xml"

export PATH=$QPKG_ROOT/jellyfin/bin:$QPKG_ROOT/jellyfin-ffmpeg:$PATH

source $QPKG_ROOT/jellyfin-config.sh

jellyfin_start(){
  /bin/ln -sf $QPKG_ROOT /opt/$QPKG_NAME
  /bin/ln -sf $QPKG_ROOT/jellyfin-ffmpeg /usr/lib/jellyfin-ffmpeg

  ENABLED=$(/sbin/getcfg $QPKG_NAME Enable -u -d FALSE -f $CONF)

  load_config
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

link_to_store(){
  store=$(find_store $1)
  ${CMD_SETCFG} "${QPKG_NAME}" "store" "$store" -f "${CONF}"
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

  link_to_default_store)
    link_to_store "$PDULVP_STORE"
    ;;

  link_to_prerelease_store)
    link_to_store "$PDULVP_PRE_STORE"
    ;;

  *)
    echo "Usage: $0 {start|stop|restart|link_to_default_store|link_to_prerelease_store}"
    exit 1
esac

exit 0
