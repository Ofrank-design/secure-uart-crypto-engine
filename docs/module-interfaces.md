# Module Interfaces

Generated from the entity declarations by `scripts/gen_module_docs.py` (do not edit by hand).
All modules are synchronous to `clk` (single 50 MHz domain), VHDL-2008, synchronous reset `rst` (active high).

## `aes128_core`  (`rtl/aes128_core.vhd`)
```text
aes128_core.vhd  Iterative AES-128 encryption: one round per clock, round keys
derived on the fly. Latency: 10 round clocks (done pulses on the
cycle block_out becomes valid, i.e. 11 clock edges after the one that latched start).
start is ignored while busy.
Only the encrypt direction is implemented because GCM (CTR + GHASH) needs nothing else.
```

**Ports**

| Name | Dir | Type | Note |
|---|---|---|---|
| `clk` | in | `std_logic` |  |
| `rst` | in | `std_logic` |  |
| `start` | in | `std_logic` |  |
| `key` | in | `std_logic_vector(127 downto 0)` |  |
| `block_in` | in | `std_logic_vector(127 downto 0)` |  |
| `busy` | out | `std_logic` |  |
| `done` | out | `std_logic` |  |
| `block_out` | out | `std_logic_vector(127 downto 0)` |  |

## `aes128_key_expansion`  (`rtl/aes128_key_expansion.vhd`)
```text
aes128_key_expansion.vhd  One step of the AES-128 key schedule (FIPS 197 section 5.2), combinational.
rk_out = round key N+1 derived from rk_in (round key N) and rcon (Rcon[N+1], 0x01 for the first step).
Used by aes128_core (one step per round) and verified standalone against FIPS-197 Appendix A.1.
```

**Ports**

| Name | Dir | Type | Note |
|---|---|---|---|
| `rk_in` | in | `std_logic_vector(127 downto 0)` |  |
| `rcon` | in | `std_logic_vector(7 downto 0)` |  |
| `rk_out` | out | `std_logic_vector(127 downto 0)` |  |

## `aes_gcm_engine`  (`rtl/aes_gcm_engine.vhd`)
```text
aes_gcm_engine.vhd  AES-128-GCM, 96-bit IV, full 128-bit tag (SP 800-38D).

Transaction contract (buffered/block-stream):
 * Pulse 'start' while busy='0'. key, iv, aad_len, data_len (bytes), decrypt and
   tag_in are sampled on that clock edge and need not stay stable afterwards.
 * The engine requests input blocks: while in_ready='1' it wants one 16-byte block
   (in_is_aad='1' -> AAD block, else data block). A block is accepted on the edge where
   in_valid and in_ready are both '1'. Byte 0 is in_block(127 downto 120). Final partial
   blocks may carry any padding; the engine masks bytes beyond the length.
 * Data blocks are returned on out_block with a one-clock out_valid pulse; out_bytes
   gives the number of valid bytes (1..16, MSB-first), the rest are zero.
 * 'done' pulses for one clock when the transaction ends; tag_out and auth_ok are then valid.
     encrypt: tag_out is the computed tag, auth_ok='1'.
     decrypt: auth_ok='1' only if the computed tag equals tag_in.
 * !! In decrypt mode out_block carries UNAUTHENTICATED plaintext. The consumer (crypto
   controller) must hold it in a private buffer and release it only if auth_ok='1' at done.
 * 'error' pulses for one clock if 'start' arrives while busy; the running transaction is unaffected.
 * Cancellation: only reset cancels a transaction; no done/auth_ok pulse is produced for an aborted one.
Sequencing is serial (one AES or GHASH operation at a time) to keep area small.
```

**Ports**

