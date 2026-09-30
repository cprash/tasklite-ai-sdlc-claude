#!/usr/bin/env bash
# pre-push hook — runs before git push
# Enforces: full test suite, quality checks, secret scan

set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
BACKEND_DIR="$ROOT_DIR/backend"
SCRIPTS_DIR="$ROOT_DIR/scripts"

echo "[pre-push] Running pre-push checks..."
echo "[pre-push] This may take a moment — running the full test suite."

# 1. Full secret scan (all tracked files, not just staged)
echo "[pre-push] Running full secret scan..."
if ! bash "$SCRIPTS_DIR/scan-secrets.sh" --all; then
  echo "[pre-push] FAIL: Secret scan detected potential secrets."
  echo "[pre-push] Review the output above. Do not push secrets."
  exit 1
fi
echo "[pre-push] Secret scan: PASS"

# 2. Full test suite with coverage
echo "[pre-push] Running full test suite..."
if ! (cd "$BACKEND_DIR" && npm test -- --coverage --forceExit 2>&1); then
  echo "[pre-push] FAIL: Test suite failed."
  echo "[pre-push] Fix failing tests before pushing."
  exit 1
fi
echo "[pre-push] Test suite: PASS"

# 3. Full quality checks
echo "[pre-push] Running quality checks..."
if ! bash "$SCRIPTS_DIR/run-quality-checks.sh"; then
  echo "[pre-push] FAIL: Quality checks failed."
  echo "[pre-push] Review the output above and fix issues before pushing."
  exit 1
fi
echo "[pre-push] Quality checks: PASS"

# 4. Check that the most recent commit message includes the attribution footer
LATEST_COMMIT_MSG=$(git log -1 --pretty=%B)
if ! echo "$LATEST_COMMIT_MSG" | grep -q "Co-Authored-By:"; then
  echo "[pre-push] WARNING: Latest commit does not include a Co-Authored-By line."
  echo "[pre-push] If this was a Claude-assisted commit, add the attribution line."
  echo "[pre-push] Proceeding — this is a warning, not a blocker."
fi

echo "[pre-push] All pre-push checks passed."
echo "[pre-push] IMPORTANT: Human approval is required before pushing to main."
exit 0
