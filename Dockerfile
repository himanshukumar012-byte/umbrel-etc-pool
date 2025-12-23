FROM golang:1.21-alpine AS builder
RUN apk add --no-cache git make gcc musl-dev
WORKDIR /src
RUN git clone https://github.com/etclabscore/open-etc-pool.git
WORKDIR /src/open-etc-pool
RUN make

FROM alpine:3.20
RUN apk add --no-cache ca-certificates tzdata
WORKDIR /app
COPY --from=builder /src/open-etc-pool/build/bin/open-etc-pool /usr/local/bin/open-etc-pool
CMD ["open-etc-pool", "/app/config.json"]
