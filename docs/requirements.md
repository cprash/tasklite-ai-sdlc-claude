# Requirements — Automated Documentation Sync

**Project:** TaskLite  
**Feature:** Automated Documentation Sync  
**Status:** Approved  
**Last Updated:** 2026-09-30  
**Source:** `docs/user-story.md`

---

## 1. Functional Requirements

### FR-001 — File Change Detection

Claude must watch the `backend/src/` and `frontend/src/` directories for file-system changes (create, modify, delete) and trigger documentation extraction when a `.ts` or `.tsx` file changes.

**Acceptance Criteria:**
- AC-001-1: When a `.ts` file in `backend/src/` is saved, extraction runs within 2 seconds.
- AC-001-2: When a `.tsx` file in `frontend/src/` is saved, extraction runs within 2 seconds.
- AC-001-3: Changes to files outside `backend/src/` and `frontend/src/` do not trigger extraction.
- AC-001-4: File deletion removes the corresponding generated doc file from `docs/api/`.

---

### FR-002 — JSDoc Extraction

The system must extract JSDoc comments from TypeScript source files and convert them to structured documentation data.

**Acceptance Criteria:**
- AC-002-1: `@param`, `@returns`, `@throws`, `@example`, and `@deprecated` JSDoc tags are extracted.
- AC-002-2: Functions without JSDoc are listed as undocumented in the sync report.
- AC-002-3: Extraction handles TypeScript generics and union types without error.
- AC-002-4: Private functions (prefixed `_` or marked `private`) are excluded from output.

---

### FR-003 — OpenAPI Annotation Extraction

The system must extract route-level OpenAPI annotations from Express route files and produce an OpenAPI 3.0-compatible JSON fragment.

**Acceptance Criteria:**
- AC-003-1: `@openapi` JSDoc blocks in route files are parsed into valid OpenAPI 3.0 path objects.
- AC-003-2: Missing `@openapi` annotations on exported route handlers are flagged in the sync report.
- AC-003-3: The generated OpenAPI fragment is validated against the OpenAPI 3.0 schema before being written.

---

### FR-004 — Markdown Generation

The system must convert extracted documentation data into Markdown files under `docs/api/`.

**Acceptance Criteria:**
- AC-004-1: Each source module produces one Markdown file at `docs/api/<module-name>.md`.
- AC-004-2: Generated files include: module name, description, exported functions with signatures, parameters, return types, and examples.
- AC-004-3: Generated files include a `<!-- generated: <ISO timestamp> -->` comment at the top.
- AC-004-4: If a source file produces no extractable documentation, no output file is generated (or an existing one is removed).

---

### FR-005 — Documentation Sync to `docs/` Directory

The system must write generated Markdown files to the configured output directory and keep that directory consistent with the source code.

**Acceptance Criteria:**
- AC-005-1: Docs generated from deleted source files are removed from `docs/api/`.
- AC-005-2: Docs generated from renamed source files are renamed in `docs/api/` accordingly.
- AC-005-3: No manual edits to generated files are overwritten without a warning in the sync report.

---

### FR-006 — Drift Detection

The system must detect when documentation in `docs/api/` no longer matches the current source code.

**Acceptance Criteria:**
- AC-006-1: Running `npm run docs:check` exits with code 1 if any generated doc is out of date.
- AC-006-2: The drift report identifies each out-of-date file with the timestamp of the source change and the timestamp of the doc file.
- AC-006-3: Running `npm run docs:sync` resolves all detected drift.

---

### FR-007 — Sync Report Generation

The system must produce a human-readable sync report after each sync run.

**Acceptance Criteria:**
- AC-007-1: The report lists: files synced, files removed, files with no documentation, drift detected, and errors encountered.
- AC-007-2: The report is written to `docs/sync-report.md` after every run.
- AC-007-3: The report includes the total count of documented and undocumented exported functions.

---

### FR-008 — CLI and npm Script Integration

The system must be runnable as npm scripts without requiring global tool installation.

**Acceptance Criteria:**
- AC-008-1: `npm run docs:sync` triggers a one-shot sync of all source files.
- AC-008-2: `npm run docs:watch` starts file watching mode.
- AC-008-3: `npm run docs:check` runs drift detection and exits non-zero on drift.
- AC-008-4: All scripts work on macOS, Linux, and Windows (via cross-platform Node.js execution, not shell scripts).

---

## 2. Non-Functional Requirements

### NFR-001 — Performance

The extraction and markdown generation pipeline must complete a full sync of the current `backend/src/` within 10 seconds on developer hardware.

**Acceptance Criteria:**
- AC-NFR-001-1: `npm run docs:sync` completes in under 10 seconds on the reference machine.

---

### NFR-002 — Security

The system must not expose secrets or environment-variable values in generated documentation.

**Acceptance Criteria:**
- AC-NFR-002-1: No `.env` values, API keys, database URLs, or tokens appear in any generated Markdown file.
- AC-NFR-002-2: `scripts/scan-secrets.sh` passes on all generated output files.

---

### NFR-003 — Maintainability

The doc-sync implementation must follow the project's TypeScript coding conventions and be covered by unit tests at ≥ 80 % line coverage.

**Acceptance Criteria:**
- AC-NFR-003-1: Jest coverage report shows ≥ 80 % line coverage for all `src/docs-sync/` modules.
- AC-NFR-003-2: ESLint reports zero errors on all `src/docs-sync/` files.

