# Packet Protocol Specification (v1)

All multi-byte fields are **big-endian**. Bytes arrive in field order. UART is 8-N-1, 9600 baud.

## Frame layout (request, host -> device)

| Offset | Size | Field | Notes |
|---|---|---|---|
| 0 | 1 | SYNC | `0xA5`; only meaningful while hunting |
| 1 | 1 | VER | must be `0x01` |
| 2 | 1 | TYPE | `0x01` DECRYPT_REQ, `0x02` ENCRYPT_REQ |
| 3 | 2 | SEQ | sequence number |
| 5 | 12 | NONCE | 96-bit GCM IV |
| 17 | 2 | LEN | payload length, 0..MAX_PAYLOAD (default 256) |
| 19 | LEN | PAYLOAD | ciphertext (DECRYPT_REQ) or plaintext (ENCRYPT_REQ) |
| 19+LEN | 16 | TAG | **DECRYPT_REQ only**; absent for ENCRYPT_REQ |

Header = 19 bytes. Max DECRYPT_REQ = 19 + 256 + 16 = 291 bytes (~0.30 s at 9600 baud).

## Authenticated data
AAD = `VER || TYPE || SEQ || LEN` (6 bytes), where TYPE is the type of the frame that carries the
tag (`01` for a DECRYPT_REQ, `81` for an ENCRYPT_RESP). NONCE is the GCM IV. SYNC is not authenticated.

## Response frame (device -> host)
Same layout as a request: `A5 01 TYPE SEQ(2) NONCE(12) LEN(2) PAYLOAD [TAG(16)]`

| TYPE | Meaning | NONCE | PAYLOAD | TAG |
|---|---|---|---|---|
| `81` | ENCRYPT ok | device nonce (device ID \|\| counter) | ciphertext | yes |
| `82` | DECRYPT ok | request nonce echoed | plaintext (released only after the tag verified) | no |
| `E0` | error | zeros | 1 byte error code (LEN=1) | no |

SEQ in a response echoes the request SEQ (0 for parser-level errors).
Decrypt responses carry no tag: the response itself is not authenticated (trusted-link assumption).

## Response error codes (E0 payload)
| Code | Meaning |
|---|---|
| `01` | authentication failed (plaintext discarded and wiped) |
| `02` | replay: SEQ not greater than the last authenticated SEQ |
| `03` | nonce unavailable (counter not valid/exhausted, or NV store did not acknowledge) |
| `04` | no key loaded (never provisioned or zeroized) |
| `05` | DECRYPT_REQ nonce starts with the device ID (reserved for device-generated nonces) |
| `06` | ENCRYPT_REQ refused (`ALLOW_UNAUTH_ENCRYPT=false`) |
| `11`-`14` | parser error: `10` OR parser code (bad version / bad type / bad length / timeout) |

## Nonce policy (default)
Nonce = 32-bit device ID || 64-bit counter. For ENCRYPT_REQ the **device** generates the nonce
(the NONCE field in the request is ignored and should be zero); the response carries it.
A counter that survives reset/power loss is required before any security-sensitive use.
Nonce reuse under one key breaks GCM; this must be solved in Phase 6, not assumed.

## Parser policy
- Bytes before SYNC are discarded while hunting.
- Length-delimited: a `0xA5` inside a packet is ordinary data; there is no rescan inside a packet.
- Early rejection: bad VER, bad TYPE, or LEN > MAX_PAYLOAD abort the packet immediately and return to hunting.
  The remaining bytes of the rejected packet are then hunted for SYNC; a false start fails later
  (header check, timeout, or GCM tag), never corrupting state.
- Inter-byte timeout inside a packet aborts it (error TIMEOUT). Idle while hunting never times out.
- A complete packet is held (`pkt_valid`) until the consumer acknowledges it. While held, no bytes are
  consumed, so backpressure builds in the RX FIFO (a full FIFO drops bytes and flags overflow).

## Error codes
| Code | Meaning |
|---|---|
| 001 | bad version |
| 010 | bad type |
| 011 | bad length |
| 100 | inter-byte timeout |

## Known limitations / open items
- Replay policy (implemented): a DECRYPT_REQ is accepted only if SEQ > last authenticated SEQ. Forged or failed
  packets never advance it. The last SEQ is persisted through the NV store before the plaintext is released and is
  reloaded after reset or power loss. After SEQ `0xFFFF` every DECRYPT_REQ is rejected until reprovisioned.
  A host that never receives the response must use a higher SEQ for its retry (the old SEQ is consumed).
- ENCRYPT_REQ is unauthenticated, so anyone with UART access can use the device as an encryption oracle and consume
  nonce space. Acceptable only on a trusted link; otherwise build with `ALLOW_UNAUTH_ENCRYPT=false` (see `security-review.md`).
