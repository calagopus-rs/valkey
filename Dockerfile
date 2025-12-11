FROM alpine:3.18 AS builder

ARG TARGETARCH
WORKDIR /out

COPY docker-bins/${TARGETARCH}/ /out/

RUN set -eux; \
    for f in /out/*; do \
      base=$(basename "$f"); \
      case "$base" in \
        valkey-server-*-linux) mv "$f" /out/valkey-server ;; \
        valkey-cli-*-linux) mv "$f" /out/valkey-cli ;; \
        valkey-benchmark-*-linux) mv "$f" /out/valkey-benchmark ;; \
        valkey-check-aof-*-linux) mv "$f" /out/valkey-check-aof ;; \
        valkey-check-rdb-*-linux) mv "$f" /out/valkey-check-rdb ;; \
        *) : ;; \
      esac; \
    done; \
    chmod +x /out/* || true

FROM alpine:3.18 AS runtime

RUN apk add --no-cache ca-certificates

COPY --from=builder /out/ /usr/local/bin/

EXPOSE 6379

ENTRYPOINT ["/usr/local/bin/valkey-server"]