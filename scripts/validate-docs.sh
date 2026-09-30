#!/usr/bin/env bash
# validate-docs.sh — validates Markdown documentation files
#
# Usage:
#   bash scripts/validate-docs.sh              # validate all docs
#   bash scripts/validate-docs.sh <file.md>    # validate a single file

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0
FAIL=0
ERRORS=()

# ─── Helpers ──────────────────────────────────────────────────────────────────

fail() {
  local file="$1"
  local message="$2"
  ERRORS+=("  FAIL  $file: $message")
  FAIL=$((FAIL + 1))
}

pass() {
  PASS=$((PASS + 1))
}

# ─── Validate a single Markdown file ─────────────────────────────────────────

validate_file() {
  local file="$1"
  local basename
  basename="$(basename "$file")"
  local ok=true

  # 1. File must exist and be non-empty
  if [ ! -s "$file" ]; then
    fail "$file" "File is empty or does not exist"
    return
  fi

  # 2. No raw "TODO" markers (case-insensitive)
  if grep -qiE "^\s*TODO\s*:" "$file" 2>/dev/null; then
    fail "$file" "Contains TODO markers — resolve before committing"
    ok=false
  fi

  # 3. No raw "TBD" placeholders (as standalone words, not part of a word)
  if grep -qE '\bTBD\b' "$file" 2>/dev/null; then
    fail "$file" "Contains TBD placeholders — replace with 'Not Identified: <reason>' or actual value"
    ok=false
  fi

  # 4. SDLC documents must have a Status line
  if [[ "$basename" =~ ^(requirements|architecture|design-review|impl-plan)\.md$ ]]; then
    if ! grep -qE '^\*\*Status:\*\*' "$file" 2>/dev/null; then
      fail "$file" "Missing **Status:** line — add 'Draft', 'Approved', or 'Superseded'"
      ok=false
    fi
  fi

  # 5. SDLC documents must have a Last Updated line
  if [[ "$basename" =~ ^(requirements|architecture|design-review|impl-plan)\.md$ ]]; then
    if ! grep -qE '^\*\*Last Updated:\*\*' "$file" 2>/dev/null; then
      fail "$file" "Missing **Last Updated:** line"
      ok=false
    fi
  fi

  # 6. Generated docs in docs/api/ must have the generated header
  if [[ "$file" == */docs/api/* && "$basename" != "README.md" ]]; then
    if ! grep -q '<!-- generated:' "$file" 2>/dev/null; then
      fail "$file" "Missing '<!-- generated: <timestamp> -->' header — file may be hand-edited or generation failed"
      ok=false
    fi
  fi

  # 7. Check heading hierarchy — H1 must appear before H2
  # (simple check: first heading must be H1)
  FIRST_HEADING=$(grep -Em1 '^#+\s' "$file" 2>/dev/null || true)
  if [ -n "$FIRST_HEADING" ] && ! echo "$FIRST_HEADING" | grep -qE '^# '; then
    fail "$file" "First heading is not H1 — headings must start at level 1"
    ok=false
  fi

  # 8. No lines longer than 300 characters (catches accidentally concatenated content)
  if awk 'length > 300 { exit 1 }' "$file" 2>/dev/null; then
    : # all lines within limit
  else
    fail "$file" "Contains lines longer than 300 characters — possible formatting issue"
    ok=false
  fi

  if $ok; then
    pass
    echo "  PASS  $file"
  fi
}

# ─── Main ─────────────────────────────────────────────────────────────────────

if [ $# -ge 1 ]; then
  # Validate specific files passed as arguments
  for f in "$@"; do
    validate_file "$f"
  done
else
  # Validate all Markdown files in docs/ and root SDLC docs
  echo "Validating all documentation files..."
  while IFS= read -r -d '' file; do
    validate_file "$file"
  done < <(find "$ROOT_DIR/docs" -name "*.md" -print0 2>/dev/null)

  for sdlc_file in requirements.md architecture.md design-review.md impl-plan.md CLAUDE.md; do
    if [ -f "$ROOT_DIR/$sdlc_file" ]; then
      validate_file "$ROOT_DIR/$sdlc_file"
    fi
  done
fi

# ─── Report ───────────────────────────────────────────────────────────────────

echo ""
echo "────────────────────────────────────────"
echo "Documentation Validation Summary"
echo "  Passed: $PASS"
echo "  Failed: $FAIL"

if [ ${#ERRORS[@]} -gt 0 ]; then
  echo ""
  echo "Issues found:"
  for err in "${ERRORS[@]}"; do
    echo "$err"
  done
  echo ""
  exit 1
fi

echo "All documentation checks passed."
exit 0
