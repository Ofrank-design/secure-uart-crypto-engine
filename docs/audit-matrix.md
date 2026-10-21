# Requirement Audit (spec section 17 format)

Status values: **PASS** (evidence in this repo), **UNVERIFIED** (designed, needs hardware/vendor tools to prove), **MISSING** (not done),
**N/A** (not applicable, reason given). "Simulation" means GHDL 4.1 `--std=08`; evidence files are in `tb/`, `tests/`, `reports/`.

## 2.1 Functional requirements
| Requirement | Status | Evidence / action |
|---|---|---|
| Receive async UART with 50 MHz clock; recover 9600 baud | PASS | `uart_rx_tb` (real-time waveforms, phase offsets T8), `uart_timing_tb` |
| Detect valid start/stop bits | PASS | T3 (bad stop), T4 (start glitch), T7 (break) |
| Correct bit order (LSB first) | PASS | `uart_rx_tb` T1 all 256 values; `uart_tx_tb` monitor |
| One-clock `data_valid` pulse | PASS | monitor asserts in `uart_rx_tb` |
| Buffer complete packets before crypto | PASS | `packet_parser` holds the packet; `packet_parser_tb` T7 |
| Validate structure and lengths | PASS | `packet_parser_tb` T2-T6, e2e parser cases |
| Encrypt outgoing plaintext | PASS | e2e ENCRYPT cases vs OpenSSL |
| Decrypt only after authentication | PASS | controller holds plaintext; e2e tamper cases + mutation test |
| Reject invalid tags | PASS | `aes_gcm_tb` tamper cases, e2e `E0 01` |
| Transmit processed packets | PASS | e2e wire-level, `packet_builder_tb` |
| Report framing, overflow, protocol, crypto errors | PASS | status pulses, see `architecture.md` error table; hardening test |
| Recover from reset and recoverable failures | PASS | e2e REQ_RESET/RESET, every error case followed by a good packet |
| Malformed packets cannot corrupt state | PASS | parser negative tests, replay state untouched by failures |

## 2.2 Non-functional requirements
| Requirement | Status | Evidence / action |
|---|---|---|
| Synchronous to a documented clock | PASS | single 50 MHz domain; baud via clock enable |
| Synthesizable in chosen toolchain | UNVERIFIED | generic GHDL/yosys synthesis passes; vendor tool unknown -> run on target |
| Deterministic | PASS | no randomness in RTL; vectors reproducible |
| No unintended latches / multiple drivers | PASS (generic) | `scripts/run_lint.sh`, `reports/synthesis/`; repeat in vendor tool |
| Verified against independent references | PASS | FIPS-197 vectors; OpenSSL GCM vectors; OpenSSL-generated wire frames |
| Documented generics | PASS | `docs/module-interfaces.md` (generated) |
| Resource-conscious, timing-closed for selected FPGA | UNVERIFIED | target FPGA unknown. **Action:** supply part/board/tool; run implementation |
| Reproducible from clean checkout | PASS | git repo + `scripts/run_regression.sh`; needs GHDL, yosys (lint), python `cryptography` |

## 2.3 Design assumptions
| Assumption | Status | Evidence |
|---|---|---|
| 50 MHz, 9600 8-N-1, LSB first, one clock domain, sync reset | PASS | generics; all testbenches; e2e also at 9600 baud |
| AES-128-GCM, 128-bit key, full 128-bit tag | PASS | `aes_gcm_tb` |
| 256-byte payload, configurable | PASS | `MAX_PAYLOAD` generic; max-size cases pass. Final limit is a hardware question: UNVERIFIED |
| Explicit ready/valid flow control | PASS | internal ready/valid; `uart_rts_n` for the wire |

