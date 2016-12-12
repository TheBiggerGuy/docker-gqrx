FROM ubuntu:16.04
MAINTAINER Guy Taylor <thebigguy.co.uk@gmail.com>

ARG DEBIAN_FRONTEND=noninteractive

# Build reqirments
ENV BUILD_PACKAGES "software-properties-common curl"
RUN apt-get update \
 && apt-get install --yes ${BUILD_PACKAGES}

# init
ENV TINI_VERSION v0.13.1
run curl -L -o /bin/tini "https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini" \
 && curl -L -o /tmp/tini.asc "https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini.asc" \
 && gpg \
      --keyserver ha.pool.sks-keyservers.net \
      --recv-keys 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7 \
 && gpg --verify /tmp/tini.asc /bin/tini \
 && rm /tmp/tini.asc \
 && chmod +x /bin/tini
ENTRYPOINT ["/bin/tini", "--"]

# gqrx
RUN add-apt-repository --yes ppa:ettusresearch/uhd \
 && add-apt-repository --yes ppa:myriadrf/drivers \
 && add-apt-repository --yes ppa:myriadrf/gnuradio \
 && add-apt-repository --yes ppa:gqrx/gqrx-sdr \
 && apt-get update \
 && apt-get install --yes libvolk1-bin gqrx-sdr libhackrf0

# clean up
RUN echo "${BUILD_PACKAGES}" | xargs apt-get purge --yes \
 && apt-get autoremove --purge --yes \
 && rm -rf /var/lib/apt/lists/*

# Set up the user
RUN export UNAME=gqrx UID=1000 GID=1000 && \
    mkdir -p "/home/${UNAME}" && \
    echo "${UNAME}:x:${UID}:${GID}:${UNAME} User,,,:/home/${UNAME}:/bin/bash" >> /etc/passwd && \
    echo "${UNAME}:x:${UID}:" >> /etc/group && \
    mkdir -p /etc/sudoers.d && \
    echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${UNAME} && \
    chmod 0440 /etc/sudoers.d/${UNAME} && \
    chown ${UID}:${GID} -R /home/${UNAME} && \
    gpasswd --add ${UNAME} audio 

COPY pulse-client.conf /etc/pulse/client.conf

USER gqrx
ENV HOME /home/gqrx

# run
CMD ["gqrx"]
