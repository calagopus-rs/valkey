ARG VALKEY_VERSION
ARG BUILD_RDMA=0
ARG ALPINE_VERSION=3.18

FROM --platform=$TARGETPLATFORM alpine:${ALPINE_VERSION} AS builder

ARG VALKEY_VERSION
ARG BUILD_RDMA
ENV VALKEY_VERSION=${VALKEY_VERSION}
ENV BUILD_RDMA=${BUILD_RDMA}

RUN apk add --no-cache \
    build-base \
    cmake \
    pkgconfig \
    linux-headers \
    perl \
    git \
    wget \
    openssl-dev \
    zlib-dev \
    bzip2-dev \
    ca-certificates

WORKDIR /src

RUN set -eux; \
    if [ -n "$VALKEY_VERSION" ]; then \
      VER="$VALKEY_VERSION"; \
    else \
      VER="$(wget -qO- https://api.github.com/repos/valkey-io/valkey/releases/latest | awk -F\" '/"tag_name":/ {print $4; exit}')" ; \
    fi; \
    echo "Building valkey version: $VER"; \
    wget -qO /tmp/valkey.tar.gz "https://github.com/valkey-io/valkey/archive/refs/tags/${VER}.tar.gz"; \
    tar -xzf /tmp/valkey.tar.gz --strip-components=1 -C /src

RUN set -eux; \
    uname -a || true; \
    NPROC=$(getconf _NPROCESSORS_ONLN || echo 1); \
    export VALKEY_DEBUG_BUILD=0; \
    make -C src -j${NPROC} BUILD_TLS=yes BUILD_RDMA=${BUILD_RDMA}

RUN set -eux; \
    cd src; \
    for f in valkey-server valkey-cli valkey-benchmark valkey-check-aof valkey-check-rdb; do \
      if [ -f "$f" ]; then strip "$f" || true; fi; \
    done

FROM alpine:${ALPINE_VERSION} AS runtime

RUN apk add --no-cache ca-certificates

COPY --from=builder /src/src/valkey-server /usr/local/bin/valkey-server
COPY --from=builder /src/src/valkey-cli /usr/local/bin/valkey-cli
COPY --from=builder /src/src/valkey-benchmark /usr/local/bin/valkey-benchmark
COPY --from=builder /src/src/valkey-check-aof /usr/local/bin/valkey-check-aof
COPY --from=builder /src/src/valkey-check-rdb /usr/local/bin/valkey-check-rdb

RUN chmod +x /usr/local/bin/valkey-server /usr/local/bin/valkey-cli /usr/local/bin/valkey-benchmark /usr/local/bin/valkey-check-aof /usr/local/bin/valkey-check-rdb || true

EXPOSE 6379

ENTRYPOINT ["/usr/local/bin/valkey-server"]
