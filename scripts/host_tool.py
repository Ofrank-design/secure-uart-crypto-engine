#!/usr/bin/env python3
"""Host-side tool for the Secure UART Crypto Engine (protocol v1, see docs/protocol-specification.md).

  host_tool.py --selftest                         check this tool against tests/protocol_cases/e2e_cases.txt
  host_tool.py --port COM3 decrypt --seq 5 --key HEX --pt "hello"     (host encrypts, device decrypts)
  host_tool.py --port COM3 encrypt --seq 6 --key HEX --pt "hello"     (device encrypts, host verifies)

Host nonces MUST NOT start with the device ID (C0FFEE01 by default); the device refuses them (code 05).
Needs: pip install cryptography pyserial
"""
import argparse, os, sys, time
from cryptography.hazmat.primitives.ciphers.aead import AESGCM

DEV_ID = bytes.fromhex("C0FFEE01")
ERR = {1: "authentication failed", 2: "replay (seq not greater than last)", 3: "NV/nonce unavailable",
       4: "no key loaded", 5: "reserved nonce prefix", 6: "encrypt disabled",
       0x11: "bad version", 0x12: "bad type", 0x13: "bad length", 0x14: "timeout"}

def aad(t, seq, l): return bytes([1, t]) + seq.to_bytes(2, "big") + l.to_bytes(2, "big")
def frame(t, seq, nonce, payload, tag=b""):
    return b"\xA5\x01" + bytes([t]) + seq.to_bytes(2, "big") + nonce + len(payload).to_bytes(2, "big") + payload + tag

def build_decrypt_request(key, seq, pt, nonce=None):
    nonce = nonce or os.urandom(12)
    if nonce[:4] == DEV_ID: raise ValueError("nonce prefix reserved for the device")
    ct = AESGCM(key).encrypt(nonce, pt, aad(1, seq, len(pt)))
    return frame(1, seq, nonce, ct[:-16], ct[-16:])

def build_encrypt_request(seq, pt): return frame(2, seq, bytes(12), pt)

def parse_response(buf, key=None):
    """Returns (kind, seq, payload). Verifies the GCM tag of type-81 frames when key is given."""
    if len(buf) < 19 or buf[0] != 0xA5 or buf[1] != 1: raise ValueError("bad frame")
    t, seq, nonce, ln = buf[2], int.from_bytes(buf[3:5], "big"), buf[5:17], int.from_bytes(buf[17:19], "big")
    body = buf[19:]
    if t == 0xE0:
        code = body[0]; return ("error:%s" % ERR.get(code, hex(code)), seq, body[:1])
    if t == 0x82: return ("decrypted", seq, body[:ln])
    if t == 0x81:
        ct, tag = body[:ln], body[ln:ln + 16]
        if len(tag) != 16: raise ValueError("truncated tag")
        if key is None: return ("encrypted-unverified", seq, ct + tag)
        return ("encrypted", seq, AESGCM(key).decrypt(nonce, ct + tag, aad(0x81, seq, ln)))  # raises on bad tag
    raise ValueError("unknown type %02x" % t)

def expected_len(head):
    ln = int.from_bytes(head[17:19], "big")
    return 19 + ln + (16 if head[2] == 0x81 else 0)

def read_frame(ser, timeout=5.0):
    ser.timeout = timeout
    head = ser.read(19)
    if len(head) < 19: raise TimeoutError("no response")
    return head + ser.read(expected_len(head) - 19)

def selftest():
    keys = [bytes(range(16)), bytes(range(0x80, 0x90))]
    n = 0
    for ln in open(os.path.join(os.path.dirname(__file__), "..", "tests", "protocol_cases", "e2e_cases.txt")):
        p = ln.split()
        if not p or p[0] != "REQ": continue
        resp = bytes.fromhex(p[2]); kind, seq, pl = None, None, None
        for k in keys + [None]:
            try: kind, seq, pl = parse_response(resp, k); break
            except Exception: continue
        assert kind is not None, "could not parse/verify response: " + p[2][:40]
        if resp[2] == 0x81: assert kind == "encrypted", "type-81 tag did not verify against the OpenSSL key"
        n += 1
    print("host_tool selftest: parsed and verified %d device responses" % n)

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--selftest", action="store_true"); ap.add_argument("--port"); ap.add_argument("--baud", type=int, default=9600)
    sub = ap.add_subparsers(dest="cmd")
    for c in ("decrypt", "encrypt"):
        sp = sub.add_parser(c); sp.add_argument("--seq", type=int, required=True)
        sp.add_argument("--key", required=True); sp.add_argument("--pt", required=True)
    a = ap.parse_args()
    if a.selftest: selftest(); sys.exit(0)
    import serial
    key = bytes.fromhex(a.key); pt = a.pt.encode()
    with serial.Serial(a.port, a.baud) as ser:
        ser.write(build_decrypt_request(key, a.seq, pt) if a.cmd == "decrypt" else build_encrypt_request(a.seq, pt))
        kind, seq, pl = parse_response(read_frame(ser), key)
        print(kind, "seq", seq, pl)
