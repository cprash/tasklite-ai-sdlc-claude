#!/usr/bin/env bash
# run-quality-checks.sh — runs all quality gates for the project
#
# Checks: TypeScript compilation, ESLint, Jest with coverage, npm audit, doc validation
#
# Usage: bash scripts/run-quality-checks.sh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKEND_DIR="$ROOT_DIR/backend"
FRONTEND_DIR="$ROOT_DIR/frontend"
SCRIPTS_DIR="$ROOT_DIR/scripts"

PASS=0
FAIL=0
CHECKS=()

# ─── Helpers ──────────────────────────────────────────────────────────────────

check_pass() {
  local name="$1"
  CHECKS+=("  ✓  $name")
  PASS=$((PASS + 1))
}

check_fail() {
  local name="$1"
  local detail="${2:-}"
  CHECKS+=("  ✗  $name${detail:+ — $detail}")
  FAIL=$((FAIL + 1))
}

run_check() {
  local name="$1"
  shift
  echo ""
  echo "── $name ──"
  if "$@" 2>&1; then
    check_pass "$name"
  else
    check_fail "$name"
  fi
}

# ─── Checks ───────────────────────────────────────────────────────────────────

echo "TaskLite Quality Checks"
echo "========================"
echo "Root: $ROOT_DIR"
echo ""

# 1. Backend TypeScript compilation
echo "── TypeScript Compilation (backend) ──"
if (cd "$BACKEND_DIR" && npx tsc --noEmit 2>&1); then
  check_pass "TypeScript Compilation (backend)"
else
  check_fail "TypeScript Compilation (backend)"
fi

# 2. Backend ESLint
echo ""
echo "── ESLint (backend) ──"
if (cd "$BACKEND_DIR" && npx eslint src/ 2>&1); then
  check_pass "ESLint (backend)"
else
  check_fail "ESLint (backend)"
fi

# 3. Frontend ESLint
echo ""
echo "── ESLint (frontend) ──"
if [ -d "$FRONTEND_DIR" ] && (cd "$FRONTEND_DIR" && npx eslint src/ 2>&1); then
  check_pass "ESLint (frontend)"
else
  check_fail "ESLint (frontend)"
fi

# 4. Jest — unit tests with coverage
echo ""
echo "── Jest Unit Tests + Coverage (backend) ──"
if (cd "$BACKEND_DIR" && npm test -- --coverage --testPathPattern=unit --forceExit 2>&1); then
  check_pass "Jest Unit Tests (backend)"
else
  check_fail "Jest Unit Tests (backend)"
fi

# 5. Jest — integration tests
echo ""
echo "── Jest Integration Tests (backend) ──"
if (cd "$BACKEND_DIR" && npm test -- --testPathPattern=integration --forceExit 2>&1); then
  check_pass "Jest Integration Tests (backend)"
else
  check_fail "Jest Integration Tests (backend) — integration tests may not exist yet (expected before TASK-015)"
fi

# 6. Backend npm audit
echo ""
echo "── npm Audit (backend) ──"
if (cd "$BACKEND_DIR" && npm audit --audit-level=high 2>&1); then
  check_pass "npm Audit (backend)"
else
  check_fail "npm Audit (backend) — High or Critical vulnerabilities found"
fi

# 7. Frontend npm audit
echo ""
echo "── npm Audit (frontend) ──"
if [ -d "$FRONTEND_DIR" ] && (cd "$FRONTEND_DIR" && npm audit --audit-level=high 2>&1); then
  check_pass "npm Audit (frontend)"
else
  check_fail "npm Audit (frontend)"
fi

# 8. Documentation validation
echo ""
echo "── Documentation Validation ──"
if bash "$SCRIPTS_DIR/validate-docs.sh" 2>&1; then
  check_pass "Documentation Validation"
else
  check_fail "Documentation Validation"
fi

# 9. Secret scan
echo ""
echo "── Secret Scan ──"
if bash "$SCRIPTS_DIR/scan-secrets.sh" 2>&1; then
  check_pass "Secret Scan"
else
  check_fail "Secret Scan — potential secrets detected"
fi

# ─── Report ───────────────────────────────────────────────────────────────────

echo ""
echo "════════════════════════════════════════"
echo "Quality Check Summary"
echo "  Passed: $PASS"
echo "  Failed: $FAIL"
echo ""
echo "Results:"
for check in "${CHECKS[@]}"; do
  echo "$check"
done
echo ""

if [ "$FAIL" -gt 0 ]; then
  echo "FAIL — $FAIL quality check(s) did not pass."
  echo "Review the output above and fix issues before pushing."
  exit 1
fi

echo "PASS — All quality checks passed."
exit 0