## 3-5 Architecture, UART
| Requirement | Status | Evidence / action |
|---|---|---|
| Components independently verifiable | PASS | one testbench per block: timing, rx, tx, fifo, parser, builder, key expansion, AES core, GCM engine; controller/top by e2e + hardening |
| Key/nonce mgmt, error reporting, packet timeout, status | PASS | `key_manager`, controller, parser timeout, status pulses (no counters; pulses only) |
| Crypto core independent of UART timing | PASS | block interface, no UART signals in engine |
| Baud approach documented; no second fabric clock | PASS | `timing-analysis.md`, fractional accumulator + enable |
| `uart_rx` interface as recommended | PASS | exact recommended ports |
| 2-flop sync + metastability attribute; raw RX only in sync | PASS | `uart_rx` (`async_reg`), reset sync in top (`async_reg`) |
| RX FSM states and behaviour | PASS | states as specified (COMPLETE folded into STOP_BIT, allowed); error recovery policy documented |
| 16x oversampling as clock enable | PASS | `uart_timing` OVERSAMPLE=16 |
| Majority vote over 3 samples | N/A | optional in spec; not implemented (centre sample verified to +/-3 % tolerance) |
| `uart_tx` interface, sequence, `done` one clock | PASS | exact recommended ports; `uart_tx_tb` |

## 6 Cryptography
| Requirement | Status | Evidence / action |
|---|---|---|
| AES-128 (S-box, ShiftRows, MixColumns, AddRoundKey, key expansion, round behaviour, byte order) | PASS | FIPS-197 C.1, B, zero key; key expansion standalone vs Appendix A.1 |
| AES iterative choice justified by measured area/latency/Fmax | PARTIAL | latency measured (11 clocks); area and Fmax UNVERIFIED (no target) |
| GHASH, counter mode, tag generation/compare, AAD, partial blocks | PASS | 108 OpenSSL vectors incl. NIST cases 1-4 |
| Interface documented (sampling, stability, backpressure, cancel, failure) | PASS | header of `aes_gcm_engine.vhd`, mapping table in `cryptographic-design.md` |
| Plaintext released only after authentication; failure behaviour | PASS | controller + e2e |
| Key management: provisioning, no hardcoded production key, zeroization, access control | PASS (policy) / UNVERIFIED (device) | `key_manager`, `key_load` trusted port; FPGA key-extraction risk documented, not mitigated |
| Nonce policy incl. reset, power loss, retransmission, replacement, rollback | PASS (design) / UNVERIFIED (real NV) | NV reservation; rollback of NV image is an OPEN risk |

## 7 Protocol
| Requirement | Status | Evidence / action |
|---|---|---|
| Formal packet format, widths, byte order, max length, AAD fields | PASS | `protocol-specification.md` |
| Replay policy explicit | PASS | strictly increasing SEQ, persistent |
| Parser: boundaries, version/type, length, truncation/timeouts, unexpected sync, overflow, recovery | PASS | `packet_parser_tb` |
| CRC | N/A | optional; GCM tag covers integrity |
| Buffer sizing calculated; oversize behaviour | PASS | `architecture.md` buffer table; error 0x13 |

## 8 Control FSM
| Requirement | Status | Evidence / action |
|---|---|---|
| Every legal transition and condition defined | PASS | `architecture.md` transition tables |
| Recommended state names | PARTIAL | different decomposition (parser + controller + builder); mapping table provided. Allowed: states are "recommended" |
| Required protections | PASS | listed with evidence in `architecture.md`; UART wire flood is flagged (cannot be prevented without host flow control: RTS provided) |
| UART modules independently testable | PASS | separate entities and testbenches |

## 9 Coding standards
| Requirement | Status | Evidence / action |
|---|---|---|
| std_logic_1164 + numeric_std, explicit widths, documented standard (VHDL-2008) | PASS | README, scripts |
| No latches / multiple drivers / unsafe clocks; reset values for control registers | PASS | lint + synthesis; control registers reset |
| Project organisation | PARTIAL | proposed layout adapted: `sync_fifo` replaces rx/tx_fifo, `ghash_mult` replaces `ghash`; `packet_builder`, `aes128_key_expansion` now exist as separate files |