---

### NFR-004 — Reliability

The watcher process must recover from transient file-system errors without crashing.

**Acceptance Criteria:**
- AC-NFR-004-1: A file-system error during extraction logs the error and continues watching; it does not exit.
- AC-NFR-004-2: A malformed TypeScript file (syntax error) does not crash the watcher; extraction is skipped for that file and reported.

---

### NFR-005 — Observability

All sync operations must be logged with structured output including timestamps, source file, and outcome.

**Acceptance Criteria:**
- AC-NFR-005-1: Every sync event is logged as JSON with fields: `timestamp`, `event`, `sourceFile`, `outputFile`, `status`, `durationMs`.
- AC-NFR-005-2: Errors include an `error` field with the message (not a stack trace in production mode).

---

## 3. Assumptions

| ID | Assumption |
|----|-----------|
| ASM-001 | The TypeScript compiler (tsc) is available in the project's `node_modules/.bin/` |
| ASM-002 | Source files use JSDoc syntax for documentation comments, not TSDoc |
| ASM-003 | The `docs/api/` directory is not manually edited — it is treated as generated output |
| ASM-004 | PostgreSQL is running locally; the doc-sync feature is backend-only |
| ASM-005 | The project uses Node.js 20 LTS |

---

## 4. Not Identified

| ID | Item | Reason |
|----|------|--------|
| NI-001 | Confluence integration target URL | No Confluence instance configured; integration deferred |
| NI-002 | GitHub Wiki sync credentials | Not in scope for this iteration |
| NI-003 | Maximum repository size for performance guarantee | Not specified in user story |
| NI-004 | Retention policy for old doc files | Not specified; current behaviour is immediate deletion |
| NI-005 | Authentication for any external doc target | No external targets in scope |

---

## 5. Dependencies

| ID | Dependency | Type | Status |
|----|-----------|------|--------|
| DEP-001 | `ts-morph` npm package | Runtime | Required |
| DEP-002 | `chokidar` npm package | Runtime | Required |
| DEP-003 | PostgreSQL 15+ | Infrastructure | Existing |
| DEP-004 | Node.js 20 LTS | Runtime | Existing |

---

## 6. Potential Risks

| ID | Risk | Likelihood | Impact | Mitigation |
|----|------|-----------|--------|-----------|
| RISK-001 | ts-morph API changes breaking extraction in future TS versions | Medium | High | Pin TypeScript version; test on upgrade |
| RISK-002 | Large monorepos causing slow full-sync runs | Low | Medium | Incremental sync using file-change events only |
| RISK-003 | Generated docs overwriting hand-written docs | Medium | High | Separate `docs/api/` (generated) from `docs/` (hand-written); warn on overlap |
| RISK-004 | Watcher process leaking file handles on Windows | Low | Medium | Use chokidar's `usePolling` option on Windows if handles leak |

---

---

# Requirements — Edit Task Title (Inline)

**Project:** TaskLite
**Feature:** Edit Task Title (Inline)
**Story Type:** UI
**Status:** In Progress
**Last Updated:** 2026-10-01
**Source:** `docs/stories/TASKLITE-edit-task-title.md`

---

## FR-009 — Edit Mode Entry

Each task item must display an Edit control. Activating it switches that task into edit mode, replacing the title display with a text input prefilled with the current title.

**Acceptance Criteria:**
- AC-009-1: An Edit button is visible on every task item in view mode.
- AC-009-2: Activating the Edit control switches the task to edit mode, showing a `<input type="text">` prefilled with the task's current title.
- AC-009-3: When the input is shown, focus is placed on it automatically and the cursor is positioned within the existing title text.
- AC-009-4: No API call is made when entering edit mode.

---

## FR-010 — Single Edit Mode (Mutual Exclusion)

At most one task may be in edit mode at any time.

**Acceptance Criteria:**
- AC-010-1: When a user activates the Edit control on task B while task A is in edit mode, task A returns to view mode and task B enters edit mode.
- AC-010-2: Tasks not in edit mode remain fully visible and operable while another task is being edited.

---

## FR-011 — Keyboard Accessibility for Edit Entry

The Edit control must be fully keyboard-operable without requiring a mouse.

**Acceptance Criteria:**
- AC-011-1: The Edit button is reachable via the Tab key.
- AC-011-2: Pressing Enter or Space on the focused Edit button activates edit mode.
- AC-011-3: The Edit button has an accessible name that identifies the specific task (e.g. `aria-label="Edit Buy milk"`).

---

## NFR-006 — Accessibility (UI)

The edit control and inline input must meet WCAG 2.1 AA.

**Acceptance Criteria:**
- AC-NFR-006-1: The Edit button and text input pass automated axe-core scan with zero violations.
- AC-NFR-006-2: Focus is visible on the Edit button and on the edit input (no `outline: none` without a replacement ring).
- AC-NFR-006-3: Colour contrast for the Edit button label meets 4.5:1 ratio against its background.

---

## NFR-007 — Responsive Layout (UI)

The task item with its Edit button and inline input must render correctly at 375 px viewport width.

**Acceptance Criteria:**
- AC-NFR-007-1: No horizontal overflow on a 375 px viewport when a task is in edit mode.
- AC-NFR-007-2: The inline input width does not exceed the task item container width.
