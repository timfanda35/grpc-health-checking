# Builder
FROM golang:1.21 as builder

WORKDIR /src
COPY . /src

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /bin/grpc-health-checking main.go

# App
FROM scratch

COPY --from=builder /bin/grpc-health-checking /bin/grpc-health-checking

EXPOSE 8000
EXPOSE 8080

ENTRYPOINT ["/bin/grpc-health-checking"]
