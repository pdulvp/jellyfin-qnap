#!/bin/bash

APP=$1
FIELD=$2
if [ -f /tmp/cfg-$APP-$FIELD.settings ]; then
  cat /tmp/cfg-$APP-$FIELD.settings
else
  echo "NOT_HANDLED_$TYPE"
fi