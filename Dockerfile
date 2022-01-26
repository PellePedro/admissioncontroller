ARG ALPINE_VERSION=3.14
ARG GO_VERSION=1.17

FROM golang:${GO_VERSION}-alpine${ALPINE_VERSION} AS builder

WORKDIR /build

COPY go.mod go.mod
COPY go.sum go.sum

RUN go mod download

COPY cmd/ cmd/
COPY pkg/ pkg/

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -o controller cmd/main.go

#----------------------------------------------------------------
# Controller
FROM alpine:${ALPINE_VERSION}
COPY --from=builder /build/controller /usr/local/bin/controller 
CMD ["/usr/local/bin/controller"]