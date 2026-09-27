#!/usr/bin/env bash
echo "Deteniendo daemon previo en node_09 si existe..."
/home/roru/bitcoin_satoshi2/bitcoin_0.9/bitcoin-0.9.3/src/bitcoind -datadir=/home/roru/bitcoin_satoshi2/node_09 stop 2>/dev/null
while pgrep -f "node_09.*bitcoind" > /dev/null; do sleep 0.5; done

echo "Lanzando Bitcoin Core v0.9.3 GUI..."
export QT_PLUGIN_PATH=/nix/store/64qmp7fap3740hxd2bsnpy10s9ndy5qx-qtbase-5.15.18-bin/lib/qt-5.15.18/plugins
export QT_QPA_PLATFORM=xcb
exec /home/roru/bitcoin_satoshi2/bitcoin_0.9/bitcoin-0.9.3/src/qt/bitcoin-qt -datadir=/home/roru/bitcoin_satoshi2/node_09 "$@"
