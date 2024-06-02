#!/bin/bash

VERSION="$1"
BUILD_INFO="$2"
ARCH=$3

mkdir -p .tmp-lib;
if [ -d ".cache/$VERSION-$ARCH/deb" ]; then
  echo -e "\033[0;32mPrefetch dependencies $2 from cache \033[0m"
  cp .cache/$VERSION-$ARCH/deb/* .tmp-lib
  exit 0
fi

echo "Prefetch dependencies $2"
cp "$2" .tmp-lib
cd .tmp-lib

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

cd ..

mkdir -p .cache/$VERSION-$ARCH/deb
cp .tmp-lib/* .cache/$VERSION-$ARCH/deb

echo "Finished prefetch dependencies $1"
exit 0
