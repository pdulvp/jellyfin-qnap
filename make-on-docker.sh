#!/bin/bash

docker build -t jellyfin-info . -f Dockerfile-jellyfin-info
docker build -t qbuild1 . -f Dockerfile-qbuild
docker build -t net1 . -f Dockerfile-net

# Test qbuild
if [ 1 == 2 ]; then
  docker build -t qbuild.test . -f Dockerfile-qbuild.test
  rm -rf $(pwd)/tests/test/*
  mkdir -p $(pwd)/tests/test/build
  cp -r packaging/* $(pwd)/tests/test

  docker run --rm -it \
    -v "$(pwd):/mnt/shared" \
    -v "$(pwd)/tests/test:/test" \
    qbuild.test \
    bash -c "/mnt/shared/tests/test-qbuild.sh"
fi

get_env_var() {
  local container=$1
  local var_name=$2
  docker run --rm -it "$container" bash -c "/jellyfin-info.sh; source /.env; echo \$$var_name" | tr -d '\r' | tr -d '\n'
}

create_volume() {
  local volume_name=$1
  local containers=$(docker ps -a --filter volume="$volume_name" -q)

  if [ -n "$containers" ]; then
    echo "Stopping and removing containers using the volume: $volume_name"
    docker stop $containers
    docker rm $containers
  fi
  if docker volume inspect "$volume_name" > /dev/null 2>&1; then
    echo "Deleting existing volume: $volume_name"
    docker volume rm --force "$volume_name"
  else
    echo "Volume $volume_name does not exist, skipping deletion."
  fi
  docker volume create $VOLUME
}

initialize_output_folder() {
  rm -rf output
  mkdir -p output
  cp -rf packaging/* output
}

VOLUME_PLUGINS="jellyfin-plugins"
create_volume "$VOLUME_PLUGINS"

docker run --rm -it \
  -v "$(pwd)/plugins:/plugins" \
  -v $VOLUME_PLUGINS:/output \
  net1 \
  bash -c "/make-plugin.sh " 

process() {
  pwd
  ARCH=$1
  QPKG_VER=$2

  VOLUME_JELLYFIN="jellyfin-volume-jellyfin-$ARCH"
  create_volume "$VOLUME_JELLYFIN"

  VOLUME_USR="jellyfin-volume-usr-$ARCH"
  create_volume "$VOLUME_USR"

  VOLUME_ETC="jellyfin-volume-etc-$ARCH"
  create_volume "$VOLUME_ETC"

  VOLUME_OUTPUT="jellyfin-output1-$ARCH"
  create_volume "$VOLUME_OUTPUT"

  docker build --platform linux/$ARCH -t jellyfin1 . -f Dockerfile-jellyfin 

  docker run \
  --platform linux/$ARCH \
  -v $VOLUME_JELLYFIN:/jellyfin \
  -v $VOLUME_ETC:/etc \
  -v $VOLUME_USR:/usr \
  jellyfin1 \
  echo

  docker build -t builder1 . -f Dockerfile-builder
  docker run --rm -it \
    -v $VOLUME_JELLYFIN:/source/jellyfin \
    -v $VOLUME_ETC:/source/etc \
    -v $VOLUME_USR:/source/usr \
    -v $VOLUME_OUTPUT:/output \
    -v $VOLUME_PLUGINS:/plugins \
    builder1 \
    bash -c "/copy.sh && /jellyfin-ffmpeg-steps.sh $ARCH && /jellyfin-server-steps.sh $ARCH"

  docker run --rm -it \
    -v $VOLUME_OUTPUT:/output \
    -v "$(pwd)/build:/builds" \
    qbuild1 \
    bash -c "/update_qver.sh $QPKG_VER && cd /output && /usr/share/QDK/bin/qbuild -v && cd .. && /archive-artifacts.sh $ARCH ffmpeg7 $QPKG_VER" 
}

FFMPEG_VERSION=$(get_env_var "jellyfin-info" "JELLYFIN_FFMPEG")
SERVER_VERSION=$(get_env_var "jellyfin-info" "JELLYFIN_VERSION")
WEB_VERSION=$SERVER_VERSION

source ./version-check.sh
echo CURRENT_VERSION=$CURRENT_VERSION
echo NEXT_VERSION=$NEXT_VERSION
echo QPKG_VER=$QPKG_VER

process "amd64" $QPKG_VER
process "arm64" $QPKG_VER

json=$(cat package.json | jq ".version = \"$NEXT_VERSION\"")
json=$(echo $json | jq ".sha = \"$NEXT_SHA\"")
json=$(echo $json | jq ".qpkg_ver = \"$QPKG_VER\"")
json=$(echo $json | jq ".ffmpeg = \"$FFMPEG_VERSION\"")
json=$(echo $json | jq ".server = \"$SERVER_VERSION\"")
json=$(echo $json | jq ".web = \"$WEB_VERSION\"")
printf '%s\n' "$json" > package.json
