#!/bin/bash

source /qpkg/asserts.sh


source /jellyfin/shared/jellyfin-config.sh

/qpkg/setcfg.sh jellyfin Enable "TRUE"

sub_test "Test if OpenCL is enabled and installed, the variables are here"

/qpkg/setcfg.sh jellyfin-opencl Enable "TRUE"
OCL_ICD_VENDORS=default
default_config
log_assertion $(equals "$OCL_ICD_VENDORS" "/jellyfin-opencl/shared/etc/OpenCL/vendors") "OCL_ICD_VENDORS shall point to the correct location"
log_assertion $(equals "$QPKGS_PATHS" ":/jellyfin-opencl/shared/lib") "QPKGS_PATHS shall include the correct path"

sub_test "Test if OpenCL is disabled and installed, the variables are not there"

OCL_ICD_VENDORS=default
/qpkg/setcfg.sh jellyfin-opencl Enable "FALSE"
default_config
log_assertion $(equals "$OCL_ICD_VENDORS" "default") "OCL_ICD_VENDORS shall not be modified"
log_assertion $(equals "$QPKGS_PATHS" "") "QPKGS_PATHS shall be empty"

sub_test "Test if OpenCL is not installed, the variables are not there"
mv /jellyfin-opencl /jocl
OCL_ICD_VENDORS=default
/qpkg/setcfg.sh jellyfin-opencl Enable "TRUE"
default_config
log_assertion $(equals "$OCL_ICD_VENDORS" "default") "OCL_ICD_VENDORS shall not be modified"
log_assertion $(equals "$QPKGS_PATHS" "") "QPKGS_PATHS shall be empty"
mv /jocl /jellyfin-opencl

