FROM golang:1.21-alpine AS builder
RUN apk add --no-cache git make gcc musl-dev
WORKDIR /src
RUN git clone https://github.com/etclabscore/open-etc-pool.git
WORKDIR /src/open-etc-pool

# Show what we're building
RUN set -eux; ls -la; echo "---- Makefile (if exists) ----"; (ls -la Makefile && sed -n '1,200p' Makefile) || true

# Try make, but don't assume it produces a binary with a specific name
RUN set -eux; \
    echo "---- running make ----"; \
    make || true; \
    echo "---- tree (top) ----"; \
    find . -maxdepth 3 -type d -print; \
    echo "---- files that look like binaries ----"; \
    find . -maxdepth 6 -type f -perm -111 -print || true; \
    echo "---- go build fallback ----"; \
    if [ -f "go.mod" ]; then \
      go build -v -o /tmp/open-etc-pool ./... || true; \
      # If ./... fails (multiple mains), try common main locations:
      go build -v -o /tmp/open-etc-pool . || true; \
      go build -v -o /tmp/open-etc-pool ./cmd/... || true; \
    fi; \
    test -f /tmp/open-etc-pool

FROM alpine:3.20
RUN apk add --no-cache ca-certificates tzdata
WORKDIR /app
COPY --from=builder /tmp/open-etc-pool /usr/local/bin/open-etc-pool
CMD ["open-etc-pool", "/app/config.json"]
