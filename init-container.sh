#!/bin/bash

LXC_NAME="bullseye1"
lxc-create -n $LXC_NAME -t download -- -d debian -r bullseye -a amd64

HOST_PATH="/mnt/c/Works/jellyfin-qnap"
CONTAINER_PATH="mnt/shared"

echo "lxc.mount.entry = $HOST_PATH $CONTAINER_PATH none bind,create=dir" | tee -a /var/lib/lxc/$LXC_NAME/config

lxc-start -n $LXC_NAME
lxc-attach -n $LXC_NAME -- sleep 4
lxc-attach -n $LXC_NAME -- bash -c "bash /mnt/shared/setup-container.sh"
