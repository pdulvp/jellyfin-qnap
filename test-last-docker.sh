#!/bin/bash


test() {
  VOLUME3="jellyfin-output1-amd64"

  docker build -t tester1 . -f Dockerfile-qpkg-tester

  docker run --rm -it \
    -v $VOLUME3:/source \
    tester1 \
    bash -c "/qpkg/init.sh && /qpkg/launch.sh"
}

test