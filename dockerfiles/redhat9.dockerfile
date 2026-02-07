FROM redhat/ubi9:latest AS molecule-image

LABEL maintainer="Ivan Medaev"

RUN dnf update -y \
    && dnf install -y \
        iproute \
        procps-ng \
        python3-devel \
        python3-pip \
        python3-wheel \
        sudo \
        systemd \
    && dnf clean all \
    && pip3 install --no-cache-dir --upgrade pip \
    && pip3 install --no-cache-dir 'ansible-core>=2.15,<2.16' 'ansible>=8,<9' \
    && rm -rf /usr/share/doc \
    && rm -rf /usr/share/man

CMD ["/usr/lib/systemd/systemd"]
