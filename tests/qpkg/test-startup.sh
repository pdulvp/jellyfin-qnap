#!/bin/bash

source /qpkg/asserts.sh


sub_test "Test Application enablement"

/qpkg/setcfg.sh jellyfin Enable "FALSE"
START=$(/jellyfin/shared/jellyfin.sh start)
log_assertion $(equals "$START" "jellyfin is disabled.") "If not enabled, jellyfin must be disabled"


sub_test "Test Application start"

/qpkg/setcfg.sh jellyfin Enable "TRUE"
START=$(/jellyfin/shared/jellyfin.sh start)
log_assertion $(contains "$START" "jellyfin is started.") "jellyfin must be started."

log_assertion $(folder_exists /opt/jellyfin) "/opt/jellyfin must exist."
log_assertion $(folder_exists /usr/lib/jellyfin-ffmpeg) "/usr/lib/jellyfin-ffmpeg must exist."


sub_test "Test Application stop"

STOP=$(/jellyfin/shared/jellyfin.sh stop)
log_assertion $(contains "$STOP" "jellyfin is stopped.") "jellyfin must be stopped."

log_assertion $(folder_not_exists /opt/jellyfin) "/opt/jellyfin must not exist."
log_assertion $(folder_not_exists /usr/lib/jellyfin-ffmpeg) "/usr/lib/jellyfin-ffmpeg must not exist."


