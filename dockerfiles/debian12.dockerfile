FROM debian:bookworm AS molecule-image

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
        sudo \
        systemd \
    && pip3 install --break-system-packages 'ansible-core>=2.19,<2.20' 'ansible>=12,<13' \
    && apt-get clean \
    && apt-get autoremove -y \
    && mkdir /etc/bash_completion.d/ \
    && locale-gen en_US.UTF-8 \
    && rm -rf /tmp/* /var/tmp/* \
    && rm -f /lib/systemd/system/systemd*udev* \
    && rm -f /lib/systemd/system/getty.target

CMD ["/lib/systemd/systemd"]
