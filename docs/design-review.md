# Design Review — Automated Documentation Sync

**Project:** TaskLite  
**Feature:** Automated Documentation Sync  
**Reviewer:** Claude (design-reviewer agent)  
**Review Date:** 2026-09-30  
**Architecture Reviewed:** `architecture.md` v1.0  
**Status:** Approved with Conditions

---

## 1. Review Summary

The proposed architecture for the Automated Documentation Sync feature is sound. The component decomposition is clean, the data flow is unidirectional, and the choice of `ts-morph` is well-justified. Three confirmed issues and four potential risks were identified. Two decisions require human approval before implementation begins.

**Recommendation:** Proceed to implementation after resolving the two items marked "Requires Human Approval."

---

## 2. Confirmed Issues

### CI-001 — Missing Secret-Pattern Check in SyncWriter (Severity: High)

**Description:** `architecture.md` section 7 mentions that `SyncWriter` should check generated content for secrets before writing, but no acceptance criterion in `requirements.md` specifies the regex patterns, the false-positive policy, or what happens when a secret is detected (abort? redact? warn?).

**Impact:** Without a defined behaviour, the secret check may be inconsistently implemented or skipped.

**Recommendation:** Add an acceptance criterion to NFR-002 specifying: (a) the pattern set (API key, JWT, database URL, AWS key), (b) behaviour on detection (abort write, log error, do not log matched value), and (c) that `scripts/scan-secrets.sh` is run on `docs/api/` in CI.

**Decision:** Human approval required — see HR-001.

---

### CI-002 — No Error Recovery Specification for SyncWriter (Severity: Medium)

**Description:** NFR-004 specifies that the watcher must not crash on extraction errors, but there is no specification for what happens when `SyncWriter` fails to write a file (e.g., permission error, disk full).

**Impact:** A write failure in sync mode would silently leave the documentation out of date.

**Recommendation:** Define the error-handling contract for `SyncWriter`: log the error with structured JSON, include the file path and error message, continue with remaining files, and include the failed file in the sync report under an "Errors" section.

**Status:** Confirmed. Will be addressed in `impl-plan.md` task TASK-005.

---

### CI-003 — `docs/api/` Git Status Undefined (Severity: Medium)

**Description:** Open Question OQ-001 in `architecture.md` asks whether `docs/api/` should be committed to Git or gitignored. This has implications for the CI `docs:check` command — if `docs/api/` is gitignored, there are no committed docs to check against in CI.

