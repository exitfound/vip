FROM ubuntu:22.04 AS molecule-image

LABEL maintainer="Ivan Medaev"

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get -y install --no-install-recommends \
    apt-utils \
    bash-completion \
    build-essential \
    iproute2 \
    locales \
    python3 \
    python3-dev \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    software-properties-common \
    sudo \
    systemd \
    && pip3 install --no-cache-dir 'ansible-core>=2.17,<2.18' 'ansible>=10,<11' \
    && apt-get clean \
    && apt-get autoremove -y \
    && locale-gen en_US.UTF-8 \
    && mkdir /etc/bash_completion.d/ \
    && rm -rf /tmp/* /var/tmp/* \
    && rm -f /lib/systemd/system/systemd*udev* \
    && rm -f /lib/systemd/system/getty.target

CMD ["/lib/systemd/systemd"]
