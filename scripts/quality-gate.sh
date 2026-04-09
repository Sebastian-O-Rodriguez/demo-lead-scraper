#!/bin/bash
# Run all quality gates
# Usage: ./scripts/quality-gate.sh [target]
# Targets: types, lint, build, all (default)

set -euo pipefail

TARGET="${1:-all}"
PASS=0
FAIL=0

run_gate() {
  local name="$1"
  local cmd="$2"
  echo -n "  $name... "
  if eval "$cmd" > /dev/null 2>&1; then
    echo "pass"
    ((PASS++))
  else
    echo "FAIL"
    ((FAIL++))
  fi
}

echo "=== Quality Gates ==="
echo ""

case "$TARGET" in
  types)  run_gate "TypeScript" "npx tsc --noEmit" ;;
  lint)   run_gate "ESLint" "npx eslint . --max-warnings 0" ;;
  build)  run_gate "Build" "npx next build" ;;
  all)
    run_gate "TypeScript" "npx tsc --noEmit"
    run_gate "ESLint" "npx eslint . --max-warnings 0"
    run_gate "Build" "npx next build"
    ;;
  *)
    echo "Unknown target: $TARGET"
    echo "Usage: quality-gate.sh [types|lint|build|all]"
    exit 1
    ;;
esac

echo ""
echo "Results: $PASS passed, $FAIL failed"

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
