# Security Review (working draft, Phase 6)

## Threat model (assumed, not yet confirmed by the project owner)
- Attacker can read, inject, modify, drop and replay bytes on the UART link.
- Attacker has no physical access to the FPGA, bitstream or key storage. **This is the weakest assumption.**
- Goals: confidentiality and integrity of DECRYPT traffic, no release of unauthenticated plaintext, no nonce reuse.
- Not goals (yet): side-channel/fault resistance, tamper evidence, availability against flooding.

## Controls and evidence
| Control | Where | Evidence |
|---|---|---|
| AES-128-GCM, full 128-bit tag | `aes_gcm_engine` | 108 independent vectors incl. NIST cases 1-4; tag/ct/AAD/IV tamper all fail |
| No plaintext before authentication | `crypto_controller` (private buffer, wiped on failure, error frame instead) | e2e: tampered tag/ct/nonce/AAD give only `E0 01`; no extra bytes follow |
| Replay rejection, persistent across reset | controller + NV `seq_*` store | e2e: same/lower SEQ refused; failed packets never advance SEQ; old packet refused after reset; mutation-checked |
| Plaintext released only after SEQ is durable | `SEQ_WAIT` state | NV timeout path wipes plaintext (code 03) |
| Nonce uniqueness across reset/power loss | counter + NV reservation before use | e2e: NV written before use, counter reloaded from NV after reset; mutations caught |
| No nonce collision between directions | reserved device-ID prefix refused (code 05) | e2e case + mutation-checked |
| Encrypt-oracle / nonce-exhaustion option | `ALLOW_UNAUTH_ENCRYPT=false` -> code 06 | hardening test: refused, NV store untouched |
| Bounded parsing, backpressure | parser, FIFOs, builder, `uart_rts_n` | unit tests; hardening test: 44 dropped bytes flagged under flood with RTS asserted, 39-byte reply through 16-byte TX FIFO, builder tested under random backpressure |
| Reset mid-transaction | top | e2e: no output after reset, device recovers, in-flight SEQ not consumed |
| Key zeroize / trusted load | `key_manager`, top ports | e2e: refused after zeroize, works after `key_load` with a new key |
| Latch/driver-free RTL | GHDL `--synth` + yosys `check` | `reports/synthesis/*`, all modules and top: no warnings except the vendor `async_reg` attribute |

## Resolved since the first draft
- Replay state is now persistent (NV store). Tag compare is a single-cycle parallel compare (no data-dependent latency).
- Cross-direction nonce collision closed (code 05). Key provisioning path exists via the trusted `key_load` port (UART cannot load keys).
- Encrypt oracle can be disabled at build time.

## Open issues / residual risks (cannot be closed without owner decisions or hardware)
1. **Test key in the bitstream by default.** Production: `KEY_INIT_VALID=false` and drive `key_load` from trusted logic (secure boot / JTAG / HSM).
2. **Threat model not confirmed.** Physical access, bitstream readback and side channels are out of scope and unmitigated.
3. **Default build still allows unauthenticated ENCRYPT_REQ**; choose per deployment.
4. **Responses of type 82 and E0 are unauthenticated**; a link attacker can forge, suppress or delay them.
5. **NV store is only modelled** in simulation. The real device must acknowledge only after the write is durable, and per-request writes wear flash
   (consider block reservation for the counter once the part is chosen). A lost response consumes the SEQ.
6. **SEQ 16-bit:** after 0xFFFF the device refuses decrypts until reprovisioned (fail-safe, but an operational limit).
7. Error frames can be triggered by any garbage on the link (availability/amplification is not analysed).
8. No side-channel (S-box table, power/EM) or fault-injection assessment.

This design must not be described as production-ready or tamper-resistant until 1, 2, 5 are resolved and a hardware validation is done.
