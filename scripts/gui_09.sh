#!/usr/bin/env bash
# ==============================================================================
# Bitcoin Core v0.9.3 GUI Launcher (Wayland / Hyprland compatible)
# ==============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

BITCOIN_QT="${REPO_ROOT}/bitcoin_0.9/bitcoin-0.9.3/src/qt/bitcoin-qt"
DATADIR="${REPO_ROOT}/node_09"

mkdir -p "${DATADIR}"

if [ ! -f "${BITCOIN_QT}" ]; then
    echo "[-] Binary not found: ${BITCOIN_QT}"
    echo "    Compile inside nix-shell: cd nix/v0.9 && nix-shell --run 'make'"
    exit 1
fi

echo "Launching Bitcoin Core v0.9.3 GUI with datadir=${DATADIR}..."
export QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-xcb}"
exec nix-shell "${REPO_ROOT}/nix/v0.9/shell.nix" --run "${BITCOIN_QT} -datadir=${DATADIR} \"$@\""
