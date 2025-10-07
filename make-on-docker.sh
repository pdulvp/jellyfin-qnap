#!/bin/bash

#docker build -t bullseye1 .

docker run --rm -it \
  -v "$(pwd):/mnt/shared" \
  bullseye1 \
  bash -c "cd /mnt/shared && ./make.sh"
