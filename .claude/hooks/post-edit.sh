#!/usr/bin/env bash
# post-edit hook — runs after a file is edited by Claude
# Lints TypeScript files; validates Markdown documentation files
#
# Usage: post-edit.sh <edited-file-path>

set -euo pipefail

EDITED_FILE="${1:-}"

if [ -z "$EDITED_FILE" ]; then
  echo "[post-edit] No file path provided — skipping."
  exit 0
fi

ROOT_DIR="$(git rev-parse --show-toplevel)"
BACKEND_DIR="$ROOT_DIR/backend"
SCRIPTS_DIR="$ROOT_DIR/scripts"

# Normalise to absolute path
if [[ "$EDITED_FILE" != /* ]]; then
  EDITED_FILE="$ROOT_DIR/$EDITED_FILE"
fi

# Only act if the file exists
if [ ! -f "$EDITED_FILE" ]; then
  echo "[post-edit] File not found: $EDITED_FILE — skipping."
  exit 0
fi

# 1. TypeScript files in backend/src/ — auto-fix lint
if [[ "$EDITED_FILE" == "$BACKEND_DIR/src/"* && "$EDITED_FILE" == *.ts ]]; then
  echo "[post-edit] TypeScript file edited — running ESLint --fix..."
  if ! (cd "$BACKEND_DIR" && npx eslint "$EDITED_FILE" --fix 2>&1); then
    echo "[post-edit] ESLint could not auto-fix all issues in: $EDITED_FILE"
    echo "[post-edit] Review remaining lint errors manually."
    # Non-fatal: exit 0 to allow the edit to stand; human will see lint errors at commit
  else
    echo "[post-edit] ESLint --fix: done"
  fi
fi

# 2. Markdown files in docs/ — validate documentation structure
if [[ "$EDITED_FILE" == "$ROOT_DIR/docs/"* && "$EDITED_FILE" == *.md ]]; then
  echo "[post-edit] Markdown doc edited — running validate-docs.sh..."
  if ! bash "$SCRIPTS_DIR/validate-docs.sh" "$EDITED_FILE" 2>&1; then
    echo "[post-edit] Documentation validation found issues in: $EDITED_FILE"
    echo "[post-edit] Review the issues above before committing."
    # Non-fatal: exit 0 to allow the edit to stand
  else
    echo "[post-edit] Documentation validation: PASS"
  fi
fi

# 3. Root-level SDLC Markdown files
if [[ "$EDITED_FILE" == "$ROOT_DIR/requirements.md" || \
      "$EDITED_FILE" == "$ROOT_DIR/architecture.md" || \
      "$EDITED_FILE" == "$ROOT_DIR/design-review.md" || \
      "$EDITED_FILE" == "$ROOT_DIR/impl-plan.md" ]]; then
  echo "[post-edit] SDLC document edited — running validate-docs.sh..."
  if ! bash "$SCRIPTS_DIR/validate-docs.sh" "$EDITED_FILE" 2>&1; then
    echo "[post-edit] SDLC document validation found issues in: $EDITED_FILE"
  else
    echo "[post-edit] SDLC document validation: PASS"
  fi
fi

exit 0
