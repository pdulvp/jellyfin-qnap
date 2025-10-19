#!/bin/bash
QPKG_VER=$1
sed -i "s/^QPKG_VER=.*$/QPKG_VER=\"$QPKG_VER\"/" /output/qpkg.cfg
