#!/usr/bin/env python3
"""End-to-end wire-level vectors for secure_uart_crypto_top (independent model: OpenSSL AES-GCM).
Output lines (tests/protocol_cases/e2e_cases.txt):
  REQ <request hex> <expected response hex>   send frame, expect exactly this response
  REQ_RESET <request hex>                     send frame, reset the device mid-processing, expect silence
  RESET                                       pulse reset (NV state survives)
  CTRVALID <0|1>                              nonce-counter NV valid flag
  ZEROIZE / LOADKEY <hex32>                   key zeroize / trusted key load
  EXPECT_STORE <hex64>                        last value written to the nonce NV store
  EXPECT_EVENTS <auth_fail> <replay> <parse>  status event pulse counts so far
Frame: A5 01 TYPE SEQ(2) NONCE(12) LEN(2) PAYLOAD [TAG(16) if TYPE in 01,81]
AAD  : VER || TYPE || SEQ || LEN  (TYPE of the frame that carries the tag)
Responses: 82 decrypt ok, 81 encrypt ok, E0 error (1 payload byte).
Codes: 01 auth, 02 replay, 03 NV/nonce unavailable, 04 no key, 05 reserved nonce prefix, 10|n parser.
"""
import os, random
from cryptography.hazmat.primitives.ciphers.aead import AESGCM

DEV = 0xC0FFEE01; CTR0 = 0x1000
KEY = bytes(range(16)); NEWKEY = bytes(range(0x80, 0x90))
g = AESGCM(KEY); rnd = random.Random(7)
out = []
st = dict(have=False, last=0, ctr=CTR0, ctrvalid=True, key=True)
ev = dict(auth=0, replay=0, parse=0)

def aad(t, seq, l): return bytes([1, t]) + seq.to_bytes(2, "big") + l.to_bytes(2, "big")
def frame(t, seq, nonce, payload, tag=b""):
    return b"\xA5\x01" + bytes([t]) + seq.to_bytes(2, "big") + nonce + len(payload).to_bytes(2, "big") + payload + tag
def err(seq, code): return frame(0xE0, seq, bytes(12), bytes([code]))
def line(req, resp): out.append("REQ %s %s" % (req.hex(), resp.hex()))
def perr(req, code): ev["parse"] += 1; line(req, err(0, code))

def dec(seq, pt, tamper=None, seq_used=None, nonce=None):
    nonce = nonce or rnd.randbytes(12)
    su = seq if seq_used is None else seq_used
    ct = g.encrypt(nonce, pt, aad(1, su, len(pt)))
    c, t = bytearray(ct[:-16]), bytearray(ct[-16:])
    if tamper == "tag": t[3] ^= 0x40
    if tamper == "ct" and c: c[-1] ^= 1
    n = bytearray(nonce)
    if tamper == "nonce": n[0] ^= 1
    req = frame(1, seq, bytes(n), bytes(c), bytes(t))
    if not st["key"]: resp = err(seq, 4)
    elif bytes(n[:4]) == DEV.to_bytes(4, "big"): resp = err(seq, 5)
    elif st["have"] and seq <= st["last"]: ev["replay"] += 1; resp = err(seq, 2)
    elif tamper or seq_used is not None: ev["auth"] += 1; resp = err(seq, 1)
    else:
        st["have"] = True; st["last"] = seq
        resp = frame(0x82, seq, bytes(n), pt)
    line(req, resp)

def enc(seq, pt):
    req = frame(2, seq, bytes(12), pt)
    if not st["key"]: resp = err(seq, 4)
    elif not st["ctrvalid"]: resp = err(seq, 3)
    else:
        nonce = DEV.to_bytes(4, "big") + st["ctr"].to_bytes(8, "big"); st["ctr"] += 1
        ct = g.encrypt(nonce, pt, aad(0x81, seq, len(pt)))
        resp = frame(0x81, seq, nonce, ct[:-16], ct[-16:])
    line(req, resp)

dec(1, rnd.randbytes(20))                 # valid decrypt
dec(1, rnd.randbytes(5))                  # replay (same seq)
dec(0, rnd.randbytes(5))                  # replay (lower seq)
dec(5, rnd.randbytes(16), "tag")          # bad tag, seq must not advance
dec(5, rnd.randbytes(33), "ct")           # tampered ciphertext
dec(5, rnd.randbytes(9), "nonce")         # tampered nonce
dec(5, rnd.randbytes(9), seq_used=4)      # header/AAD mismatch (seq tampered in flight)
dec(5, rnd.randbytes(17))                 # failures never advanced seq: accepted now
dec(6, b"")                               # empty payload, tag only
dec(7, rnd.randbytes(256))                # maximum payload
enc(7, rnd.randbytes(33))                 # encrypt, counter 0x1000
enc(8, b"")                               # encrypt empty
enc(9, rnd.randbytes(256))                # encrypt max
out.append("EXPECT_STORE %016x" % st["ctr"])
out.append("CTRVALID 0"); st["ctrvalid"] = False
enc(10, rnd.randbytes(4))                 # refused: counter not valid
out.append("CTRVALID 1"); st["ctrvalid"] = True
enc(11, rnd.randbytes(16))
out.append("EXPECT_STORE %016x" % st["ctr"])
perr(b"\xA5\x02", 0x11)                                            # bad version
perr(b"\xA5\x01\x09", 0x12)                                        # bad type
perr(b"\xA5\x01\x01" + bytes(2) + bytes(12) + b"\x01\x01", 0x13)   # LEN=257
perr(b"\xA5\x01\x01\x00", 0x14)                                    # truncated -> timeout
dec(12, rnd.randbytes(12))                # still healthy
dec(30, rnd.randbytes(8), nonce=DEV.to_bytes(4, "big") + rnd.randbytes(8))   # reserved nonce prefix
# --- reset behaviour: replay state and nonce counter are persisted, in-flight work is discarded
dec(20, rnd.randbytes(10))
nonce = rnd.randbytes(12); ct = g.encrypt(nonce, rnd.randbytes(256), aad(1, 21, 256))
out.append("REQ_RESET " + frame(1, 21, nonce, ct[:-16], ct[-16:]).hex())   # reset mid-decrypt
dec(21, rnd.randbytes(40))                # seq 21 was never consumed: accepted
out.append("RESET")
dec(20, rnd.randbytes(10))                # replay of an old packet after reset/power cycle: refused
enc(40, rnd.randbytes(7))                 # counter continues from NV, no nonce reuse
out.append("EXPECT_STORE %016x" % st["ctr"])
# --- key lifecycle
out.append("ZEROIZE"); st["key"] = False
dec(31, rnd.randbytes(8))                 # no key -> refused
enc(14, rnd.randbytes(8))                 # no key -> refused
out.append("LOADKEY " + NEWKEY.hex()); st["key"] = True; g = AESGCM(NEWKEY)
dec(32, rnd.randbytes(18))                # works under the newly loaded key
enc(33, rnd.randbytes(18))
out.append("EXPECT_STORE %016x" % st["ctr"])
out.append("EXPECT_EVENTS %d %d %d" % (ev["auth"], ev["replay"], ev["parse"]))

p = os.path.join(os.path.dirname(__file__), "..", "tests", "protocol_cases", "e2e_cases.txt")
open(p, "w").write("\n".join(out) + "\n")
print(len(out), "lines written", ev)
