# Architecture

```
rst_in -> 2-FF sync -> rst
uart_rx_pin -> uart_rx (16x oversample, 2-FF sync) -> sync_fifo (RX) -> packet_parser
                                                                     | held packet, header, payload buf, tag
key_manager --key--> crypto_controller <--NV store (nonce ctr, last SEQ)
                      |  AAD/data blocks       ^ out blocks, tag, auth_ok
                      v                        |
                    aes_gcm_engine (aes128_core + ghash_mult)
crypto_controller -> response builder -> sync_fifo (TX) -> uart_tx -> uart_tx_pin
```
Single clock domain (50 MHz). Baud timing is a clock-enable (`uart_timing`), never a second clock.

| Module | Role |
|---|---|
| `uart_timing` | fractional accumulator tick, exact long-term rate |
| `uart_rx` / `uart_tx` | 8-N-1 serial, ready/valid on TX |
| `sync_fifo` | FWFT byte FIFO; overflow drops + flags, underflow ignored |
| `packet_parser` | frame state machine, bounds checks, timeout, holds packet until acked |
| `aes_pkg`, `aes128_core` | AES-128 encrypt, 1 round/clock, on-the-fly key schedule |
| `ghash_mult` | bit-serial GF(2^128) multiplier |
| `aes_gcm_engine` | GCM sequencing; block-stream interface (contract in file header) |
| `key_manager` | key + valid flag, zeroize, trusted load |
| `crypto_controller` | transaction FSM, replay, nonce/NV, plaintext hold-back, response builder |
| `secure_uart_crypto_top` | integration, reset synchroniser |

## Controller FSM
IDLE -> (decrypt) ENG_GO -> ENG_RUN <-> LOAD_BLK/PRESENT -> SEQ_WAIT -> RESP -> ACK -> IDLE
IDLE -> (encrypt) NONCE_WAIT -> ENG_GO -> ENG_RUN ... -> RESP -> ACK -> IDLE
Any error: -> RESP (error frame) [auth failure and NV timeout via CLEAR, which zeroes the plaintext buffer].
Parser errors reach RESP directly from IDLE (no held packet, so no ACK).
Legal transitions are exactly those in `crypto_controller.vhd`; `when` coverage is complete (no default branch is needed).

## Deviation from the original spec file list
No separate `packet_builder`, `rx_fifo`, `tx_fifo` or `ghash.vhd` files: the builder lives in the controller and both FIFOs are
instances of `sync_fifo`. The original spec's `COMPLETE`/`VALIDATE_PACKET` states are folded into the parser and controller.

## State machines (every legal transition)
Reset puts every FSM in its first state. A state not listed for an event holds.

