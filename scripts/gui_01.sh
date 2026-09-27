#!/usr/bin/env bash
echo "Deteniendo daemon previo en node_08 si existe..."
/home/roru/bitcoin_satoshi2/bitcoin_0.8/bitcoin-0.8.0/src/bitcoind -datadir=/home/roru/bitcoin_satoshi2/node_08 stop 2>/dev/null
while pgrep -f "node_08.*bitcoind" > /dev/null; do sleep 0.5; done

echo "Lanzando Bitcoin v0.01 / v0.1 GUI..."
nix-shell /home/roru/bitcoin_satoshi2/shell.nix --run "/home/roru/bitcoin_satoshi2/bitcoin -datadir=/home/roru/bitcoin_satoshi2/node_08 $@"
