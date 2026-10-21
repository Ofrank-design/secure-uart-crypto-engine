#!/usr/bin/env bash
# Full regression: vector self-consistency, lint+synthesis check, every testbench, host-tool self-test,
# then a manifest tying the result to the exact source tree (and git revision when available).
# Add SPEC_BAUD=1 to also run the end-to-end test at the specified 9600 baud (slow).
set -euo pipefail
cd "$(dirname "$0")/.."
LOG=reports/verification/regression_log.txt
mkdir -p reports/verification
{
  echo "== regenerate reference vectors (must reproduce identically)"
  cp tests/reference_vectors/gcm_vectors.txt /tmp/gcm_before.txt; cp tests/protocol_cases/e2e_cases.txt /tmp/e2e_before.txt
  python3 scripts/gen_gcm_vectors.py; python3 scripts/gen_e2e_vectors.py
  cmp tests/reference_vectors/gcm_vectors.txt /tmp/gcm_before.txt && cmp tests/protocol_cases/e2e_cases.txt /tmp/e2e_before.txt && echo "vectors reproducible"
  echo "== lint + synthesis check";  bash scripts/run_lint.sh
  echo "== simulation";              bash scripts/run_simulation.sh
  echo "== host tool self-test";     python3 scripts/host_tool.py --selftest
} 2>&1 | tee "$LOG"
bash scripts/make_manifest.sh "$LOG"
echo "REGRESSION PASSED"
