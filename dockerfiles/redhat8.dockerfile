FROM redhat/ubi8:latest AS molecule-image

LABEL maintainer="Ivan Medaev"

RUN dnf update -y \
    && dnf install -y \
        iproute \
        procps-ng \
        python3-devel \
        python3-pip \
        python3-wheel \
        openssl \
        sudo \
        systemd \
    && dnf clean all \
    && pip3 install --no-cache-dir --upgrade pip \
    && pip3 install --no-cache-dir 'ansible-core>=2.11,<2.12' 'ansible>=4,<5' \
    && rm -rf /usr/share/doc \
    && rm -rf /usr/share/man

CMD ["/usr/lib/systemd/systemd"]
