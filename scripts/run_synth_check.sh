#!/usr/bin/env bash
# Vendor-neutral synthesis sanity check: GHDL --synth (flags inferred latches, multiple drivers,
# unsupported constructs) then yosys for generic cell statistics. These are NOT FPGA resource or
# timing results; they only show the design is synthesizable and latch-free.
# Usage: scripts/run_synth_check.sh [top]   (default secure_uart_crypto_top)
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p reports/synthesis build
TOP=${1:-secure_uart_crypto_top}
FILES=(rtl/uart_timing.vhd rtl/uart_rx.vhd rtl/uart_tx.vhd rtl/sync_fifo.vhd rtl/packet_parser.vhd
       rtl/aes_pkg.vhd rtl/aes128_key_expansion.vhd rtl/aes128_core.vhd rtl/ghash_mult.vhd rtl/aes_gcm_engine.vhd
       rtl/key_manager.vhd rtl/packet_builder.vhd rtl/crypto_controller.vhd rtl/secure_uart_crypto_top.vhd)
LOG=reports/synthesis/ghdl_synth_${TOP}.log
ghdl --synth --std=08 --workdir=build --out=verilog "${FILES[@]}" -e "$TOP" > reports/synthesis/${TOP}.v 2> "$LOG" || { cat "$LOG"; exit 1; }
echo "ghdl --synth warnings/errors for $TOP:"; grep -iE "latch|multiple|driver|warning|error" "$LOG" || echo "  none"
yosys -q -p "read_verilog reports/synthesis/${TOP}.v; hierarchy -top ${TOP}; proc; opt; check -assert; tee -o reports/synthesis/yosys_${TOP}_stat.txt stat" >/dev/null
grep -E 'Number of cells|=== ' reports/synthesis/yosys_${TOP}_stat.txt | head -12
