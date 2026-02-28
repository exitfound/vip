FROM registry.suse.com/bci/bci-init:16.0 AS molecule-image

LABEL maintainer="Ivan Medaev"

RUN echo "http1.1" > /root/.curlrc \
    && zypper update --no-recommends --force-resolution --no-confirm \
    && rm -f /usr/lib/zypp/plugins/services/container-suseconnect-zypp \
            /usr/lib/zypp/plugins/urlresolver/susecloud \
    && zypper addrepo --no-gpgcheck \
        http://cdn.opensuse.org/distribution/leap/16.0/repo/oss/x86_64 \
        leap_oss \
    && zypper addrepo --no-gpgcheck \
        http://cdn.opensuse.org/distribution/leap/16.0/repo/non-oss/x86_64 \
        leap_non_oss \
    && zypper --gpg-auto-import-keys refresh leap_oss leap_non_oss \
    && zypper install --no-recommends --no-confirm \
        iproute2 \
        python313 \
        python313-devel \
        python313-pip \
        python313-wheel \
        xz \
        sudo \
    && zypper clean --all \
    && python3.13 -m pip install --no-cache-dir --upgrade pip \
    && python3.13 -m pip install --no-cache-dir 'ansible-core>=2.19,<2.20' 'ansible>=12,<13' \
    && rm -rf /usr/share/doc \
    && rm -rf /usr/share/man

CMD ["/usr/lib/systemd/systemd"]
