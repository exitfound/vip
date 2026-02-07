ARG VERSION

FROM hashicorp/vault:${VERSION} AS base

LABEL maintainer="Ivan Medaev"

ENV USER=vault

USER root

RUN apk --no-cache add shadow \
    && usermod --uid 1000 ${USER} \
    && groupmod --gid 1000 ${USER} \
    && mkdir -p /opt/vault/data \
    && chown -R ${USER}:${USER} /opt/vault/data /vault/* \
    && apk del shadow

USER ${USER}

EXPOSE 8200

HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://127.0.0.1:8200/v1/sys/health?standbyok=true || exit 1
