FROM dokken/centos-stream-9:main AS molecule-image

LABEL maintainer="Ivan Medaev"

RUN yum install -y dnf-plugins-core \
    && dnf config-manager --set-enabled crb \
    && dnf update -y \
    && dnf install -y \
        epel-release \
        epel-next-release \
        iproute \
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
