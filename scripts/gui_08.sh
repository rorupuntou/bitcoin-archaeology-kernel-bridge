#!/usr/bin/env bash
echo "Deteniendo daemon previo en node_08 si existe..."
/home/roru/bitcoin_satoshi2/bitcoin_0.8/bitcoin-0.8.0/src/bitcoind -datadir=/home/roru/bitcoin_satoshi2/node_08 stop 2>/dev/null
while pgrep -f "node_08.*bitcoind" > /dev/null; do sleep 0.5; done

echo "Lanzando Bitcoin Core v0.8.0 GUI..."
export QT_PLUGIN_PATH=/nix/store/64qmp7fap3740hxd2bsnpy10s9ndy5qx-qtbase-5.15.18-bin/lib/qt-5.15.18/plugins
export QT_QPA_PLATFORM=xcb
exec /home/roru/bitcoin_satoshi2/bitcoin_0.8/bitcoin-0.8.0/bitcoin-qt -datadir=/home/roru/bitcoin_satoshi2/node_08 "$@"
