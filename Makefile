SHELL := /bin/bash

BINARY ?= ianmiell-mcp-server
PKG ?= .
CMD ?= .
BUILD_DIR ?= bin
GO ?= go
SYSTEMD_SERVICE ?= ianmiell-mcp-server
SYSTEMD_INSTALL_FLAGS ?=
SYSTEMD_UNIT_DIR ?= /etc/systemd/system
SYSTEMD_INSTALL_DIR ?= /opt/ianmiell-mcp-server
SYSTEMD_ENV_DIR ?= /etc/default
NGINX_CONF ?= nginx/ianmiell-mcp-server.conf
NGINX_SITES_AVAILABLE ?= /etc/nginx/sites-available
NGINX_SITES_ENABLED ?= /etc/nginx/sites-enabled
NGINX_CONF_NAME ?= ianmiell-mcp-server

.PHONY: help build run test fmt vet tidy lint clean \
	systemd-install systemd-uninstall systemd-start systemd-stop systemd-restart \
	systemd-status systemd-logs systemd-enable systemd-disable \
	systemd-daemon-reload systemd-verify \
	nginx-install nginx-uninstall nginx-enable nginx-disable nginx-reload nginx-test

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
	@echo "  make systemd-install      Build and install systemd service (uses sudo)"
	@echo "  make systemd-uninstall    Stop, disable and remove systemd service files (uses sudo)"
	@echo "  make systemd-start        Start systemd service"
	@echo "  make systemd-stop     Stop systemd service"
	@echo "  make systemd-restart  Restart systemd service"
	@echo "  make systemd-status   Show systemd service status"
	@echo "  make systemd-logs     Tail systemd service logs"
	@echo "  make systemd-enable       Enable service at boot"
	@echo "  make systemd-disable      Disable service at boot"
	@echo "  make systemd-daemon-reload  Reload systemd unit files"
	@echo "  make systemd-verify       Verify service unit file syntax"
	@echo "  make nginx-install    Install nginx config to sites-available (uses sudo)"
	@echo "  make nginx-uninstall  Remove nginx config from sites-available and sites-enabled (uses sudo)"
	@echo "  make nginx-enable     Symlink config into sites-enabled (uses sudo)"
	@echo "  make nginx-disable    Remove symlink from sites-enabled (uses sudo)"
	@echo "  make nginx-test       Test nginx configuration"
	@echo "  make nginx-reload     Reload nginx (uses sudo)"

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

systemd-uninstall: systemd-disable systemd-stop
	sudo rm -f "$(SYSTEMD_UNIT_DIR)/$(SYSTEMD_SERVICE).service"
	sudo rm -f "$(SYSTEMD_INSTALL_DIR)/$(SYSTEMD_SERVICE)"
	sudo systemctl daemon-reload

systemd-daemon-reload:
	sudo systemctl daemon-reload

systemd-verify:
	systemd-analyze verify "$(SYSTEMD_UNIT_DIR)/$(SYSTEMD_SERVICE).service"

nginx-install:
	sudo cp "$(NGINX_CONF)" "$(NGINX_SITES_AVAILABLE)/$(NGINX_CONF_NAME)"

nginx-uninstall: nginx-disable
	sudo rm -f "$(NGINX_SITES_AVAILABLE)/$(NGINX_CONF_NAME)"

nginx-enable:
	sudo ln -sf "$(NGINX_SITES_AVAILABLE)/$(NGINX_CONF_NAME)" "$(NGINX_SITES_ENABLED)/$(NGINX_CONF_NAME)"

nginx-disable:
	sudo rm -f "$(NGINX_SITES_ENABLED)/$(NGINX_CONF_NAME)"

nginx-test:
	sudo nginx -t

nginx-reload:
	sudo systemctl reload nginx