**Impact:** The `docs:check` CI step will either always fail (if docs aren't committed) or be meaningless (if docs are committed but stale).

**Recommendation:** Decide before implementation whether `docs/api/` is committed (and `docs:check` verifies freshness by timestamp) or generated-on-the-fly in CI (and `docs:check` verifies the generation succeeds without errors).

**Decision:** Human approval required — see HR-002.

---

## 3. Potential Risks

### PR-001 — ts-morph Version Lock (Medium Likelihood, High Impact)

`ts-morph` re-exports the TypeScript compiler. If the project's `typescript` version is upgraded, `ts-morph` must be upgraded in lockstep. A mismatch causes silent AST parsing failures.

**Mitigation:** Pin `typescript` and `ts-morph` to compatible versions in `package.json`. Add a compatibility note to `CLAUDE.md` under known constraints.

---

### PR-002 — chokidar Polling on Windows Network Drives (Low Likelihood, Medium Impact)

`chokidar` defaults to native file-system events, which may not fire reliably on Windows network drives or WSL2 mounts.

**Mitigation:** Document that `DOCS_SYNC_USE_POLLING=true` enables polling mode. Default to native events.

---

### PR-003 — Manual Edits to `docs/api/` (Medium Likelihood, High Impact)

A developer might hand-edit a file in `docs/api/`, which will be silently overwritten on the next sync.

**Mitigation:** `SyncWriter` checks for a `<!-- generated:` header before overwriting. If the header is absent, it logs a warning and skips the overwrite. Behaviour is documented in `docs/user-story.md`.

---

### PR-004 — Circular Import if Logger Used in All Modules (Low Likelihood, Low Impact)

If every module imports from `logger.ts` and `logger.ts` imports from any other module, a circular dependency could emerge.

**Mitigation:** `logger.ts` must have zero imports from other `docs-sync` modules. Enforce via ESLint `import/no-cycle`.

---

## 4. Recommendations

### REC-001 — Add `docs/api/.gitkeep` with a README

Add a `docs/api/README.md` (manually maintained) explaining that files in this directory are auto-generated. This prevents confusion and is not overwritten by `SyncWriter` because it lacks a `<!-- generated:` header.

### REC-002 — Add `DOCS_SYNC_*` Env Vars to `docs/technical-profile.md`

Document all `DOCS_SYNC_*` environment variables in `docs/technical-profile.md` so they appear in the technical profile and are available to new developers.

### REC-003 — Add `docs:check` to CI Pipeline Separately from Tests

Run `npm run docs:check` as a separate CI step (not inside the test suite) so documentation drift fails the build independently and is easy to identify in CI logs.

### REC-004 — Integration Test Against a Fixture Directory

The `DocExtractor` and `MarkdownGenerator` should have integration tests that run against a `tests/fixtures/` directory containing representative TypeScript files. This makes tests deterministic and independent of the live `backend/src/`.

---

## 5. Decisions Requiring Human Approval

### HR-001 — Secret Detection Behaviour in SyncWriter

**Question:** When `SyncWriter` detects a potential secret in generated content, should it:
- (A) Abort the write entirely and log an error
- (B) Redact the matched string with `[REDACTED]` and continue
- (C) Write the file but emit a warning

**Recommended:** Option A (abort). Secrets in documentation are a security incident, not a warning.

**Status:** Awaiting human decision.

---

### HR-002 — `docs/api/` Git Commit Strategy

**Question:** Should `docs/api/` be:
- (A) Committed to Git — `docs:check` verifies timestamps in CI, fails if stale
- (B) Gitignored — `docs:sync` runs in CI as a generation step, `docs:check` verifies no errors

**Recommended:** Option A — committed, so PR reviewers can see documentation changes alongside code changes.

**Status:** Awaiting human decision.

---

## 6. Deferred / Out-of-Scope Items

| Item | Reason |
|------|--------|
| Confluence sync | No instance URL or credentials identified (NI-001) |
| GitHub Wiki sync | Not in scope for this iteration |
| Slack notifications on drift | Not in scope |
| TSDoc support | Only JSDoc in scope; TSDoc deferred |
| React component prop documentation | Frontend doc extraction deferred |

---

## 7. Decisions Made and Recorded

| ID | Decision | Recorded In |
|----|---------|------------|
| DEC-001 | Use `ts-morph` for TypeScript AST parsing | `docs/decisions/ADR-001-doc-extraction-library.md` |
| DEC-002 | Use `chokidar` for cross-platform file watching | `architecture.md` section 5 |
| DEC-003 | `docs/api/` is output-only; no hand-editing | `architecture.md` section 7 + `docs/user-story.md` |

---

---

# Design Review — Edit Task Title (Inline)

**Project:** TaskLite
**Feature:** Edit Task Title (Inline)
**Reviewer:** Claude (design-reviewer agent)
**Review Date:** 2026-10-01
**Architecture Reviewed:** `architecture.md` — Edit Task Title section
**Status:** Approved with Conditions

---

## 1. Review Summary

The proposed architecture is minimal and correct. Lifting `editingTaskId` to `App` cleanly satisfies the mutual-exclusion requirement. One confirmed issue and two potential risks were identified. One item requires human approval before implementation.

**Recommendation:** Proceed to implementation after resolving HR-003.

---

## 2. Confirmed Issues

### CI-004 — No Exit Mechanism for Edit Mode (Severity: Medium)

**Description:** The story and architecture define how to *enter* edit mode but specify no way to *exit* it without saving. There is no Escape key handler, no click-outside handler, and no Cancel button specified. A user who activates edit mode accidentally has no recovery path in this story.

**Impact:** Moderate UX friction. The Toggle Status and Delete buttons are disabled while editing, so the user is stuck in edit mode until a future save story ships.

**Recommendation:** Add a Cancel/Escape mechanism to exit edit mode and restore the title span, even if saving is deferred. This is low-cost and prevents a broken partial state.

**Decision:** Human approval required — see HR-003.

---

## 3. Potential Risks

### PR-005 — Edit Input Width on Narrow Viewports (Low Likelihood, Medium Impact)

On small viewports the inline `<input>` may overflow or collapse the action buttons into a second line in an unexpected way.

**Mitigation:** Set `width: 100%` with `box-sizing: border-box` on the edit input; constrain action buttons to `flex-shrink: 0` so they don't disappear.

---

### PR-006 — Multiple Rapid Clicks on Edit Button (Low Likelihood, Low Impact)

Clicking Edit on a task that is already in edit mode (e.g. via keyboard repeat) re-calls `setEditingTaskId` with the same id, which is a no-op in React — no issue. Confirmed safe.

---

## 4. Decisions Requiring Human Approval

### HR-003 — Exit Mechanism for Edit Mode

**Question:** Should this story include a Cancel / Escape-key handler to exit edit mode, or should that be deferred to the save story?

- (A) Add Escape key handler now — pressing Escape exits edit mode and restores view mode
- (B) Defer — exit mechanism ships with the save story

**Recommended:** Option A. Implementing Escape exit costs ~5 lines and prevents a UX dead end in the interim.

**Status:** Awaiting human decision.
