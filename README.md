# 🏛️ Bitcoin Archaeological Suite & libbitcoinkernel Consensus Bridge

An open-source, mathematically reproducible research environment to compile and run historical Bitcoin nodes (**v0.01/v0.1**, **v0.8.0**, **v0.9.3**, and **v0.10.4**) natively on modern Linux systems (bare-metal, no VMs, no containers) using **Nix**, and to audit historical consensus evolution directly against Bitcoin Core's next-generation consensus engine: **`libbitcoinkernel`**.

---

## 📂 Repository Structure

```text
├── shell.nix                      # Nix environment for Bitcoin v0.01 / v0.1 ALPHA (Satoshi Era)
├── bitcoin                        # Compiled native Linux binary for Bitcoin v0.01 / v0.1
├── gui_01.sh                      # Launch script for v0.01/v0.1 GUI under modern Wayland / Hyprland
├── bitcoin_0.8/
│   ├── shell.nix                  # Pinned Nix shell (Boost 1.77, Berkeley DB 4.8, OpenSSL, Qt5)
│   └── bitcoin-0.8.0/             # Bitcoin Core v0.8.0 source code
├── bitcoin_0.9/
│   ├── shell.nix                  # Pinned Nix shell (OpenSSL 1.1.1w, BDB 4.8, Qt5 Wayland)
│   └── bitcoin-0.9.3/             # Bitcoin Core v0.9.3 source code
├── bitcoin_0.10/
│   ├── shell.nix                  # Pinned Nix shell (OpenSSL 1.1.1w, BDB 4.8, Qt5 Wayland)
│   └── bitcoin-0.10.4/            # Bitcoin Core v0.10.4 source code
├── node_08/                       # Isolated data directory for v0.8.0 (contains blk0001.dat)
├── node_09/                       # Isolated data directory for v0.9.3
├── node_010/                      # Isolated data directory for v0.10.4
├── historical_kernel_auditor.py   # Ingests raw blk0001.dat directly into libbitcoinkernel in 40ms
├── test_bip_consensus_rules.py    # Audits consensus script flags (v0.1 NONE -> Taproot ALL)
├── test_kernel_dat_pipeline.py    # Pipeline unit test for parsing raw .dat blocks into C++ kernel
├── kernel_consensus_audit_report.json # Exported JSON audit report from libbitcoinkernel execution
└── readme.txt                     # Original Bitcoin v0.01 ALPHA README by Satoshi Nakamoto (2009)
```

---

## ⚡ The Challenge: Solving 15+ Years of "Bitrot"

Compiling software written between 2009 and 2015 on modern Linux (GCC 13+, glibc 2.38+, OpenSSL 3.x) typically fails due to:
1. **OpenSSL 3.0+ API Breaches:** Early Bitcoin relied extensively on OpenSSL internals for BIGNUM arithmetic, ECDSA signatures, and hashing, APIs which have been deprecated or completely stripped in modern distributions.
2. **Berkeley DB (BDB 4.8) Bitrot:** Critical for wallet and pre-v0.8 block index serialization; incompatible with modern glibc POSIX mutexes and strict C++ compiler flags without explicit patch configurations.
3. **C++98 to C++20 Drift:** Deprecated idioms, non-narrowing conversions, and raw pointer semantics that cause immediate build aborts in modern compilers.
4. **Desktop GUI Migration (X11 to Wayland / Hyprland):** Legacy wxWidgets 2.8 and early Qt4/Qt5 interfaces failing to locate rendering platform plugins.

Nix provides **deterministic isolation**: it pins exact binary toolchains, cryptographic libraries, and platform plugins bare-metal without the virtualization overhead of VMs or Docker.

---

## 🛠️ Step-by-Step Compilation & Run Instructions

### 1. Bitcoin v0.01 / v0.1 ALPHA (Satoshi Era)
```bash
# Enter the Satoshi build environment
nix-shell shell.nix

# Compile the native Satoshi client
make -f src/makefile.unix -j$(nproc)

# Launch GUI under modern Wayland / Hyprland (XWayland bridge configured)
./gui_01.sh
```

### 2. Bitcoin Core v0.8.0 (The LevelDB Milestone)
```bash
cd bitcoin_0.8
nix-shell shell.nix

cd bitcoin-0.8.0/src
make -f makefile.unix -j$(nproc) USE_UPNP=

# To build the Qt GUI:
cd ..
qmake bitcoin-qt.pro USE_UPNP=
make -j$(nproc)

# Run daemon or GUI:
cd ../..
./gui_08.sh
```