| Name | Dir | Type | Note |
|---|---|---|---|
| `clk` | in | `std_logic` |  |
| `rst` | in | `std_logic` |  |
| `start` | in | `std_logic` |  |
| `decrypt` | in | `std_logic` |  |
| `key` | in | `std_logic_vector(127 downto 0)` |  |
| `iv` | in | `std_logic_vector(95 downto 0)` |  |
| `aad_len` | in | `natural range 0 to 4095` |  |
| `data_len` | in | `natural range 0 to 4095` |  |
| `tag_in` | in | `std_logic_vector(127 downto 0)` |  |
| `in_ready` | out | `std_logic` |  |
| `in_is_aad` | out | `std_logic` |  |
| `in_valid` | in | `std_logic` |  |
| `in_block` | in | `std_logic_vector(127 downto 0)` |  |
| `out_valid` | out | `std_logic` |  |
| `out_block` | out | `std_logic_vector(127 downto 0)` |  |
| `out_bytes` | out | `natural range 0 to 16` |  |
| `busy` | out | `std_logic` |  |
| `done` | out | `std_logic` |  |
| `error` | out | `std_logic;` | 1-clock pulse: 'start' received while busy (ignored) |
| `tag_out` | out | `std_logic_vector(127 downto 0)` |  |
| `auth_ok` | out | `std_logic` |  |

## `crypto_controller`  (`rtl/crypto_controller.vhd`)
```text
crypto_controller.vhd  Transaction controller (packet builder is merged in here).

Security rules implemented here:
 * Plaintext of a failed authentication is never sent: decrypt output sits in a private
   block buffer, is zeroed on failure, and an ERROR frame (code 01) is sent instead.
 * Replay: DECRYPT_REQ is accepted only if SEQ is strictly greater than the last
   AUTHENTICATED SEQ (checked early, updated only after a successful tag check, so
   forged packets can never advance it). The last SEQ is persisted through the NV store
   (seq_store_*) BEFORE the plaintext is released, and reloaded after reset/power loss.
   If the NV write is not acknowledged the plaintext is wiped and error 03 is sent.
   After SEQ 0xFFFF everything is rejected until the key/NV state is reprovisioned.
 * Nonce spaces: DECRYPT_REQ nonces whose first 4 bytes equal DEVICE_ID are refused (code 05),
   so a host can never choose a nonce that collides with the device-generated space.
 * ALLOW_UNAUTH_ENCRYPT=false refuses ENCRYPT_REQ (code 06) for links that are not trusted.
 * Nonce (ENCRYPT_REQ): DEVICE_ID(32) || counter(64). Before a counter value is used,
   counter+1 is written to non-volatile storage (ctr_store_req/val) and the controller
   waits for ctr_store_ack. The counter is only trusted when ctr_valid='1'. A power cycle
   therefore can never reuse a nonce, provided the NV store is honest.
 * Parser errors produce an ERROR frame with SEQ 0 and code 0x10|parser_code.
 * One packet at a time; the parser holds the packet (and its inputs) until pkt_ack.

Response frame: A5 01 TYPE SEQ(2) NONCE(12) LEN(2) PAYLOAD [TAG(16) for TYPE 81]
  81 encrypt ok (ciphertext + tag, device nonce) | 82 decrypt ok (plaintext, request nonce echoed)
  E0 error (LEN=1, payload = code; 01 auth, 02 replay, 03 NV/nonce unavailable, 04 no key,
            05 reserved nonce prefix, 06 encrypt disabled, 1x parser)
AAD = 01 || TYPE || SEQ || LEN where TYPE is the type of the frame carrying the tag (01 or 81).
```

**Generics**

| Name | Type | Default |
|---|---|---|
| `MAX_PAYLOAD` | `positive` | `256` |
| `NV_TIMEOUT_CLKS` | `positive` | `50_000_000` |
| `ALLOW_UNAUTH_ENCRYPT` | `boolean` | `true` |

**Ports**

