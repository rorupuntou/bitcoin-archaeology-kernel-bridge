#!/usr/bin/env bash
# ==============================================================================
# Bitcoin v0.01 / v0.1 ALPHA GUI Launcher (Wayland / Hyprland compatible)
# ==============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

BITCOIN_BIN="${REPO_ROOT}/bitcoin"
DATADIR="${REPO_ROOT}/node_01"

mkdir -p "${DATADIR}"

if [ ! -f "${BITCOIN_BIN}" ]; then
    echo "[-] Binary not found: ${BITCOIN_BIN}"
    echo "    Compile inside nix-shell: make -f src/makefile.unix"
    exit 1
fi

echo "Launching Bitcoin v0.01 / v0.1 ALPHA GUI with datadir=${DATADIR}..."
export QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-xcb}"
exec nix-shell "${REPO_ROOT}/shell.nix" --run "${BITCOIN_BIN} -datadir=${DATADIR} \"$@\""
