ARG VERSION

FROM hashicorp/vault:${VERSION} AS base

ENV USER=vault

LABEL maintainer="Ivan Medaev"

USER root

RUN apk --no-cache add shadow \
    && usermod --uid 1000 ${USER} \
    && mkdir -p /opt/vault/data \
    && chown -R ${USER}:${USER} /opt/vault/data /vault/* \
    && apk del shadow

USER ${USER}

COPY ./properties/config/config.hcl /vault/config/

EXPOSE 8200

HEALTHCHECK --interval=5m --timeout=3s CMD ["curl", "-f", "http://localhost:8200 || exit 1"]
