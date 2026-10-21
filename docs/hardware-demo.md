# Hardware Demonstration Procedure (NOT YET EXECUTED - no target board)

Prerequisites: FPGA board with a USB-UART at 3.3 V logic, 50 MHz clock, bitstream built from the verified source revision,
NV store for the nonce counter and last SEQ (or the demo shim: initial values via constants -- for lab use only, nonce safety is then NOT guaranteed),
`pip install cryptography pyserial`.

1. Program the FPGA; open the serial port at 9600 8-N-1.
2. Host-encrypts / device-decrypts: `python scripts/host_tool.py --port <P> decrypt --seq 1 --key 000102030405060708090a0b0c0d0e0f --pt "hello"`
   Expect `decrypted seq 1 b'hello'`.
3. Replay: repeat the same command with `--seq 1`. Expect `error:replay`.
4. Tamper: flip one byte of the frame (use a serial tool); expect `error:authentication failed` and no plaintext.
5. Device-encrypts / host-verifies: `... encrypt --seq 2 --key <same> --pt "hello"`. Expect `encrypted seq 2 b'hello'` (tag verified on the host).
6. Reset during processing (press reset after sending a 256-byte request); expect silence, then a fresh request works.
7. Power-cycle and repeat step 3 with an old SEQ: must still be refused (needs real NV storage for the replay state).
8. Capture a logic-analyser or terminal log of each step and store it under `reports/verification/`.
Pass criteria: all eight steps behave as stated. Record board, part number, tool versions and bitstream hash.
