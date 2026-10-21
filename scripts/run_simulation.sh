#!/usr/bin/env bash
# Analyse, elaborate and run all unit testbenches with GHDL (VHDL-2008).
# Usage: scripts/run_simulation.sh [testbench ...]   (default: all)
set -euo pipefail
cd "$(dirname "$0")/.."
STD=08
WORK=build
mkdir -p "$WORK"

RTL=(rtl/uart_timing.vhd rtl/uart_rx.vhd rtl/uart_tx.vhd rtl/sync_fifo.vhd rtl/packet_parser.vhd rtl/aes_pkg.vhd rtl/aes128_key_expansion.vhd rtl/aes128_core.vhd rtl/ghash_mult.vhd rtl/aes_gcm_engine.vhd rtl/key_manager.vhd rtl/packet_builder.vhd rtl/crypto_controller.vhd rtl/secure_uart_crypto_top.vhd)
TBS=("$@")
[ ${#TBS[@]} -eq 0 ] && TBS=(uart_timing_tb uart_rx_tb uart_tx_tb sync_fifo_tb packet_parser_tb aes128_key_expansion_tb aes128_core_tb packet_builder_tb aes_gcm_tb secure_uart_crypto_top_tb secure_uart_hardening_tb)

ghdl -a --std=$STD --workdir=$WORK "${RTL[@]}"
for tb in "${TBS[@]}"; do
    echo "=== $tb ==="
    ghdl -a --std=$STD --workdir=$WORK "tb/$tb.vhd"
    ghdl -e --std=$STD --workdir=$WORK "$tb"
    ghdl -r --std=$STD --workdir=$WORK "$tb" --assert-level=error
done
if [ "${SPEC_BAUD:-0}" = "1" ]; then
    echo "=== secure_uart_crypto_top_tb at the specified 9600 baud (slow) ==="
    ghdl -r --std=$STD --workdir=$WORK secure_uart_crypto_top_tb -gBAUD_G=9600 --assert-level=error
fi
echo "ALL TESTBENCHES PASSED"
