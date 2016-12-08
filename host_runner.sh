#!/usr/bin/env bash

docker run -t -i \
  --privileged \
  --volume=/dev/bus/usb:/dev/bus/usb \
  --volume=/tmp/.X11-unix:/tmp/.X11-unix \
  --env=DISPLAY=$DISPLAY \
  $@