**uart_rx**: IDLE -(sync'd rx low)-> START_BIT -(tick #7, rx low)-> DATA_BITS | -(rx high = glitch)-> IDLE.
DATA_BITS -(16 ticks x 8 bits)-> STOP_BIT -(16 ticks, rx high)-> IDLE + `data_valid` | -(rx low)-> ERROR_WAIT + `framing_err`.
ERROR_WAIT -(rx high)-> IDLE.

**uart_tx**: IDLE -(data_valid and ready)-> START_WAIT -(tick)-> DATA_BITS -(8 ticks)-> STOP_BIT -(tick)-> STOP_HOLD -(tick)-> IDLE + `done`.

**packet_parser**: HUNT -(byte = A5)-> HDR -(header ok)-> PAYLOAD | TAG | HOLD; PAYLOAD -(LEN bytes)-> TAG (type 01) | HOLD (type 02);
TAG -(16 bytes)-> HOLD; HOLD -(pkt_ack)-> HUNT. HDR/PAYLOAD/TAG -(bad VER/TYPE/LEN or inter-byte timeout)-> HUNT + `pkt_err`.

**packet_builder**: IDLE -(start)-> SEND [HDR 19 bytes -> PAY LEN bytes -> TAG 16 bytes, one byte per clock while FIFO not full] -> IDLE + `done`.

**aes_gcm_engine**: IDLE -(start)-> H_GO -> H_WAIT -> J0_GO -> J0_WAIT -> [AAD_IN -> GM_GO -> GM_WAIT]* -> [DATA_IN -> KS_GO -> KS_WAIT -> GM_GO -> GM_WAIT]* -> (length block) GM_GO -> GM_WAIT -> IDLE + `done`.
A `start` while not IDLE is ignored and pulses `error`.

**crypto_controller** (spec states -> implementation): RESET -> reset branch; IDLE -> IDLE; RX_PACKET/VALIDATE_PACKET -> inside `packet_parser` (HDR..HOLD);
PREPARE_CRYPTO -> IDLE decision + NONCE_WAIT/ENG_GO; CRYPTO_BUSY -> ENG_RUN/LOAD_BLK/PRESENT; VERIFY_RESULT -> end of ENG_RUN + SEQ_WAIT/CLEAR;
TX_PACKET -> RESP/RESP_WAIT (`packet_builder`); COMPLETE -> ACK; ERROR -> error frame via RESP.

| From | Condition | To |
|---|---|---|
| IDLE | pkt_valid, key missing / bad nonce prefix / NV not ready / replay / encrypt disabled / counter unusable | RESP (error frame) |
| IDLE | pkt_valid, decrypt accepted | ENG_GO |
| IDLE | pkt_valid, encrypt accepted | NONCE_WAIT |
| IDLE | pkt_err (parser error, no held packet) | RESP |
| NONCE_WAIT | ctr_store_ack | ENG_GO (counter+1 is durable) |
| NONCE_WAIT | NV timeout | RESP (error 03) |
| ENG_GO | always | ENG_RUN |
| ENG_RUN | eng_in_ready (AAD) | PRESENT; (data) LOAD_BLK -> PRESENT -> ENG_RUN |
| ENG_RUN | eng_done, decrypt and auth failed | CLEAR (wipe) -> RESP (error 01) |
| ENG_RUN | eng_done, decrypt and auth ok | SEQ_WAIT |
| ENG_RUN | eng_done, encrypt | RESP (type 81) |
| SEQ_WAIT | seq_store_ack | RESP (type 82, plaintext released) |
| SEQ_WAIT | NV timeout | CLEAR (wipe) -> RESP (error 03) |
| RESP | builder started | RESP_WAIT |
| RESP_WAIT | bld_done | ACK (held packet) or IDLE (parser error frame) |
| ACK | pkt_ack pulse | IDLE |

## Protections required by the spec
- No transition depends on an unregistered asynchronous input: the only asynchronous inputs are `uart_rx_pin` and `rst_in`, both go through 2-flop synchronisers
  (marked `async_reg`). All other inputs are synchronous to `clk` by contract.
- No false completion after reset: every FSM returns to its first state and the `done`/`valid` outputs are registered pulses that default to '0'.
- No repeated processing from a lingering `done`: all completion signals are one-clock pulses; the held packet is acknowledged once.
- New transaction only when resources are free: one packet at a time; the parser holds (does not consume) while the controller is busy.
- No unauthenticated plaintext: see the security review.
- No byte lost because a consumer is not ready: internal links use ready/valid or `full` gating (builder waits on `full`, parser stops reading in HOLD).
  The UART wire itself has no flow control, so the RX FIFO can overflow under a flood: that is flagged (`st_rx_overflow`), and `uart_rts_n`
  asserts when the FIFO is more than half full so a host with RTS/CTS can stop. Hosts without RTS/CTS must pace their frames.

## Buffer sizing (max payload 256 bytes)
| Item | Storage | Where |
|---|---|---|
| Received header (VER implicit) | TYPE 8 + SEQ 16 + NONCE 96 + LEN 9 = 129 bits | `packet_parser` |
| Received payload (ciphertext or plaintext) | 256 x 8 = 2,048 bits | `packet_parser` |
| Received tag | 128 bits | `packet_parser` |
| Result / decrypted plaintext (private until authenticated) | 16 x 128 = 2,048 bits | `crypto_controller` |
| Builder working copy (nonce + tag) | 96 + 128 bits | `packet_builder` |
| Largest transmit frame | 19 + 256 + 16 = 291 bytes | `sync_fifo` TX, depth 512 x 8 = 4,096 bits |
| RX backlog | 4,096 bits (one max frame 291 B + headroom) | `sync_fifo` RX |
| AES + GHASH + GCM working registers | about 2,300 bits (state, round key, key, IV, H, EJ0, Y, block copies, GHASH x/v/z) | engine |
Total storage is roughly 16 kbit plus working registers; this is a hand tally. Real utilisation needs a synthesis report on the chosen part.
A frame with LEN > MAX_PAYLOAD is rejected at the header (error 0x13) before any payload byte is stored, so the buffer cannot overflow.

## Status and error signals (spec section 12)
All event outputs are **one-clock pulses** with no sticky flags and nothing to clear (latch them externally if needed). `busy` and `uart_rts_n` are levels.

| Condition | Where it shows | Effect on state / data |
|---|---|---|
| UART framing error | `st_framing_err` | byte discarded, receiver waits for line idle |
| UART overrun / RX FIFO overflow | `st_rx_overflow` | newest byte dropped, stored data intact |
| FIFO underflow | internal (`rxf_unf`, not exported; cannot occur: reads are gated by `empty`) | read ignored |
| Invalid packet format, unsupported type, invalid length, timeout | `st_parse_err` + error frame `E0 1x` | packet abandoned, parser hunts for the next sync byte |
| Authentication failure | `st_auth_fail` + `E0 01` | plaintext wiped, replay state untouched |
| Replay | `st_replay` + `E0 02` | request refused before any crypto |
| Nonce / NV failure | `E0 03` | request refused; plaintext wiped if already decrypted |
| Invalid key configuration | `E0 04` | request refused |
| Reserved nonce prefix / encrypt disabled | `E0 05` / `E0 06` | request refused |
| Crypto engine misuse | `st_crypto_err` | ignored; never expected in normal operation |
| Reset during processing | n/a | every FSM returns to its first state, buffers are re-initialised/wiped by the next transaction; NV state persists |
Errors never produce a success frame: success frames (81/82) are only built from the success branches above.

## RX synchronisation latency
`uart_rx_pin` passes through 2 flip-flops (2 clocks = 40 ns, 0.04 % of a bit). Synchroniser flops reset to '1' (idle), so a line that is
already low when reset is released is seen as a start bit after the 2-clock latency; the frame is then decoded from that point.
