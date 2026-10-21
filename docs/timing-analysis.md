# Timing Analysis (calculated / simulated; no FPGA timing report exists)

## UART
- Clock 50 MHz (20 ns). Bit period 1/9600 = 104.167 us = 5208.33 clocks.
- Chosen approach: fractional accumulator clock enable. RX tick = 9600x16 = 153,600 Hz (325.52 clocks avg), TX tick = 9600 Hz.
  Long-term rate is exact; each tick lands within +/-1 clock (20 ns, 0.019 % of a bit).
  Measured in simulation: 7,680 RX ticks and 480 TX ticks in 50 ms (expected 7,680 / 480).
- RX samples at bit centre +/- 1/16 bit; verified error-free with sender +/-3 % off nominal back-to-back frames.
- Wire throughput 960 bytes/s. Longest frame (DECRYPT_REQ, 256 B): 291 bytes ~ 0.30 s; response up to 275 bytes ~ 0.29 s.

## Crypto latency (from the state machine, estimates not measurements)
- AES block: 11 clock edges (220 ns). GHASH block: 128 clocks (2.56 us).
- 256-byte transaction: 1 AAD + 16 data + 1 length GHASH ops (~18 x 130) + 18 AES ops + block loading ~ 3,000 clocks ~ 60 us,
  i.e. ~0.02 % of the wire time. The crypto engine is never the bottleneck at 9600 baud; the NV store write time will dominate.

## Constraints status
`constraints/timing_constraints.xdc` is a template (20 ns clock only). Fmax, utilisation and I/O timing are UNKNOWN until a real
target is chosen and implemented. Yosys/GHDL generic cell counts (reports/synthesis) are not FPGA resources.
Expected area hot-spots to check first: the 20 AES S-box lookups in the combinational round path (critical path), the
16x128-bit output buffer and the two 512x8 FIFOs (should infer RAM; verify).
