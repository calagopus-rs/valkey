FROM debian:bookworm-slim

ARG TARGETARCH
ARG VALKEY_VERSION

LABEL org.opencontainers.image.title="Valkey"
LABEL org.opencontainers.image.description="Multi-architecture Valkey builds"
LABEL org.opencontainers.image.version="${VALKEY_VERSION}"
LABEL org.opencontainers.image.source="https://github.com/calagopus-rs/valkey"
LABEL org.opencontainers.image.licenses="BSD-3-Clause"

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    libssl3 \
    tzdata && \
    rm -rf /var/lib/apt/lists/*

# Create valkey user and group
RUN groupadd -r -g 999 valkey && \
    useradd -r -g valkey -u 999 -m -d /data valkey

# Map Docker platform to our architecture naming
# amd64 -> x86_64, arm64 -> aarch64, etc.
RUN case "${TARGETARCH}" in \
    "amd64")   echo "x86_64"   > /tmp/arch ;; \
    "arm64")   echo "aarch64"  > /tmp/arch ;; \
    "ppc64le") echo "ppc64le"  > /tmp/arch ;; \
    "s390x")   echo "s390x"    > /tmp/arch ;; \
    "riscv64") echo "riscv64"  > /tmp/arch ;; \
    *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac

# Copy pre-built binaries for the target architecture
COPY docker-bins/$(cat /tmp/arch)/* /usr/local/bin/

# Create symlinks with standard names
RUN cd /usr/local/bin && \
    ARCH=$(cat /tmp/arch) && \
    ln -s valkey-server-${ARCH}-linux valkey-server && \
    ln -s valkey-cli-${ARCH}-linux valkey-cli && \
    ln -s valkey-benchmark-${ARCH}-linux valkey-benchmark && \
    ln -s valkey-check-aof-${ARCH}-linux valkey-check-aof && \
    ln -s valkey-check-rdb-${ARCH}-linux valkey-check-rdb && \
    rm /tmp/arch

# Create directories
RUN mkdir -p /data /etc/valkey && \
    chown -R valkey:valkey /data /etc/valkey

WORKDIR /data

VOLUME /data

# Expose default Valkey port
EXPOSE 6379

USER valkey

ENTRYPOINT ["valkey-server"]
CMD []
