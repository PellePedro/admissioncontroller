ARG GO_VERSION
FROM golang:${GO_VERSION:-1.17.5-alpine} AS delve

ENV GO111MODULE on
#
RUN apk update \
  && apk add git \
  && apk add gcc \
  && apk add libc-dev \
  && go install github.com/go-delve/delve/cmd/dlv@latest


FROM golang:${GO_VERSION:-1.17.5-alpine} AS runner

ENV GO111MODULE on
ARG BUILD_DIR
WORKDIR ${BUILD_DIR}
COPY . ${BUILD_DIR}

RUN go mod download

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -o controller cmd/main.go
RUN CGO_ENABLED=0 go get -ldflags "-s -w -extldflags '-static'" github.com/go-delve/delve/cmd/dlv

RUN CGO_ENABLED=0 go build -gcflags="-N -l" -o /admission-controller ./cmd/main.go

CMD ["sleep", "3600"]