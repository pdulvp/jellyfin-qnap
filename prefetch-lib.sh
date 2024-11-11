#!/bin/bash

VERSION="$1"
BUILD_INFO="$2"
ARCH=$3

mkdir -p .tmp/lib;
if [ -d ".cache/$VERSION-$ARCH/deb" ]; then
  echo -e "\033[0;32mPrefetch dependencies $BUILD_INFO from cache \033[0m"
  cp .cache/$VERSION-$ARCH/deb/* .tmp/lib
  exit 0
fi

echo "Prefetch dependencies $BUILD_INFO"
mkdir -p .tmp/lib-unary;
cp "$BUILD_INFO" .tmp/lib-unary
cd .tmp/lib-unary

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
  echo "libgnutls30"   #jellyfin-ffmpeg
}

for var in $(getDependencies $BUILD_INFO); do
  apt-get download "$var" -o APT::Architecture=$ARCH
done

cd ../..
mkdir -p .cache/$VERSION-$ARCH/deb
cp .tmp/lib-unary/* .cache/$VERSION-$ARCH/deb


if [[ "$BUILD_INFO" = *"jellyfin_"* ]]; then
  if [ "$ARCH" == "amd64" ]; then
    cp intel*.deb .cache/$VERSION-$ARCH/deb
    cp libigd*.deb .cache/$VERSION-$ARCH/deb
  fi
fi

# Remove some debs that doesnt contain libs
rm -rf .cache/$VERSION-$ARCH/deb/libstdc*cross*
rm -rf .cache/$VERSION-$ARCH/deb/libstdc*dbg*
rm -rf .cache/$VERSION-$ARCH/deb/libstdc*doc*
rm -rf .cache/$VERSION-$ARCH/deb/libstdc*dev*
rm -rf .cache/$VERSION-$ARCH/deb/libstdc*pic*
rm -rf .cache/$VERSION-$ARCH/deb/libstdc*eabi*
rm -rf .cache/$VERSION-$ARCH/deb/perl*
rm -rf .cache/$VERSION-$ARCH/deb/python*
rm -rf .cache/$VERSION-$ARCH/deb/man-db*
rm -rf .cache/$VERSION-$ARCH/deb/gcc-*
rm -rf .cache/$VERSION-$ARCH/deb/cpp-*
cp .cache/$VERSION-$ARCH/deb/* .tmp/lib
rm -rf .tmp/lib-unary

echo "Finished prefetch dependencies $VERSION"
exit 0
