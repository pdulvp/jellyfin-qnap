#!/bin/sh
CONF=/etc/config/qpkg.conf
QPKG_NAME="jellyfin"
QPKG_ROOT=`/sbin/getcfg $QPKG_NAME Install_Path -f ${CONF}`
APACHE_ROOT=`/sbin/getcfg SHARE_DEF defWeb -d Qweb -f /etc/config/def_share.info`
export QNAP_QPKG=$QPKG_NAME

case "$1" in
  start)
    ENABLED=$(/sbin/getcfg $QPKG_NAME Enable -u -d FALSE -f $CONF)
    if [ "$ENABLED" != "TRUE" ]; then
        echo "$QPKG_NAME is disabled."
        exit 1
    fi
    : ADD START ACTIONS HERE

export LIBVA_DRIVER_NAME=i965 #iHD
export PATH=$QPKG_ROOT/jellyfin/bin:$QPKG_ROOT/jellyfin-ffmpeg:$PATH

/bin/ln -sf $QPKG_ROOT /opt/$QPKG_NAME
/bin/ln -sf $QPKG_ROOT/jellyfin-ffmpeg /usr/lib/jellyfin-ffmpeg

$QPKG_ROOT/jellyfin/bin/jellyfin --datadir=$QPKG_ROOT/database --cachedir=$QPKG_ROOT/cache --configdir=$QPKG_ROOT/conf --logdir=$QPKG_ROOT/logs --restartpath=/etc/init.d/jellyfin.sh --restartargs=restart --package-name=pdulvp &
sleep 10


    ;;

  stop)
    : ADD STOP ACTIONS HERE

killall -9 jellyfin

rm -rf /opt/$QPKG_NAME
rm -rf /usr/lib/jellyfin-ffmpeg

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