| Name | Dir | Type | Note |
|---|---|---|---|
| `clk` | in | `std_logic` |  |
| `rst` | in | `std_logic` |  |
| `pkt_valid` | in | `std_logic` |  |
| `pkt_ack` | out | `std_logic` |  |
| `pkt_err` | in | `std_logic` |  |
| `err_code` | in | `std_logic_vector(2 downto 0)` |  |
| `hdr_type` | in | `std_logic_vector(7 downto 0)` |  |
| `hdr_seq` | in | `std_logic_vector(15 downto 0)` |  |
| `hdr_nonce` | in | `std_logic_vector(95 downto 0)` |  |
| `hdr_len` | in | `natural range 0 to MAX_PAYLOAD` |  |
| `tag_in` | in | `std_logic_vector(127 downto 0)` |  |
| `buf_addr` | out | `natural range 0 to MAX_PAYLOAD - 1` |  |
| `buf_data` | in | `std_logic_vector(7 downto 0)` |  |
| `key` | in | `std_logic_vector(127 downto 0)` |  |
| `key_valid` | in | `std_logic` |  |
| `ctr_init` | in | `std_logic_vector(63 downto 0)` |  |
| `ctr_valid` | in | `std_logic` |  |
| `ctr_store_req` | out | `std_logic` |  |
| `ctr_store_val` | out | `std_logic_vector(63 downto 0)` |  |
| `ctr_store_ack` | in | `std_logic` |  |
| `seq_init` | in | `std_logic_vector(15 downto 0)` |  |
| `seq_have_init` | in | `std_logic` |  |
| `seq_valid` | in | `std_logic` |  |
| `seq_store_req` | out | `std_logic` |  |
| `seq_store_val` | out | `std_logic_vector(15 downto 0)` |  |
| `seq_store_ack` | in | `std_logic` |  |
| `eng_start` | out | `std_logic` |  |
| `eng_decrypt` | out | `std_logic` |  |
| `eng_key` | out | `std_logic_vector(127 downto 0)` |  |
| `eng_iv` | out | `std_logic_vector(95 downto 0)` |  |
| `eng_aad_len` | out | `natural range 0 to 4095` |  |
| `eng_data_len` | out | `natural range 0 to 4095` |  |
| `eng_tag_in` | out | `std_logic_vector(127 downto 0)` |  |
| `eng_in_ready` | in | `std_logic` |  |
| `eng_in_is_aad` | in | `std_logic` |  |
| `eng_in_valid` | out | `std_logic` |  |
| `eng_in_block` | out | `std_logic_vector(127 downto 0)` |  |
| `eng_out_valid` | in | `std_logic` |  |
| `eng_out_block` | in | `std_logic_vector(127 downto 0)` |  |
| `eng_done` | in | `std_logic` |  |
| `eng_tag_out` | in | `std_logic_vector(127 downto 0)` |  |
| `eng_auth_ok` | in | `std_logic` |  |
| `tx_wr_en` | out | `std_logic` |  |
| `tx_wr_data` | out | `std_logic_vector(7 downto 0)` |  |
| `tx_full` | in | `std_logic` |  |
| `busy` | out | `std_logic` |  |
| `evt_parse_err` | out | `std_logic` |  |
| `evt_auth_fail` | out | `std_logic` |  |
| `evt_replay` | out | `std_logic` |  |

## `ghash_mult`  (`rtl/ghash_mult.vhd`)
```text
ghash_mult.vhd  Bit-serial GF(2^128) multiplier for GHASH (SP 800-38D, Algorithm 1).
p = a * h. 128 clocks per product; 'done' pulses when p is valid. start ignored while busy.
Bit numbering follows the standard: vector bit 127 is the standard's bit 0 (leftmost).
```

**Ports**

| Name | Dir | Type | Note |
|---|---|---|---|
| `clk` | in | `std_logic` |  |
| `rst` | in | `std_logic` |  |
| `start` | in | `std_logic` |  |
| `a` | in | `std_logic_vector(127 downto 0)` |  |
| `h` | in | `std_logic_vector(127 downto 0)` |  |
| `busy` | out | `std_logic` |  |
| `done` | out | `std_logic` |  |
| `p` | out | `std_logic_vector(127 downto 0)` |  |

## `key_manager`  (`rtl/key_manager.vhd`)
```text
key_manager.vhd  Holds the AES-128 key and its valid flag.
Reset loads KEY_INIT (a BUILD-TIME TEST KEY by default; never use it in production).
Set KEY_INIT_VALID=false for a device that must be provisioned through 'load'.
'zeroize' clears the key immediately and has priority over 'load'.
Key-load is NOT reachable from the UART in this release (top ties it off): who may
load keys is an open security decision (see docs/security-review.md).
```

