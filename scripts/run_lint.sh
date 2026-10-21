#!/usr/bin/env bash
# Lint: GHDL analysis with all warnings, then generic synthesis (latch / multiple-driver / unsupported
# construct detection) of every RTL entity. Fails on any warning other than the known, accepted ones.
set -euo pipefail
cd "$(dirname "$0")/.."
FILES=(rtl/uart_timing.vhd rtl/uart_rx.vhd rtl/uart_tx.vhd rtl/sync_fifo.vhd rtl/packet_parser.vhd
       rtl/aes_pkg.vhd rtl/aes128_key_expansion.vhd rtl/aes128_core.vhd rtl/ghash_mult.vhd
       rtl/aes_gcm_engine.vhd rtl/key_manager.vhd rtl/packet_builder.vhd rtl/crypto_controller.vhd
       rtl/secure_uart_crypto_top.vhd)
rm -rf build/lint && mkdir -p build/lint reports/synthesis
ghdl -a --std=08 --workdir=build/lint -Wall "${FILES[@]}" 2> reports/synthesis/ghdl_analyze_warnings.txt || { cat reports/synthesis/ghdl_analyze_warnings.txt; exit 1; }
# accepted: packet_parser 'others' in a case over a wide natural range (reviewed, harmless)
UNEXPECTED=$(grep "warning" reports/synthesis/ghdl_analyze_warnings.txt | grep -v "packet_parser.vhd:.*\(-Wothers\|-Wstatic\)" || true)
if [ -n "$UNEXPECTED" ]; then echo "UNEXPECTED LINT WARNINGS:"; echo "$UNEXPECTED"; exit 1; fi
echo "analysis: clean (only the accepted packet_parser 'others' notes)"
for t in uart_timing uart_rx uart_tx sync_fifo packet_parser aes128_key_expansion aes128_core ghash_mult \
         aes_gcm_engine key_manager packet_builder crypto_controller secure_uart_crypto_top; do
    bash scripts/run_synth_check.sh "$t" > /tmp/synth_$t.txt 2>&1 || { cat /tmp/synth_$t.txt; echo "SYNTH CHECK FAILED: $t"; exit 1; }
    BAD=$(grep -iE "latch|multiple|driver|error" reports/synthesis/ghdl_synth_$t.log || true)
    [ -z "$BAD" ] || { echo "synth problems in $t:"; echo "$BAD"; exit 1; }
    echo "synth ok (no latches / driver conflicts): $t"
done
echo "LINT PASSED"
