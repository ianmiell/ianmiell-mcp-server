SHELL := /bin/bash

BINARY ?= ianmiell-mcp-server
PKG ?= .
CMD ?= .
BUILD_DIR ?= bin
GO ?= go
SYSTEMD_SERVICE ?= ianmiell-mcp-server
SYSTEMD_INSTALL_FLAGS ?=

.PHONY: help build run test fmt vet tidy lint clean \
	systemd-install systemd-start systemd-stop systemd-restart \
	systemd-status systemd-logs systemd-enable systemd-disable

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
	@echo "  make systemd-install  Build and install systemd service (uses sudo)"
	@echo "  make systemd-start    Start systemd service"
	@echo "  make systemd-stop     Stop systemd service"
	@echo "  make systemd-restart  Restart systemd service"
	@echo "  make systemd-status   Show systemd service status"
	@echo "  make systemd-logs     Tail systemd service logs"
	@echo "  make systemd-enable   Enable service at boot"
	@echo "  make systemd-disable  Disable service at boot"

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

systemd-install: build
	sudo ./systemd/install-systemd.sh --service-name "$(SYSTEMD_SERVICE)" --binary "./$(BUILD_DIR)/$(BINARY)" $(SYSTEMD_INSTALL_FLAGS)

systemd-start:
	sudo systemctl start "$(SYSTEMD_SERVICE).service"

systemd-stop:
	sudo systemctl stop "$(SYSTEMD_SERVICE).service"

systemd-restart:
	sudo systemctl restart "$(SYSTEMD_SERVICE).service"

systemd-status:
	sudo systemctl status "$(SYSTEMD_SERVICE).service"

systemd-logs:
	sudo journalctl -u "$(SYSTEMD_SERVICE).service" -f

systemd-enable:
	sudo systemctl enable "$(SYSTEMD_SERVICE).service"

systemd-disable:
	sudo systemctl disable "$(SYSTEMD_SERVICE).service"
