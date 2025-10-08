#!/bin/bash

docker build -t bookworm1 .

docker run --rm -it \
  -v "$(pwd):/mnt/shared" \
  bookworm1 \
  bash -c "cd /mnt/shared && ./make.sh"
