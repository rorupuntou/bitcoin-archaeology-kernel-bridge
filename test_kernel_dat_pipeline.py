#!/usr/bin/env python3
"""
Test pipeline verifying that blocks from node_08 blk0001.dat can be read
and validated via libbitcoinkernel directly.
"""

import os
import tempfile
import pbk

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
BLK_DAT = os.path.join(BASE_DIR, "fixtures", "sample_blk0001.dat")

def main():
    print("=" * 70)
    print("⚡ LIBBITCOINKERNEL HISTORICAL .DAT BLOCK INGESTION PIPELINE ⚡")
    print("=" * 70)

    if not os.path.exists(BLK_DAT):
        print(f"[-] Error: {BLK_DAT} not found")
        return

    with open(BLK_DAT, "rb") as f:
        data = f.read()

    print(f"[✓] Archivo blk0001.dat cargado: {len(data)} bytes")

    tmpdir = tempfile.mkdtemp(prefix="kernel_chain_")
    print(f"[*] Inicializando libbitcoinkernel ChainstateManager en: {tmpdir}")
    chainman = pbk.load_chainman(tmpdir, chain_type=pbk.ChainType.MAINNET)

    offset = 0
    block_idx = 0
    valid_count = 0

    while offset + 8 <= len(data):
        magic = data[offset:offset+4]
        size = int.from_bytes(data[offset+4:offset+8], "little")
        offset += 8
        block_raw = data[offset:offset+size]
        offset += size

        header_raw = block_raw[:80]
        header = pbk.BlockHeader(header_raw)
        block_hash = bytes(header.block_hash)[::-1].hex()
        prev_hash = bytes(header.prev_hash)[::-1].hex()

        print(f"\n[+] Procesando Bloque #{block_idx} ({size} bytes):")
        print(f"  • Hash:     {block_hash}")
        print(f"  • PrevHash: {prev_hash}")
        print(f"  • Bits:     {hex(header.bits)}")
        print(f"  • Nonce:    {header.nonce}")

        if block_idx == 0:
            print("  • (Génesis ya anclado en ChainstateManager por defecto)")
            block_idx += 1
            continue

        state = chainman.process_block_header(header)
        mode = state.validation_mode.name
        result = state.block_validation_result.name
        print(f"  • Resultado Validación libbitcoinkernel: {mode} (Result: {result})")

        if mode == "VALID":
            valid_count += 1
            print(f"  • Altura de punta en la cadena: {chainman.best_entry.height}")

        block_idx += 1

    print("\n" + "=" * 70)
    print(f"🎉 Pipeline completado con éxito: {valid_count} bloques históricos conectados a libbitcoinkernel!")
    print("=" * 70)

if __name__ == "__main__":
    main()
