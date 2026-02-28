FROM opensuse/leap:15.6 AS leap-repos

FROM registry.suse.com/bci/bci-init:15.6 AS molecule-image

LABEL maintainer="Ivan Medaev"

COPY --from=leap-repos /etc/zypp/repos.d/ /etc/zypp/repos.d/

RUN echo "http1.1" > /root/.curlrc \
    && rm -rf /etc/zypp/services.d/ \
        /usr/lib/zypp/plugins/services/container-suseconnect* \
    && zypper --gpg-auto-import-keys refresh \
    && zypper update --no-recommends --force-resolution --no-confirm \
    && zypper install --no-recommends --no-confirm \
        iproute2 \
        python311 \
        python311-devel \
        python311-pip \
        xz \
        sudo \
    && zypper clean --all \
    && python3.11 -m pip install --no-cache-dir --upgrade pip \
    && python3.11 -m pip install --no-cache-dir 'ansible-core>=2.19,<2.20' 'ansible>=12,<13' \
    && rm -rf /usr/share/doc \
    && rm -rf /usr/share/man

CMD ["/usr/lib/systemd/systemd"]
