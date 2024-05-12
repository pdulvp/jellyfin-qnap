#!/bin/bash

rm -rf .tmp; mkdir .tmp;
mkdir -p "$2"
cp "$1" .tmp
cd .tmp
ls *.buildinfo | cat > root.txt

echo "Prefetch dependencies"
ls *.buildinfo


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
  }' *.buildinfo) | sort | uniq
  echo "libpciaccess0" #vainfo
  echo "libstdc++"     #jellyfin
}
for var in $(getDependencies $line); do
  apt-get download "$var" -o APT::Architecture=amd64 
done

for file in $(find . -type f -name "*.deb"); do
    echo "--- $file"
    ar x $file data.tar.xz
    tar xvf data.tar.xz ./usr/lib/x86_64-linux-gnu/
    tar xvf data.tar.xz ./lib/x86_64-linux-gnu/
    rm -f *.tar.xz
done

cd ..

if ! [ -d .tmp/usr/lib/x86_64-linux-gnu ] && ! [ -d .tmp/lib/x86_64-linux-gnu ]; then
    exit 1
fi

mv .tmp/usr/lib/x86_64-linux-gnu/* "$2"
mv .tmp/lib/x86_64-linux-gnu/* "$2"
exit 0
