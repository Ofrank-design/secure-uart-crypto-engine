# Secure UART Data Crypto Engine

FPGA design in **VHDL-2008**: 50 MHz clock, UART 9600 baud 8-N-1, AES-128-GCM authenticated encryption over a framed packet protocol.
Status: **verified in simulation; not yet synthesised for or run on any real FPGA** (no target was specified). Production-ready: **no** (see `docs/audit-matrix.md`).

## Requirements to build and test
GHDL 4.x (mcode ok), Python 3 with `cryptography` (vector generation, host tool), yosys (lint/synthesis check). Optional: `pyserial` for the host tool.

## Commands
    bash scripts/run_regression.sh              # everything: vectors, lint+synthesis check, all testbenches, host-tool self-test, manifest
    bash scripts/run_simulation.sh [tb ...]     # testbenches only (default: all)
    SPEC_BAUD=1 bash scripts/run_simulation.sh  # also run the end-to-end test at 9600 baud (about 10 minutes)
    bash scripts/run_lint.sh                    # GHDL -Wall + latch/driver check of every module
    python3 scripts/gen_gcm_vectors.py          # regenerate OpenSSL GCM vectors
    python3 scripts/gen_e2e_vectors.py          # regenerate wire-level end-to-end vectors
    python3 scripts/gen_module_docs.py          # regenerate docs/module-interfaces.md
    python3 scripts/host_tool.py --selftest     # host-side frame tool check (use --port for real hardware)

## Layout
    rtl/    uart_timing, uart_rx, uart_tx, sync_fifo, packet_parser, packet_builder, aes_pkg, aes128_key_expansion,
            aes128_core, ghash_mult, aes_gcm_engine, key_manager, crypto_controller, secure_uart_crypto_top
    tb/     one self-checking testbench per block, plus secure_uart_crypto_top_tb (wire level) and secure_uart_hardening_tb
    tests/  reference_vectors (OpenSSL GCM), protocol_cases (wire-level frames from an independent model)
    docs/   architecture, module-interfaces, protocol-specification, cryptographic-design, timing-analysis,
            security-review, hardware-demo, audit-matrix
    constraints/  timing_constraints.xdc (TEMPLATE, no board known)
    reports/      synthesis (generic), verification (regression log + manifest)

## Verification status
| Block | Evidence |
|---|---|
| uart_timing | exact tick counts over 50 ms (`uart_timing_tb`) |
| uart_rx | all 256 bytes, +/-3 % baud, framing error, glitch, reset, break, phase offsets (`uart_rx_tb`) |
| uart_tx | frame decoding by independent monitor, 256 back-to-back, reset while busy (`uart_tx_tb`) |
| sync_fifo | directed + 20,000 random cycles vs model (`sync_fifo_tb`) |
| packet_parser / packet_builder | positive/negative protocol tests; builder with random FIFO backpressure |
| AES-128 | FIPS-197 vectors; key expansion vs Appendix A.1 |
| AES-GCM | 108 OpenSSL vectors incl. NIST cases 1-4, enc/dec, tamper tests, start-while-busy |
| Whole device | 29 wire-level cases (replay, tamper, reset mid-transaction, NV persistence, key zeroize/load) at 115200 **and 9600** baud; flood/backpressure/encrypt-disabled hardening test |
| Mutation checks | deliberately broken RTL (wrong GHASH constant, ignored auth failure, no replay check, frozen nonce counter, ...) is caught by the tests |
| Lint/synthesis | GHDL `--synth` + yosys check: no latches or driver conflicts in any module (generic gates only; not FPGA resource numbers) |

## Open items (cannot be closed without your input or hardware)
- **FPGA board/part and synthesis tool**: needed for pin constraints, timing closure, resource/Fmax numbers and hardware validation (`docs/hardware-demo.md` is written, not executed).
- **Security decisions**: replace the public test key (`KEY_INIT`), decide who provisions keys (`key_load` is a trusted-logic port, never reachable from the UART), whether unauthenticated
  ENCRYPT_REQ is acceptable (`ALLOW_UNAUTH_ENCRYPT`), and provide a real non-volatile store for the nonce counter and last SEQ (only modelled in simulation).
- Side-channel/tamper assessment is out of scope here; responses of type 82/E0 are unauthenticated.

## Synthesis instructions (vendor-neutral outline)
1. Create a project for your part with all `rtl/*.vhd` (VHDL-2008, library `work`, `aes_pkg.vhd` before its users), top `secure_uart_crypto_top`.
2. Set generics: `CLK_FREQ_HZ`, `BAUD_RATE`, `KEY_INIT_VALID=false` for anything real, `ALLOW_UNAUTH_ENCRYPT` per policy, `DEVICE_ID`, `PARSER_TIMEOUT_CLKS`, `NV_TIMEOUT_CLKS`.
3. Fill in `constraints/timing_constraints.xdc` (clock, pins). Connect `ctr_*`, `seq_*`, `key_load`, `zeroize` to real logic; leaving them tied off changes security behaviour.
4. Review: latches, unconstrained paths, RAM inference for the FIFOs/buffers, the AES S-box critical path. Record results under `reports/`.

## Key design decisions
- Baud timing: fractional phase-accumulator clock enable (exact long-term rate, no second clock). RX 16x oversampling, TX 1x.
- Protocol: `docs/protocol-specification.md`. AAD = VER||TYPE||SEQ||LEN; request/response types differ so responses cannot be replayed as requests.
- Plaintext hold-back: decrypt output stays in a private buffer; it is wiped on auth failure and released only after the tag verifies **and** the replay SEQ is durably stored.
- Nonces: device `DEVICE_ID||counter` with NV reservation before use; host nonces starting with `DEVICE_ID` are refused.
- Deviations from the spec's proposed file list are listed in `docs/architecture.md` and `docs/audit-matrix.md`.
