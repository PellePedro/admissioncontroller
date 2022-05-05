ARG GO_VERSION
FROM golang:${GO_VERSION:-1.17.5-alpine} AS builder

ENV GO111MODULE on
ARG BUILD_DIR
WORKDIR ${BUILD_DIR}
COPY . ${BUILD_DIR}

RUN go mod download
# RUN CGO_ENABLED=0 go get -ldflags "-s -w -extldflags '-static'" github.com/go-delve/delve/cmd/dlv

RUN CGO_ENABLED=0 go build -gcflags="-N -l" -o /target ./cmd/main.go

FROM alpine:3.14.5
COPY --from=builder /target /usr/local/bin/admission-controller
CMD ["/usr/local/bin/admission-controller"]