**Generics**

| Name | Type | Default |
|---|---|---|
| `KEY_INIT_VALID` | `boolean` | `true` |

**Ports**

| Name | Dir | Type | Note |
|---|---|---|---|
| `clk` | in | `std_logic` |  |
| `rst` | in | `std_logic` |  |
| `zeroize` | in | `std_logic` |  |
| `load` | in | `std_logic` |  |
| `key_in` | in | `std_logic_vector(127 downto 0)` |  |
| `key` | out | `std_logic_vector(127 downto 0)` |  |
| `key_valid` | out | `std_logic` |  |

## `packet_builder`  (`rtl/packet_builder.vhd`)
```text
packet_builder.vhd  Serialises one response frame (protocol v1) into a byte FIFO.
  A5 01 TYPE SEQ(2) NONCE(12) LEN(2) PAYLOAD [TAG(16)]
Contract:
 * Pulse 'start' while busy='0'. All frame fields are sampled on that clock edge.
 * Payload bytes are fetched through the combinational read port: while the builder
   needs byte k it drives pay_blk = k/16, pay_byte = k mod 16 and expects pay_data
   (same clock cycle) to carry that byte. For error frames (resp_is_err='1') the payload is
   the single byte resp_code and the read port is not used.
 * One byte is written per clock while 'full'='0'. When 'full'='1' the builder waits (no
   byte is ever dropped). 'done' pulses for one clock after the last byte was written.
 * Reset abandons any frame in progress; no done pulse is produced.
```

**Generics**

| Name | Type | Default |
|---|---|---|
| `MAX_PAYLOAD` | `positive` | `256` |

**Ports**

| Name | Dir | Type | Note |
|---|---|---|---|
| `clk` | in | `std_logic` |  |
| `rst` | in | `std_logic` |  |
| `start` | in | `std_logic` |  |
| `busy` | out | `std_logic` |  |
| `done` | out | `std_logic` |  |
| `resp_type` | in | `std_logic_vector(7 downto 0)` |  |
| `resp_seq` | in | `std_logic_vector(15 downto 0)` |  |
| `resp_nonce` | in | `std_logic_vector(95 downto 0)` |  |
| `resp_len` | in | `natural range 0 to MAX_PAYLOAD` |  |
| `resp_has_tag` | in | `std_logic` |  |
| `resp_is_err` | in | `std_logic` |  |
| `resp_code` | in | `std_logic_vector(7 downto 0)` |  |
| `resp_tag` | in | `std_logic_vector(127 downto 0)` |  |
| `pay_blk` | out | `natural range 0 to (MAX_PAYLOAD + 15) / 16 - 1` |  |
| `pay_byte` | out | `natural range 0 to 15` |  |
| `pay_data` | in | `std_logic_vector(7 downto 0)` |  |
| `wr_en` | out | `std_logic` |  |
| `wr_data` | out | `std_logic_vector(7 downto 0)` |  |
| `full` | in | `std_logic` |  |

## `packet_parser`  (`rtl/packet_parser.vhd`)
```text
packet_parser.vhd  Parses protocol v1 request frames (see docs/protocol-specification.md).
Input: first-word-fall-through byte source (e.g. sync_fifo). A byte is consumed on
every clock where byte_valid='1' and byte_rd='1'. byte_rd drops while a packet is held.
Output: header fields, payload buffer (async read by buf_addr), tag; pkt_valid is a
level held until pkt_ack. Errors are one-clock pulses with a code that stays valid
until the next error.
```

**Generics**

| Name | Type | Default |
|---|---|---|
| `MAX_PAYLOAD` | `positive` | `256` |
| `TIMEOUT_CLKS` | `positive` | `5_000_000` |

**Ports**

