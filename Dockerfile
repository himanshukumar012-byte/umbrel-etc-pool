FROM golang:1.21-alpine AS builder
RUN apk add --no-cache git make gcc musl-dev
WORKDIR /src
RUN git clone https://github.com/etclabscore/open-etc-pool.git
WORKDIR /src/open-etc-pool

# Build
RUN make || (echo "MAKE FAILED" && ls -la && exit 1)

# Find the built binary (path differs by repo/build)
RUN set -eux; \
    find /src/open-etc-pool -maxdepth 5 -type f -name "open-etc-pool" -print; \
    BIN="$(find /src/open-etc-pool -maxdepth 6 -type f -name 'open-etc-pool' | head -n 1)"; \
    if [ -z "$BIN" ]; then echo "open-etc-pool binary not found after build"; find /src/open-etc-pool -maxdepth 6 -type f -print; exit 1; fi; \
    cp "$BIN" /tmp/open-etc-pool

FROM alpine:3.20
RUN apk add --no-cache ca-certificates tzdata
WORKDIR /app
COPY --from=builder /tmp/open-etc-pool /usr/local/bin/open-etc-pool
CMD ["open-etc-pool", "/app/config.json"]
