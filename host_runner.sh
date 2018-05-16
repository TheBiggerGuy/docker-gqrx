#!/usr/bin/env bash

# TODO:
#  * Isolate X11 better - http://wiki.ros.org/docker/Tutorials/GUI 

set -x

echo "Searching for Docker image ..."
DOCKER_IMAGE_ID=$(docker images --format="{{.ID}}" thebiggerguy/docker-gqrx | head -n 1)
echo "Found and using ${DOCKER_IMAGE_ID}"

DOCKER_HOSTNAME=$(docker inspect --format='{{ .Config.Hostname }}' "${DOCKER_IMAGE_ID}")
echo "Using Docker hostname ${DOCKER_HOSTNAME}"

xhost +local:${DOCKER_HOSTNAME}

USER_UID=$(id -u)

DOCKER_DEVICES=""
for DEVICE in /dev/hackrf-*
do
  echo "Adding ${DEVICE} to container"
  DEVICE_DIRECT=$(readlink -f ${DEVICE})
  DOCKER_DEVICES="${DOCKER_DEVICES} --device=${DEVICE_DIRECT} --device=${DEVICE}"
done

echo "Devices found: ${DOCKER_DEVICES}"

docker run -t -i \
  ${DOCKER_DEVICES} \
  --volume=/tmp/.X11-unix:/tmp/.X11-unix:rw \
  --volume=/run/user/${USER_UID}/pulse:/run/user/1000/pulse \
  --env=DISPLAY=unix${DISPLAY} \
  --env=LIBUSB_DEBUG=1 \
  --group-add=plugdev \
  --security-opt label:disable \
  --privileged \
  ${DOCKER_IMAGE_ID} \
  ${@}
