#!/bin/bash
CONF=/etc/config/qpkg.conf
QPKG_NAME="jellyfin-opencl"
QPKG_ROOT=`/sbin/getcfg $QPKG_NAME Install_Path -f ${CONF}`
CMD_SETCFG="/sbin/setcfg"

PDULVP_STORE="https://pdulvp.github.io/qnap-store/repos.xml"
PDULVP_PRE_STORE="https://pdulvp.github.io/qnap-store/repos-prereleases.xml"

jellyfin_opencl_start(){
  link_icd
  echo "$QPKG_NAME is started."
}

jellyfin_opencl_stop(){
  echo "$QPKG_NAME is stopped."
}

link_icd(){
  echo "$QPKG_ROOT/lib/intel-opencl/libigdrcl.so" > "$QPKG_ROOT/etc/OpenCL/vendors/intel.icd"
  echo "$QPKG_ROOT/lib/intel-opencl/libigdrcl_legacy1.so" > "$QPKG_ROOT/etc/OpenCL/vendors/intel_legacy1.icd"
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
    jellyfin_opencl_start
    ;;

  stop)
    jellyfin_opencl_stop
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