## 10 Verification
| Requirement | Status | Evidence |
|---|---|---|
| RX: 0x00, FF, 55, AA, all 256, back-to-back, glitches, bad stop, incomplete frames, reset, baud tolerance, offsets, long idle, recovery | PASS | `uart_rx_tb` T1-T8 (incomplete frame = break T7 and reset mid-frame T5) |
| TX: idle, start, order, stop, average baud, done, back-to-back, reset, handshake | PASS | `uart_tx_tb`, `uart_timing_tb` |
| AES: encryption KAT | PASS | `aes128_core_tb` |
| AES: decryption KAT | N/A | decrypt direction not implemented: GCM uses only the forward cipher; GCM decrypt is verified end to end |
| AES: key expansion KAT, zero/non-zero keys | PASS | `aes128_key_expansion_tb` |
| GCM: empty PT/AAD, partial blocks, multi-block, AAD, enc/dec, tag failures, modified CT/nonce/header, boundaries | PASS | `aes_gcm_tb`, e2e |
| Protocol tests (versions, types, truncation, length, tags, ordering, interruption, unexpected bytes, duplicates, replay, recovery) | PASS | parser tb + e2e; "incorrect field ordering" is covered as VER/TYPE mismatch (`A5 02`), not a dedicated test |
| Integration success and failure paths | PASS | `secure_uart_crypto_top_tb` (115200 and 9600 baud) |
| Regression: compile, elaborate, unit, integration, KAT, lint/synth | PASS | `scripts/run_regression.sh` |
| Passing suite tied to a revision and tool configuration | PASS | git commit + `reports/verification/manifest.txt` |

## 11 FPGA synthesis and timing
| Requirement | Status | Action |
|---|---|---|
| Toolchain: vendor, exact part, board, VHDL standard, simulator, synthesis tool | MISSING | simulator/standard documented (GHDL, VHDL-2008); **FPGA vendor/part/board/tool unknown** |
| 20 ns clock constraint | PASS (template) | `constraints/timing_constraints.xdc`; board I/O constraints MISSING until pins known |
| Synthesis report checks (latches, drivers: PASS generic; unconstrained paths, timing, utilisation, RAM inference, fanout, critical path) | PARTIAL/UNVERIFIED | needs target tool |
| Measured resources, Fmax, latencies | UNVERIFIED | latency estimates in `timing-analysis.md`; **no resource or Fmax claims are made** |

## 12-14 Reliability, security, documentation
| Requirement | Status | Evidence / action |
|---|---|---|
| Distinct error classes with defined effects, documented pulse/clear behaviour | PASS | `architecture.md` error table |
| Errors never become success | PASS | e2e (no extra bytes after error frames) |
| Threat model | PASS (draft) | `security-review.md`; assumptions need owner sign-off |
| Security controls; debug/test hooks reviewed | PASS | `zeroize`/`key_load` ports documented as trusted-logic-only |
| Side-channel/fault/tamper assessment | MISSING | separate assessment required for real deployments; no tamper-resistance claim is made |
| Docs: architecture, interfaces, UART timing, FSM diagrams, packet format, crypto spec, key/nonce lifecycle, sim instructions | PASS | `docs/` |
| Docs: FPGA synthesis instructions | PARTIAL | generic flow in README; vendor steps need the target |
| Docs: timing/resource reports, pin assignments, executed demo | UNVERIFIED/MISSING | need target hardware |
| Docs: limitations, assumptions, residual risks | PASS | `security-review.md`, README |

## 15-16 Phase exit criteria and acceptance checklist
| Phase | Exit criteria met? |
|---|---|
| 1 Requirements/environment | PARTIAL: architecture, interfaces, protocol, threat model documented; FPGA/tool selection open |
| 2 UART receiver | PASS |
| 3 UART TX + buffering | PASS |
| 4 Packet protocol (parser and builder) | PASS (builder has its own testbench) |
| 5 Crypto primitives | PASS |
| 6 Secure integration | PASS |
| 7 Verification and hardening | PARTIAL: no known functional defects; security open items in `security-review.md` |
| 8 Synthesis and timing closure | OPEN (no target) |
| 9 Hardware validation | OPEN (procedure written, not executed) |
| 10 Release readiness | OPEN |

Final acceptance checklist: all **Functional correctness** and **Verification** items have evidence; **Hardware implementation** items other than
"no latches/multiple drivers (generic)" and "toolchain documented (simulator side)" are open; **Security and documentation** items have evidence except
real nonce-NV behaviour and clean-environment build on a second machine.
**Production-ready designation: NOT GRANTED** (per the spec's final release rule, unchecked critical hardware/timing and security items block it).
