#!/usr/bin/env python3
"""Generate AES-128-GCM reference vectors with an independent implementation
(python 'cryptography' / OpenSSL). Also asserts the published McGrew-Viega/NIST
test cases 1-4 against that implementation. Line format (hex, '-' = empty):
    key iv aad plaintext ciphertext tag
"""
import os, random
from cryptography.hazmat.primitives.ciphers.aead import AESGCM

def h(b): return b.hex() if b else "-"

def vec(key, iv, aad, pt):
    out = AESGCM(key).encrypt(iv, pt, aad)
    return key, iv, aad, pt, out[:-16], out[-16:]

published = [  # (key, iv, aad, pt, expected tag)  -- NIST GCM spec test cases 1-4
    ("00"*16, "00"*12, "", "", "58e2fccefa7e3061367f1d57a4e7455a"),
    ("00"*16, "00"*12, "", "00"*16, "ab6e47d42cec13bdf53a67b21257bddf"),
    ("feffe9928665731c6d6a8f9467308308", "cafebabefacedbaddecaf888", "",
     "d9313225f88406e5a55909c5aff5269a86a7a9531534f7da2e4c303d8a318a721c3c0c95956809532fcf0e2449a6b525b16aedf5aa0de657ba637b391aafd255",
     "4d5c2af327cd64a62cf35abd2ba6fab4"),
    ("feffe9928665731c6d6a8f9467308308", "cafebabefacedbaddecaf888",
     "feedfacedeadbeeffeedfacedeadbeefabaddad2",
     "d9313225f88406e5a55909c5aff5269a86a7a9531534f7da2e4c303d8a318a721c3c0c95956809532fcf0e2449a6b525b16aedf5aa0de657ba637b39",
     "5bc94fbc3221a5db94fae95ae7121a47"),
]
lines = []
for k, iv, a, p, t in published:
    v = vec(bytes.fromhex(k), bytes.fromhex(iv), bytes.fromhex(a), bytes.fromhex(p))
    assert v[5].hex() == t, "published vector mismatch"
    lines.append(v)

rnd = random.Random(20261021)
lens = [0, 1, 15, 16, 17, 31, 32, 33, 47, 48, 49, 64]
for al in [0, 1, 15, 16, 17, 20, 33]:
    for pl in lens:
        lines.append(vec(rnd.randbytes(16), rnd.randbytes(12), rnd.randbytes(al), rnd.randbytes(pl)))
for _ in range(20):
    lines.append(vec(rnd.randbytes(16), rnd.randbytes(12), rnd.randbytes(rnd.randint(0, 40)), rnd.randbytes(rnd.randint(0, 70))))

path = os.path.join(os.path.dirname(__file__), "..", "tests", "reference_vectors", "gcm_vectors.txt")
with open(path, "w") as f:
    for k, iv, a, p, c, t in lines:
        f.write(" ".join([h(k), h(iv), h(a), h(p), h(c), h(t)]) + "\n")
print(len(lines), "vectors written; published vectors 1-4 confirmed")
