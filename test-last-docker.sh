#!/bin/bash


test() {
  VOLUME="jellyfin-output1-amd64"
  VOLUME_OPENCL="jellyfin-opencl-output1-amd64"

  docker build -t tester1 . -f Dockerfile-qpkg-tester

  docker run --rm -it \
    -v $VOLUME:/source \
    -v $VOLUME_OPENCL:/source-opencl \
    tester1 \
    bash -c "/qpkg/init.sh && /qpkg/launch.sh"
}

test