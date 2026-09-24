#!/bin/bash

source /qpkg/asserts.sh
source /jellyfin/shared/jellyfin-config.sh

/qpkg/setcfg.sh jellyfin-opencl Enable "TRUE"

sub_test "Test if OpenCL is started, icd is valid"
START=$(/jellyfin-opencl/shared/jellyfin-opencl.sh start)
VALUE=$(cat /jellyfin-opencl/shared/etc/OpenCL/vendors/intel.icd)
VALUE_LEGACY=$(cat /jellyfin-opencl/shared/etc/OpenCL/vendors/intel_legacy1.icd)

log_assertion $(equals "$VALUE" "/jellyfin-opencl/shared/lib/intel-opencl/libigdrcl.so") "intel.icd shall be valid"
log_assertion $(equals "$VALUE_LEGACY" "/jellyfin-opencl/shared/lib/intel-opencl/libigdrcl_legacy1.so") "intel_legacy1.icd shall be valid"

