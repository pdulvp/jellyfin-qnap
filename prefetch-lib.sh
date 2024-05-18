#!/bin/bash

mkdir -p .tmp-lib;
cp "$1" .tmp-lib
cd .tmp-lib

ARCH=amd64
echo "Prefetch dependencies $1"
BUILD_INFO="$1"
getDependencies() {
  echo $(awk '
  /^Installed-Build-Depends:/ || /^ / && deps {
    sub(/^[^ ]+: /, "")
    deps = 1
    dep_str = dep_str ", " $0
    next
  }
  { deps=0 }
  END {
    split(dep_str, dep_array, /[,|] */)
    for (d in dep_array) {
      dep = dep_array[d]
      gsub(/[^a-z0-9_.-].*$/, "", dep)
      if (dep && !seen[dep]++) print dep
    }
  }' $1) | sort | uniq
  echo "libpciaccess0" #vainfo
  echo "libstdc++"     #jellyfin
}
for var in $(getDependencies $BUILD_INFO); do
  apt-get download "$var" -o APT::Architecture=$ARCH
done

echo "Finished prefetch dependencies $1"
exit 0
