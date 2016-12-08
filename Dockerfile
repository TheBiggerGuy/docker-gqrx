FROM ubuntu:16.04
MAINTAINER Guy Taylor <thebigguy.co.uk@gmail.com>

# Build reqirments
ENV BUILD_PACKAGES "software-properties-common curl"
RUN apt-get update \
 && apt-get install --yes ${BUILD_PACKAGES}

# init
ENV TINI_VERSION v0.13.1
run curl -L -o /tini "https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini" \
 && curl -L -o /tini.asc "https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini.asc" \
 && gpg \
      --keyserver ha.pool.sks-keyservers.net \
      --recv-keys 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7 \
 && gpg --verify /tini.asc /tini \
 && rm /tini.asc \
 && chmod +x /tini
ENTRYPOINT ["/tini", "--"]

# gqrx
RUN add-apt-repository --yes ppa:ettusresearch/uhd \
 && add-apt-repository --yes ppa:myriadrf/drivers \
 && add-apt-repository --yes ppa:myriadrf/gnuradio \
 && add-apt-repository --yes ppa:gqrx/gqrx-sdr \
 && apt-get update \
 && apt-get install --yes libvolk1-bin gqrx-sdr

# clean up
RUN apt-get purge --yes curl "${BUILD_PACKAGES}" \
 && rm -rf /var/lib/apt/lists/*

# run
CMD ["gqrx"]
