#!/bin/bash

source /qpkg/asserts.sh

/qpkg/setcfg.sh jellyfin Enable "FALSE"
START=$(/jellyfin/shared/jellyfin.sh start)
log_assertion $(equals "$START" "jellyfin is disabled.") "jellyfin must be disabled"

/qpkg/setcfg.sh jellyfin Enable "TRUE"
START=$(/jellyfin/shared/jellyfin.sh start)
log_assertion $(contains $START "jellyfin is started.") "jellyfin must be started."

log_assertion $(folder_exists /opt/jellyfin) "/opt/jellyfin must exist."
log_assertion $(folder_exists /usr/lib/jellyfin-ffmpeg) "/usr/lib/jellyfin-ffmpeg must exist."

STOP=$(/jellyfin/shared/jellyfin.sh stop)
log_assertion $(contains $STOP "jellyfin is stopped.") "jellyfin must be stopped."

log_assertion $(folder_not_exists /opt/jellyfin) "/opt/jellyfin must not exist."
log_assertion $(folder_not_exists /usr/lib/jellyfin-ffmpeg) "/usr/lib/jellyfin-ffmpeg must not exist."