| Name | Dir | Type | Note |
|---|---|---|---|
| `clk` | in | `std_logic` |  |
| `rst` | in | `std_logic` |  |
| `byte_in` | in | `std_logic_vector(7 downto 0)` |  |
| `byte_valid` | in | `std_logic` |  |
| `byte_rd` | out | `std_logic` |  |
| `hdr_type` | out | `std_logic_vector(7 downto 0)` |  |
| `hdr_seq` | out | `std_logic_vector(15 downto 0)` |  |
| `hdr_nonce` | out | `std_logic_vector(95 downto 0)` |  |
| `hdr_len` | out | `natural range 0 to MAX_PAYLOAD` |  |
| `tag_out` | out | `std_logic_vector(127 downto 0)` |  |
| `buf_addr` | in | `natural range 0 to MAX_PAYLOAD - 1` |  |
| `buf_data` | out | `std_logic_vector(7 downto 0)` |  |
| `pkt_valid` | out | `std_logic` |  |
| `pkt_ack` | in | `std_logic` |  |
| `pkt_err` | out | `std_logic` |  |
| `err_code` | out | `std_logic_vector(2 downto 0)` |  |

## `secure_uart_crypto_top`  (`rtl/secure_uart_crypto_top.vhd`)
```text
secure_uart_crypto_top.vhd  UART -> RX FIFO -> packet parser -> controller/AES-GCM -> TX FIFO -> UART.
Single clock domain. External reset (active high, asynchronous to clk) is synchronised here.
The nonce-counter NV store is an external block (flash/EEPROM/battery-backed): see ctr_* ports.
```

**Generics**

| Name | Type | Default |
|---|---|---|
| `CLK_FREQ_HZ` | `positive` | `50_000_000` |
| `BAUD_RATE` | `positive` | `9_600` |
| `MAX_PAYLOAD` | `positive` | `256` |
| `FIFO_DEPTH` | `positive` | `512` |
| `PARSER_TIMEOUT_CLKS` | `positive` | `5_000_000` |
| `NV_TIMEOUT_CLKS` | `positive` | `50_000_000` |
| `KEY_INIT_VALID` | `boolean` | `true` |
| `ALLOW_UNAUTH_ENCRYPT` | `boolean` | `true` |

**Ports**

| Name | Dir | Type | Note |
|---|---|---|---|
| `clk` | in | `std_logic` |  |
| `rst_in` | in | `std_logic` |  |
| `uart_rx_pin` | in | `std_logic` |  |
| `uart_tx_pin` | out | `std_logic` |  |
| `zeroize` | in | `std_logic;` | clear key (tamper hook) |
| `key_load` | in | `std_logic;` | provisioning, from TRUSTED logic only |
| `key_in` | in | `std_logic_vector(127 downto 0);` | (not reachable from the UART) |
| `ctr_init` | in | `std_logic_vector(63 downto 0);` | next unused counter, from NV store |
| `ctr_valid` | in | `std_logic` |  |
| `ctr_store_req` | out | `std_logic` |  |
| `ctr_store_val` | out | `std_logic_vector(63 downto 0)` |  |
| `ctr_store_ack` | in | `std_logic` |  |
| `seq_init` | in | `std_logic_vector(15 downto 0);` | last authenticated SEQ, from NV store |
| `seq_have_init` | in | `std_logic` |  |
| `seq_valid` | in | `std_logic` |  |
| `seq_store_req` | out | `std_logic` |  |
| `seq_store_val` | out | `std_logic_vector(15 downto 0)` |  |
| `seq_store_ack` | in | `std_logic` |  |
| `uart_rts_n` | out | `std_logic;` | '1' = host should stop sending (RX FIFO > half full) |
| `busy` | out | `std_logic` |  |
| `st_framing_err` | out | `std_logic` |  |
| `st_rx_overflow` | out | `std_logic` |  |
| `st_parse_err` | out | `std_logic` |  |
| `st_auth_fail` | out | `std_logic` |  |
| `st_replay` | out | `std_logic` |  |

## `sync_fifo`  (`rtl/sync_fifo.vhd`)
```text
sync_fifo.vhd  Single-clock first-word-fall-through FIFO.
Used for both RX and TX byte buffering (WIDTH=8).
Policy: a write while full is DROPPED and raises a one-clock 'overflow'
pulse (stored data is never corrupted). A read while empty is ignored and
raises a one-clock 'underflow' pulse. 'rd_data' is valid whenever empty='0'.
Reset flushes the FIFO. Asynchronous-read array: maps to distributed RAM.
```