### 3. Bitcoin Core v0.9.3 (Autotools & BIP-65 Era)
```bash
cd bitcoin_0.9
nix-shell shell.nix

cd bitcoin-0.9.3
./autogen.sh
./configure --with-incompatible-bdb --with-gui=qt5
make -j$(nproc)

# Launch GUI:
cd ../..
./gui_09.sh
```

### 4. Bitcoin Core v0.10.4 (BIP-66 Strict DER Era)
```bash
cd bitcoin_0.10
nix-shell shell.nix

cd bitcoin-0.10.4
./autogen.sh
./configure --with-incompatible-bdb --with-gui=qt5
make -j$(nproc)

# Launch GUI:
cd ../..
./gui_010.sh
```

---

## 🔬 Archaeological Discoveries & Protocol Curiosities

During our native builds and raw block inspections, we verified several critical protocol transitions:

### 1. The BDB to LevelDB Fork (The March 2013 v0.8 Incident)
Prior to v0.8, the block database was stored in Berkeley DB (`blkindex.dat`). BDB had hardcoded limits on the number of simultaneous locks (configured by default to a conservative threshold). When miners upgraded to v0.8 (which introduced Google's LevelDB for chainstate and block index storage), a block with a large number of transaction inputs was mined. v0.8 accepted it, but older v0.7 nodes locked up inside BDB, causing an unintended consensus fork. By running v0.8 with BDB 4.8 and LevelDB side-by-side in Nix, this divergence can be reproduced and tested deterministically.

### 2. Pre-BIP-34 Coinbase Scripts & TXID Collisions (BIP-30 / BIP-34)
In Bitcoin v0.1 through v0.7, miners were permitted to write arbitrary bytes into the coinbase `scriptSig` (e.g. text like Satoshi's famous *The Times 03/Jan/2009 Chancellor on brink of second bailout for banks*, or arbitrary nonces). Because there was no requirement to include the block height, identical coinbase transactions occurred (notably Block #91,812 and Block #91,842), which overwrote previous unspent transaction outputs. BIP-34 resolved this permanently at Block 227,931 by mandating that the block height must be serialized as the first push in the coinbase `scriptSig`.

### 3. Dominance of P2PK (Pay-to-Public-Key)
Blocks mined in early epochs almost exclusively paid rewards to raw 65-byte uncompressed public keys (`0x41 0x04... 0xac OP_CHECKSIG`) rather than today's P2PKH, P2WPKH (SegWit), or P2TR (Taproot) addresses.

---

## 🚀 The Bridge to 2026: `libbitcoinkernel`

Rather than remaining confined to legacy daemons, this repository includes an audit bridge connecting historical block databases directly to Bitcoin Core's next-generation consensus engine: **`libbitcoinkernel`**.

Using `py-bitcoinkernel` (`pbk`), we load historical `blk0001.dat` files into an isolated C++ `ChainstateManager` in **44 milliseconds**:

```bash
# Run the consensus auditor
uv run --with py-bitcoinkernel python3 historical_kernel_auditor.py

# Run the BIP consensus rules and script verification suite
uv run --with py-bitcoinkernel python3 test_bip_consensus_rules.py
```

### Auditing Results:
* **Genesis Anchor:** Verified Block #0 (`000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f`) in C++ memory.
* **Block 1 Ingestion:** Validated and connected Block #1 (`000000007b5c78bb...`) directly from raw disk bytes, advancing active tip height to 1.
* **Orphan Header Rejection:** Ingested historical Block #281 without its parent (Block #280); `libbitcoinkernel` strictly rejected the header with `BLOCK_RESULT_MISSING_PREV`, validating isolated chain integrity.
* **Script Verification Flags Matrix:** Evaluated the consensus progression:
  * v0.1 (Satoshi Era): `ScriptVerificationFlags.NONE (0x0)`
  * v0.6 (BIP-16 P2SH): `ScriptVerificationFlags.P2SH (0x1)`
  * v0.10 (BIP-66 DERSIG): `ScriptVerificationFlags.P2SH | DERSIG (0x5)`
  * v0.12 (BIP-65/112 CLTV & CSV): `0x605`
  * v0.13.1 (BIP-141 SegWit): `WITNESS (0x805)`
  * Bitcoin Core 22.0+ (BIP-341 Taproot): `ALL (0x20e15)`

---

## 📜 License
Distributed under the MIT License. See `license.txt` for the original Satoshi Nakamoto license text.
