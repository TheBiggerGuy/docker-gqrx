#!/usr/bin/env bash

# TODO:
#  * Isolate X11 better - http://wiki.ros.org/docker/Tutorials/GUI 

set -x

xhost +local:docker

echo "Searching for Docker image ..."
DOCKER_IMAGE_ID=$(docker images --format="{{.ID}}" docker-gqrx:latest | head -n 1)
echo "Found and using ${DOCKER_IMAGE_ID}"

USER_UID=$(id -u)

DOCKER_DEVICES=""
for DEVICE in /dev/hackrf-*
do
  echo "Adding ${DEVICE} to container"
  DEVICE_DIRECT=$(readlink -f ${DEVICE})
  DOCKER_DEVICES="${DOCKER_DEVICES} --device=${DEVICE_DIRECT}"
done

echo "Devices found: ${DOCKER_DEVICES}"

docker run -t -i \
  ${DOCKER_DEVICES} \
  --volume=/tmp/.X11-unix:/tmp/.X11-unix \
  --volume=/run/user/${USER_UID}/pulse:/run/user/1000/pulse \
  --env=DISPLAY=${DISPLAY} \
  --env=LIBUSB_DEBUG=1 \
  --group-add=plugdev \
  ${DOCKER_IMAGE_ID} \
  ${@}
