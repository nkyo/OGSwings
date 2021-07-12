# Stage 1 (Build)
FROM --platform=$BUILDPLATFORM golang:1.16-alpine3.13 AS builder

ARG VERSION
RUN apk add --update --no-cache git make upx
WORKDIR /app/
COPY go.mod go.sum /app/
RUN go mod download
COPY . /app/
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -ldflags="-s -w -X github.com/pterodactyl/wings/system.Version=$VERSION" \
    -v \
    -trimpath \
    -o wings \
    wings.go
RUN upx wings

# Stage 2 (Final)
FROM busybox:1.33.0
RUN echo "ID=\"busybox\"" > /etc/os-release
COPY --from=builder /app/wings /usr/bin/
CMD [ "/usr/bin/wings", "--config", "/etc/pterodactyl/config.yml" ]
