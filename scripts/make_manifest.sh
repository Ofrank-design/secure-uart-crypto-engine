#!/usr/bin/env bash
# Records which exact sources and tool versions a regression result belongs to.
# Usage: scripts/make_manifest.sh <regression-log>  -> reports/verification/manifest.txt
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p reports/verification
OUT=reports/verification/manifest.txt
{
  echo "Secure UART Crypto Engine - regression manifest"
  echo "date (UTC): $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "ghdl: $(ghdl --version | head -1)"
  echo "yosys: $(yosys -V 2>/dev/null || echo n/a)"
  echo "python cryptography: $(python3 -c 'import cryptography;print(cryptography.__version__)' 2>/dev/null || echo n/a)"
  if git rev-parse --short HEAD >/dev/null 2>&1; then echo "git: $(git rev-parse HEAD) $(git diff --quiet HEAD -- rtl tb tests scripts constraints && echo clean || echo DIRTY)"; else echo "git: not a repository"; fi
  echo "tree hash (sha256 of sorted per-file hashes of rtl/ tb/ tests/ scripts/ constraints/):"
  find rtl tb tests scripts constraints -type f | sort | xargs sha256sum | tee /tmp/_files.txt >/dev/null
  sha256sum /tmp/_files.txt | cut -d' ' -f1
  echo "--- files"; cat /tmp/_files.txt
  if [ -n "${1:-}" ] && [ -f "$1" ]; then
    echo "--- regression result lines ($1)"; grep -E "ALL TESTS PASSED|PASS  |ALL TESTBENCHES|assertion|error" "$1"
  fi
} > "$OUT"
echo "wrote $OUT"; sed -n 1,8p "$OUT"
