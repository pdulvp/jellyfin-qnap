#!/bin/bash

source /qpkg/asserts.sh

files=$(ls /jellyfin/shared/fonts/etc/fonts/conf.d/*.conf | wc -l)
log_assertion $(not_equals "$files" "0") "No font config files found"

for file in /jellyfin/shared/fonts/etc/fonts/conf.d/*.conf; do
  newpath=$(readlink "$file")
  log_assertion $(file_exists "/jellyfin/shared/fonts/etc/fonts/conf.d/$newpath") "link to $newpath valid"
done
