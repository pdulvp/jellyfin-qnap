#!/bin/bash

APP=$1
FIELD=$2
VALUE=$3
echo "$VALUE" > /tmp/cfg-$APP-$FIELD.settings
