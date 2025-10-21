#!/bin/bash

source /qpkg/asserts.sh


sub_test "Test that OpenCL is properly referenced on /etc on start"

/qpkg/setcfg.sh jellyfin Enable "TRUE"
START=$(/jellyfin/shared/jellyfin.sh start)
log_assertion $(folder_exists /etc/OpenCL) "/etc/OpenCL must exist."
log_assertion $(file_exists /etc/OpenCL/.jellyfin) "/etc/OpenCL/.jellyfin must exist."


sub_test "Test that OpenCL is properly removed on /etc on stop"

STOP=$(/jellyfin/shared/jellyfin.sh stop)
log_assertion $(folder_not_exists /etc/OpenCL) "/etc/OpenCL must not exist."


sub_test "Test if OpenCL is already existing in the NAS that it is not erased by jellyfin startup"

mkdir -p /etc/OpenCL/vendors
touch /etc/OpenCL/vendors/sample

START=$(/jellyfin/shared/jellyfin.sh start)
log_assertion $(folder_exists /etc/OpenCL) "/etc/OpenCL must exist."
log_assertion $(file_not_exists /etc/OpenCL/.jellyfin) "/etc/OpenCL/.jellyfin must not exist."
log_assertion $(file_exists /etc/OpenCL/vendors/sample) "/etc/OpenCL/vendors/sample must exist."


sub_test "Test if OpenCL is already existing in the NAS that it is not erased by jellyfin stop"

STOP=$(/jellyfin/shared/jellyfin.sh stop)
log_assertion $(folder_exists /etc/OpenCL) "/etc/OpenCL must not exist."
log_assertion $(file_exists /etc/OpenCL/vendors/sample) "/etc/OpenCL/vendors/sample must exist."

rm -rf /etc/OpenCL
