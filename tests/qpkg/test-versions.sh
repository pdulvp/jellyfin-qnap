#!/bin/bash

source /qpkg/asserts.sh
cp /jellyfin/qpkg.cfg .
cp /bin/echo /sbin/log_tool

cp /jellyfin/qinstall.sh .
sed -i '$d' qinstall.sh
sed -i '$d' qinstall.sh

source ./qinstall.sh
sub_test "Test version checks"

is_greater "10.11.1-01" "10.11.0-b"
RESULT=$?
log_assertion $(equals "$RESULT" "0") "by-build is_greater"

is_greater "10.11.0-c" "10.11.0-b"
RESULT=$?
log_assertion $(equals "$RESULT" "0") "by-suffix is_greater"

is_equal "10.11.0-b" "10.11.0-b"
RESULT=$?
log_assertion $(equals "$RESULT" "0") "same-suffix is_equal"

is_greater "10.11.1-a" "10.11.0-c"
RESULT=$?
log_assertion $(equals "$RESULT" "0") "by-build is_greater"

is_greater "10.11.0-c" "10.10.0-c"
RESULT=$?
log_assertion $(equals "$RESULT" "0") "by-micro is_greater"

is_greater "11.10.0-c" "10.10.0-c"
RESULT=$?
log_assertion $(equals "$RESULT" "0") "by-major is_greater"

split_version "10.11.0-c"
log_assertion $(equals "$MAJOR" "10") "split major"
log_assertion $(equals "$MINOR" "11") "split micro"
log_assertion $(equals "$BUILD" "0-c") "split build"
