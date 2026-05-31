SHELL := /bin/bash

BINARY ?= ianmiell-mcp-server
PKG ?= .
CMD ?= .
BUILD_DIR ?= bin
GO ?= go

.PHONY: help build run test fmt vet tidy lint clean

help:
	@echo "Targets:"
	@echo "  make build   Build binary to $(BUILD_DIR)/$(BINARY)"
	@echo "  make run     Run server (use MCP_* env vars to configure)"
	@echo "  make test    Run tests"
	@echo "  make fmt     Format Go code"
	@echo "  make vet     Run go vet"
	@echo "  make tidy    Tidy module dependencies"
	@echo "  make lint    Run fmt + vet + test"
	@echo "  make clean   Remove build artifacts"

build:
	@mkdir -p $(BUILD_DIR)
	$(GO) build -o $(BUILD_DIR)/$(BINARY) $(CMD)

run:
	$(GO) run $(CMD)

test:
	$(GO) test ./...

fmt:
	$(GO) fmt ./...

vet:
	$(GO) vet ./...

tidy:
	$(GO) mod tidy

lint: fmt vet test

clean:
	rm -rf $(BUILD_DIR)
