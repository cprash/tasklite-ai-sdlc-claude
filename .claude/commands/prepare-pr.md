# /prepare-pr

Prepare all Git and GitHub artifacts for the pull request. Requires explicit human approval before any push or PR creation.

---

## When to Use

Use `/prepare-pr` after verification (`/verify`) passes and the human approves proceeding.

---

## Preconditions

- `/verify` passed (or the human approved proceeding with known limitations documented)
- All approved code review findings are resolved
- Human has confirmed the branch is ready for review

---

## Steps

### 1. Git Status Check

Run `git status` to verify the working tree state. If there are unexpected files, stop and report to the human.

```bash
git status
git diff --staged
```

### 2. Stage Changed Files

Stage only the files that are part of this feature. Do NOT use `git add -A` or `git add .` without reviewing what would be included.

```bash
git add backend/src/docs-sync/
git add backend/tests/
git add docs/
git add docs/requirements.md docs/architecture.md docs/design-review.md docs/impl-plan.md CHANGELOG.md
```

**Show the human the staged diff before committing:**
```bash
git diff --staged
```

### 3. Generate Changelog Entry

Update `CHANGELOG.md` under `[Unreleased]`:
- Add all new files under "Added"
- Add all modified files under "Changed"
- Add any removed files under "Removed"

### 4. Draft Commit Message

Draft a commit message following this format:
```
feat(docs-sync): implement automated documentation sync pipeline

- Add DocExtractor using ts-morph for JSDoc and OpenAPI extraction
- Add MarkdownGenerator for docs/api/ output
- Add SyncEngine orchestrating watch/sync/check modes
- Add DriftDetector for CI freshness checks
- Add full unit and integration test suite (≥80% coverage)

Closes #<issue number if applicable>

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
```

**Present the commit message to the human for approval before committing.**

### 5. Human Approval — Commit

Wait for explicit human approval before running `git commit`.

### 6. Draft PR Description

Generate the full PR description using this template:

```markdown
## Summary

<Two to three sentences describing what was built and why.>

## Changes Made

- `backend/src/docs-sync/` — <description>
- `docs/api/` — <description>
- `tests/` — <description>
- `docs/requirements.md`, `docs/architecture.md`, etc. — SDLC artifacts

## Requirements and Design

- Addresses: FR-001 through FR-008, NFR-001 through NFR-005
- Architecture decisions: See `docs/architecture.md` and `docs/decisions/`
- Design review findings resolved: CI-001, CI-002, CI-003

## Test Evidence

**Commands:**
\```bash
cd backend && npm test -- --coverage
\```

**Results:**
| Suite | Tests | Passed | Failed |
|-------|-------|--------|--------|
| unit | N | N | 0 |
| integration | N | N | 0 |

**Coverage:** N% lines (threshold: 80%)

## Security Review

- Secret-handling: SyncWriter aborts on detected secret patterns
- Input validation: file paths resolved and validated within project root
- Dependency audit: `npm audit` — 0 High/Critical
- Secrets scan: `bash scripts/scan-secrets.sh` — PASS

## Known Limitations

<List any Not Identified items, deferred items, or out-of-scope items.>

## Reviewer Checklist

- [ ] Requirements are satisfied
- [ ] Architecture and implementation are consistent
- [ ] Design-review findings have been addressed
- [ ] Unit and integration tests pass
- [ ] Error and edge cases are covered
- [ ] No secrets or sensitive values are committed
- [ ] Security and dependency checks are complete
- [ ] Documentation is complete and accurate
- [ ] Known limitations have been reviewed
- [ ] CI checks pass
- [ ] The implementation is ready to merge

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

**Present the PR description to the human for approval before creating the PR.**

### 7. Human Approval — Push and PR

Wait for explicit human approval before:
- Running `git push`
- Running `gh pr create`

### 8. Create PR (after human approval)

```bash
git push -u origin <branch-name>
gh pr create --title "<title>" --body "$(cat <<'EOF'
<PR description>
EOF
)"
```

---

## Human Approval Required

Claude must **never** run `git push` or `gh pr create` without explicit human approval.  
Human approval of the commit is separate from human approval of the push.

---

## Notes

- If `gh` CLI is not configured, provide the PR description for the human to paste into GitHub
- Include CI result links in the PR description once CI runs complete
- Do not merge the PR — merging requires human action