**Generics**

| Name | Type | Default |
|---|---|---|
| `WIDTH` | `positive` | `8` |
| `DEPTH` | `positive` | `512` |

**Ports**

| Name | Dir | Type | Note |
|---|---|---|---|
| `clk` | in | `std_logic` |  |
| `rst` | in | `std_logic` |  |
| `wr_en` | in | `std_logic` |  |
| `wr_data` | in | `std_logic_vector(WIDTH - 1 downto 0)` |  |
| `full` | out | `std_logic` |  |
| `rd_en` | in | `std_logic` |  |
| `rd_data` | out | `std_logic_vector(WIDTH - 1 downto 0)` |  |
| `empty` | out | `std_logic` |  |
| `level` | out | `natural range 0 to DEPTH` |  |
| `overflow` | out | `std_logic` |  |
| `underflow` | out | `std_logic` |  |

## `uart_rx`  (`rtl/uart_rx.vhd`)
```text
uart_rx.vhd  8-N-1 UART receiver, 16x oversampling via clock enable.
Policy: after a framing error the receiver waits for the line to return high
before hunting for a new start bit (handles break / mid-frame resync safely).
framing_err and data_valid are one-clock pulses and are mutually exclusive.
```

**Generics**

| Name | Type | Default |
|---|---|---|
| `CLK_FREQ_HZ` | `positive` | `50_000_000` |
| `BAUD_RATE` | `positive` | `9_600` |

**Ports**

| Name | Dir | Type | Note |
|---|---|---|---|
| `clk` | in | `std_logic` |  |
| `rst` | in | `std_logic` |  |
| `rx` | in | `std_logic` |  |
| `data_out` | out | `std_logic_vector(7 downto 0)` |  |
| `data_valid` | out | `std_logic` |  |
| `busy` | out | `std_logic` |  |
| `framing_err` | out | `std_logic` |  |

## `uart_timing`  (`rtl/uart_timing.vhd`)
```text
uart_timing.vhd
Fractional clock-enable generator (phase accumulator). Produces a one-clock
'tick' at an average rate of BAUD_RATE*OVERSAMPLE with no second fabric clock.
Rule: if acc + INC >= CLK_FREQ then acc <= acc + INC - CLK_FREQ and tick.
Long-term average is exact; per-tick jitter is at most one clock cycle.
```

**Generics**

| Name | Type | Default |
|---|---|---|
| `CLK_FREQ_HZ` | `positive` | `50_000_000` |
| `BAUD_RATE` | `positive` | `9_600` |
| `OVERSAMPLE` | `positive` | `16` |

**Ports**

| Name | Dir | Type | Note |
|---|---|---|---|
| `clk` | in | `std_logic` |  |
| `rst` | in | `std_logic` |  |
| `tick` | out | `std_logic` |  |

## `uart_tx`  (`rtl/uart_tx.vhd`)
```text
uart_tx.vhd  8-N-1 UART transmitter. Bit timing from a 1x fractional tick.
Handshake: a byte is accepted on the clock edge where data_valid and ready
are both '1'. ready is high only in IDLE. 'done' pulses one clock when the
stop bit has been held for one full bit period.
Note: frame start waits for the next bit tick (<= 1 bit of latency), so
back-to-back frames may carry extra idle time. Stop bit is always >= 1 bit.
```

**Generics**

| Name | Type | Default |
|---|---|---|
| `CLK_FREQ_HZ` | `positive` | `50_000_000` |
| `BAUD_RATE` | `positive` | `9_600` |

**Ports**

| Name | Dir | Type | Note |
|---|---|---|---|
| `clk` | in | `std_logic` |  |
| `rst` | in | `std_logic` |  |
| `data_in` | in | `std_logic_vector(7 downto 0)` |  |
| `data_valid` | in | `std_logic` |  |
| `ready` | out | `std_logic` |  |
| `tx` | out | `std_logic` |  |
| `busy` | out | `std_logic` |  |
| `done` | out | `std_logic` |  |
