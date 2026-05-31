#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="ianmiell-mcp-server"
SERVICE_SRC="systemd/ianmiell-mcp-server.service"
ENV_SRC="systemd/ianmiell-mcp-server.env"
INSTALL_DIR="/opt/ianmiell-mcp-server"
SYSTEMD_DIR="/etc/systemd/system"
DEFAULTS_DIR="/etc/default"
USER_NAME="imiell"
GROUP_NAME="imiell"
BINARY_PATH="${INSTALL_DIR}/ianmiell-mcp-server"

usage() {
    cat <<USAGE
Usage: $0 [options]

Options:
  --service-name NAME   Systemd service basename (default: ${SERVICE_NAME})
  --install-dir DIR     Install directory for binary (default: ${INSTALL_DIR})
  --binary PATH         Source binary to install (default: ./bin/ianmiell-mcp-server)
  --user USER           Service user (default: ${USER_NAME})
  --group GROUP         Service group (default: ${GROUP_NAME})
  --no-enable           Do not run systemctl enable --now
  -h, --help            Show this help text

Examples:
  sudo $0
  sudo $0 --binary ./my-mcp-server --user mcp --group mcp
USAGE
}

ENABLE_NOW=true
SOURCE_BINARY="./bin/ianmiell-mcp-server"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --service-name)
            SERVICE_NAME="$2"
            shift 2
            ;;
        --install-dir)
            INSTALL_DIR="$2"
            shift 2
            ;;
        --binary)
            SOURCE_BINARY="$2"
            shift 2
            ;;
        --user)
            USER_NAME="$2"
            shift 2
            ;;
        --group)
            GROUP_NAME="$2"
            shift 2
            ;;
        --no-enable)
            ENABLE_NOW=false
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

SERVICE_FILE="${SYSTEMD_DIR}/${SERVICE_NAME}.service"
ENV_FILE="${DEFAULTS_DIR}/${SERVICE_NAME}"
BINARY_PATH="${INSTALL_DIR}/${SERVICE_NAME}"

if [[ "${EUID}" -ne 0 ]]; then
    echo "Run as root (for example: sudo $0 ...)" >&2
    exit 1
fi

if [[ ! -f "${SOURCE_BINARY}" ]]; then
    echo "Binary not found: ${SOURCE_BINARY}" >&2
    echo "Build first with: make build" >&2
    exit 1
fi

if [[ ! -f "${SERVICE_SRC}" ]]; then
    echo "Missing service template: ${SERVICE_SRC}" >&2
    exit 1
fi

if [[ ! -f "${ENV_SRC}" ]]; then
    echo "Missing env template: ${ENV_SRC}" >&2
    exit 1
fi

install -d -m 0755 "${INSTALL_DIR}"
install -m 0755 "${SOURCE_BINARY}" "${BINARY_PATH}"

# Render service file from template, injecting selected user/group/paths.
tmp_service="$(mktemp)"
trap 'rm -f "${tmp_service}"' EXIT

sed \
    -e "s|^User=.*$|User=${USER_NAME}|" \
    -e "s|^Group=.*$|Group=${GROUP_NAME}|" \
    -e "s|^WorkingDirectory=.*$|WorkingDirectory=${INSTALL_DIR}|" \
    -e "s|^EnvironmentFile=.*$|EnvironmentFile=${ENV_FILE}|" \
    -e "s|^ExecStart=.*$|ExecStart=${BINARY_PATH}|" \
    -e "s|^ReadWritePaths=.*$|ReadWritePaths=${INSTALL_DIR}|" \
    "${SERVICE_SRC}" > "${tmp_service}"

install -m 0644 "${tmp_service}" "${SERVICE_FILE}"

if [[ ! -f "${ENV_FILE}" ]]; then
    install -m 0644 "${ENV_SRC}" "${ENV_FILE}"
    echo "Installed env file at ${ENV_FILE}"
else
    echo "Env file already exists at ${ENV_FILE}; leaving it unchanged"
fi

systemctl daemon-reload

if [[ "${ENABLE_NOW}" == "true" ]]; then
    systemctl enable --now "${SERVICE_NAME}.service"
    echo "Service enabled and started: ${SERVICE_NAME}.service"
else
    echo "Service installed but not enabled. Run:"
    echo "  systemctl enable --now ${SERVICE_NAME}.service"
fi

echo "Done. Check status with: systemctl status ${SERVICE_NAME}.service"
