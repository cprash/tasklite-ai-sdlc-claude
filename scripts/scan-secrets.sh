#!/usr/bin/env bash
# scan-secrets.sh — scans for hardcoded secrets and credentials
#
# Exits with code 1 if any potential secret is found.
# Never prints the matched secret value — only file:line references.
#
# Usage:
#   bash scripts/scan-secrets.sh           # scan staged files (pre-commit)
#   bash scripts/scan-secrets.sh --all     # scan all tracked files (pre-push / CI)
#   bash scripts/scan-secrets.sh <file>    # scan a specific file

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

FOUND=0
SCAN_MODE="staged"  # default: only staged files

# ─── Patterns ─────────────────────────────────────────────────────────────────
# These patterns are designed to catch real secrets, not variable names.
# They require the value to be present (quoted or after = with a non-trivial value).

PATTERNS=(
  # Generic key/secret assignments with a non-trivial quoted value
  'api[_-]?key\s*[:=]\s*['\''"][^'\''\"]{8,}['\''"]'
  'api[_-]?secret\s*[:=]\s*['\''"][^'\''\"]{8,}['\''"]'
  'password\s*[:=]\s*['\''"][^'\''\"]{4,}['\''"]'
  'passwd\s*[:=]\s*['\''"][^'\''\"]{4,}['\''"]'
  'secret\s*[:=]\s*['\''"][^'\''\"]{8,}['\''"]'
  'token\s*[:=]\s*['\''"][^'\''\"]{16,}['\''"]'
  'private[_-]?key\s*[:=]\s*['\''"][^'\''\"]{16,}['\''"]'

  # Database connection strings with credentials (user:pass@host)
  'postgres(ql)?://[^/\s:@]+:[^/\s:@]+@'
  'mysql://[^/\s:@]+:[^/\s:@]+@'
  'mongodb(\+srv)?://[^/\s:@]+:[^/\s:@]+@'
  'redis://:[^@]+@'

  # AWS access keys
  'AKIA[0-9A-Z]{16}'
  'ASIA[0-9A-Z]{16}'

  # GitHub / GitLab tokens
  'ghp_[0-9a-zA-Z]{36}'
  'gho_[0-9a-zA-Z]{36}'
  'github_pat_[0-9a-zA-Z_]{82}'
  'glpat-[0-9a-zA-Z_-]{20}'

  # JWT secrets (common patterns: long random strings after jwt_secret=)
  'jwt[_-]?secret\s*[:=]\s*['\''"][^'\''\"]{16,}['\''"]'

  # Bearer tokens in code (not in HTTP calls)
  'Bearer\s+[A-Za-z0-9_\-\.]{40,}'

  # Private key headers
  '-----BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----'
  '-----BEGIN CERTIFICATE-----'
)

# ─── Exclusions ───────────────────────────────────────────────────────────────
# Files that are explicitly allowed to contain these patterns (tests with placeholders, etc.)

EXCLUDE_PATTERNS=(
  'node_modules'
  '\.git/'
  'dist/'
  'coverage/'
  '\.snap$'
  'scan-secrets\.sh$'
  '\.env\.example$'
)

# Build exclude args for grep
EXCLUDE_ARGS=()
for excl in "${EXCLUDE_PATTERNS[@]}"; do
  EXCLUDE_ARGS+=("--exclude-dir=$(echo "$excl" | tr -d '/' | sed 's/\\..*$//')" 2>/dev/null || true)
done

# ─── Determine files to scan ──────────────────────────────────────────────────

FILES_TO_SCAN=()

if [ $# -ge 1 ] && [ "$1" != "--all" ]; then
  # Specific files passed as arguments
  FILES_TO_SCAN=("$@")
elif [ "$1" = "--all" ] 2>/dev/null || [ "${SCAN_MODE}" = "all" ]; then
  # All tracked files
  SCAN_MODE="all"
  mapfile -t FILES_TO_SCAN < <(git -C "$ROOT_DIR" ls-files 2>/dev/null || true)
else
  # Default: staged files only
  mapfile -t FILES_TO_SCAN < <(git -C "$ROOT_DIR" diff --cached --name-only --diff-filter=ACM 2>/dev/null || true)
fi

if [ ${#FILES_TO_SCAN[@]} -eq 0 ]; then
  echo "[scan-secrets] No files to scan."
  exit 0
fi

echo "[scan-secrets] Scanning ${#FILES_TO_SCAN[@]} file(s) for potential secrets..."
echo "[scan-secrets] Patterns checked: ${#PATTERNS[@]}"
echo ""

# ─── Scan ─────────────────────────────────────────────────────────────────────

for pattern in "${PATTERNS[@]}"; do
  for file in "${FILES_TO_SCAN[@]}"; do
    # Skip excluded patterns
    skip=false
    for excl in "${EXCLUDE_PATTERNS[@]}"; do
      if echo "$file" | grep -qE "$excl" 2>/dev/null; then
        skip=true
        break
      fi
    done
    $skip && continue

    abs_file="$ROOT_DIR/$file"
    [ -f "$abs_file" ] || abs_file="$file"
    [ -f "$abs_file" ] || continue

    # Search for the pattern — report file:line only, not the matched content
    while IFS= read -r match_line; do
      # Extract just the line number (before the colon)
      line_num="${match_line%%:*}"
      echo "[scan-secrets] POTENTIAL SECRET FOUND"
      echo "  File: $file"
      echo "  Line: $line_num"
      echo "  Pattern matched: $pattern"
      echo "  (value not shown for security)"
      echo ""
      FOUND=$((FOUND + 1))
    done < <(grep -inE "$pattern" "$abs_file" 2>/dev/null | cut -d: -f1 || true)
  done
done

# ─── Report ───────────────────────────────────────────────────────────────────

if [ "$FOUND" -gt 0 ]; then
  echo "[scan-secrets] FAIL — $FOUND potential secret(s) detected."
  echo "[scan-secrets] Review the file:line references above."
  echo "[scan-secrets] If these are false positives, add them to the exclusion list in this script."
  echo "[scan-secrets] NEVER commit real secrets, tokens, passwords, or connection strings."
  exit 1
fi

echo "[scan-secrets] PASS — No potential secrets detected."
exit 0
