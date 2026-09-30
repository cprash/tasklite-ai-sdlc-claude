#!/usr/bin/env bash
# pre-commit hook — runs before every git commit
# Enforces: lint, type-check, secret scan

set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
BACKEND_DIR="$ROOT_DIR/backend"
SCRIPTS_DIR="$ROOT_DIR/scripts"

echo "[pre-commit] Running pre-commit checks..."

# 1. Secret scan — must pass before anything else
echo "[pre-commit] Running secret scan..."
if ! bash "$SCRIPTS_DIR/scan-secrets.sh"; then
  echo "[pre-commit] FAIL: Secret scan detected potential secrets in staged files."
  echo "[pre-commit] Review the output above. Do not commit secrets."
  exit 1
fi
echo "[pre-commit] Secret scan: PASS"

# 2. TypeScript type check
echo "[pre-commit] Running TypeScript type check..."
if ! (cd "$BACKEND_DIR" && npx tsc --noEmit 2>&1); then
  echo "[pre-commit] FAIL: TypeScript type check failed."
  echo "[pre-commit] Fix type errors before committing."
  exit 1
fi
echo "[pre-commit] TypeScript type check: PASS"

# 3. ESLint — only on staged .ts and .tsx files
STAGED_TS_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(ts|tsx)$' | grep -v 'node_modules' || true)

if [ -n "$STAGED_TS_FILES" ]; then
  echo "[pre-commit] Running ESLint on staged files..."
  # Convert to absolute paths and run ESLint
  ABS_FILES=""
  for f in $STAGED_TS_FILES; do
    ABS_FILES="$ABS_FILES $ROOT_DIR/$f"
  done
  if ! (cd "$BACKEND_DIR" && npx eslint $ABS_FILES 2>&1); then
    echo "[pre-commit] FAIL: ESLint found errors."
    echo "[pre-commit] Run 'npx eslint --fix' on the failing files and re-stage."
    exit 1
  fi
  echo "[pre-commit] ESLint: PASS"
else
  echo "[pre-commit] No staged TypeScript files — skipping ESLint."
fi

echo "[pre-commit] All pre-commit checks passed."
exit 0
