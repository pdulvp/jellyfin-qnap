#!/bin/bash

docker build -t jellyfin1 . -f Dockerfile-jellyfin

docker build -t qbuild1 . -f Dockerfile-qbuild
docker run --rm -it \
  -v "$(pwd):/mnt/shared" \
  qbuild1 \
  bash -c "cd /tmp/QDK-2.4.0/ && ./InstallToUbuntu.sh install && find /usr/share/QDK"

# Test qbuild
docker build -t qbuild.test . -f Dockerfile-qbuild.test
rm -rf $(pwd)/tests/test/*
mkdir -p $(pwd)/tests/test/build
cp -r packaging/* $(pwd)/tests/test

docker run --rm -it \
  -v "$(pwd):/mnt/shared" \
  -v "$(pwd)/tests/test:/test" \
  qbuild.test \
  bash -c "/mnt/shared/tests/test-qbuild.sh"

docker build -t bookworm1 . -f Dockerfile

setSha() {
  SHA=$1 
  json=$(cat package.json | jq ".sha = \"$SHA\"")
  printf '%s\n' "$json" > package.json
}

process() {
  ARCH=$1
  
  #docker run --rm -it \
  #  -v "$(pwd):/mnt/shared" \
  #  bookworm1 \
  #  bash -c "cd /mnt/shared && ./fetch-stable.sh $ARCH"


docker run --rm -it \
  -v "$(pwd):/mnt/shared" \
  -v "$(pwd)/jel:/mnt/jel" \
  jellyfin1 \
  bash -c "cd /mnt/shared && ./copy.sh"

./jellyfin-server-steps.sh "amd64"
./jellyfin-ffmpeg-steps.sh "amd64"

QPKG_VER=10.11.0-9a
sed -i "s/^QPKG_VER=.*$/QPKG_VER=\"$QPKG_VER\"/" output/qpkg.cfg

json=$(cat package.json | jq ".qpkg_ver = \"$QPKG_VER\"")
printf '%s\n' "$json" > package.json

  docker run --rm -it \
    -v "$(pwd):/mnt/shared" \
    qbuild1 \
    bash -c "cd /mnt/shared/output && /usr/share/QDK/bin/qbuild -v" 

  docker run --rm -it \
    -v "$(pwd):/mnt/shared" \
    bookworm1 \
    bash -c "cd /mnt/shared && ./package.sh $ARCH ffmpeg7"

}

SHA=$(cat package.json | jq -r .sha)
process "amd64"
#setSha "$SHA"
#process "arm64"

