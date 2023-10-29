GOPATH = $(shell go env GOPATH)

.PHONY: compile
compile: compile-server

.PHONY: clean
clean:
	rm -rf target

target:
	mkdir target

.PHONY: compile-server
compile-server: target
	go build -o target/grpc-health-checking ./main.go
