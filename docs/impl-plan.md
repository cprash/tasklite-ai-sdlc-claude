# Implementation Plan — Automated Documentation Sync

**Project:** TaskLite  
**Feature:** Automated Documentation Sync  
**Status:** Not Started  
**Last Updated:** 2026-09-30  
**Inputs:** `requirements.md`, `architecture.md`, `design-review.md`

> **Blocked:** TASK-005 and TASK-010 are blocked pending human decisions HR-001 and HR-002 from `design-review.md`.

---

## Task Summary

| Task ID | Description | Status | Depends On |
|---------|-------------|--------|-----------|
| TASK-001 | Project setup and dependencies | Not Started | — |
| TASK-002 | Logger module | Not Started | TASK-001 |
| TASK-003 | FileWatcher module | Not Started | TASK-001 |
| TASK-004 | DocExtractor module | Not Started | TASK-001 |
| TASK-005 | SyncWriter module | Blocked | TASK-001, HR-001 |
| TASK-006 | MarkdownGenerator module | Not Started | TASK-004 |
| TASK-007 | DriftDetector module | Not Started | TASK-001 |
| TASK-008 | ReportGenerator module | Not Started | TASK-006, TASK-007 |
| TASK-009 | SyncEngine module | Not Started | TASK-003, TASK-004, TASK-005, TASK-006, TASK-007, TASK-008 |
| TASK-010 | CLI entry point | Blocked | TASK-009, HR-002 |
| TASK-011 | Unit tests — DocExtractor | Not Started | TASK-004 |
| TASK-012 | Unit tests — MarkdownGenerator | Not Started | TASK-006 |
| TASK-013 | Unit tests — DriftDetector | Not Started | TASK-007 |
| TASK-014 | Unit tests — SyncEngine | Not Started | TASK-009 |
| TASK-015 | Integration tests | Not Started | TASK-009, TASK-011, TASK-012, TASK-013 |
| TASK-016 | npm script wiring | Not Started | TASK-010 |
| TASK-017 | Documentation update | Not Started | TASK-016 |

---

## Parallel Execution Groups

After TASK-001 completes, the following tasks can run in parallel:
- **Group A:** TASK-002, TASK-003, TASK-004, TASK-007
- **Group B (after Group A):** TASK-005 (if unblocked), TASK-006, TASK-008
- **Group C (after Group B):** TASK-009
- **Group D (after Group A/B independently):** TASK-011, TASK-012, TASK-013

---

## Task Details

---

### TASK-001 — Project Setup and Dependencies

**Description:** Add `ts-morph` and `chokidar` as dev dependencies. Create `src/docs-sync/` directory with index barrel file. Update `tsconfig.json` if needed for the new module.

**Related Requirement:** DEP-001, DEP-002

**Dependencies:** None

**Files / Components Affected:**
- `backend/package.json`
- `backend/tsconfig.json`
- `backend/src/docs-sync/index.ts` (create)

**Acceptance Criteria:**
- `npm install` completes without error
- `ts-morph` and `chokidar` appear in `package.json` devDependencies
- TypeScript compiles without error after adding the directory

**Testing Requirements:** None (setup task)

**Status:** Not Started

---

### TASK-002 — Logger Module

**Description:** Implement `src/docs-sync/logger.ts`. Structured JSON output with fields: `timestamp`, `level`, `event`, `sourceFile`, `outputFile`, `status`, `durationMs`, `error?`. Pretty-print in development mode.

**Related Requirement:** NFR-005

**Dependencies:** TASK-001

**Files / Components Affected:**
- `backend/src/docs-sync/logger.ts` (create)

**Acceptance Criteria:**
- AC-NFR-005-1: Logs are valid JSON in production mode
- AC-NFR-005-2: Error field contains message only, not stack trace

**Testing Requirements:** Unit test: verify JSON output shape, verify no stack trace in error field

**Status:** Not Started

---

### TASK-003 — FileWatcher Module

**Description:** Implement `src/docs-sync/file-watcher.ts` using `chokidar`. Emits `ChangeEvent` objects. Ignores `node_modules/`, `dist/`, `coverage/`. Exposes `close()` for graceful shutdown.

**Related Requirement:** FR-001

**Dependencies:** TASK-001

**Files / Components Affected:**
- `backend/src/docs-sync/file-watcher.ts` (create)
- `backend/src/docs-sync/types.ts` (create — shared types)

**Acceptance Criteria:**
- AC-001-1 through AC-001-4 from `requirements.md`

**Testing Requirements:** Unit test with a mock chokidar; integration test verifying events on a temp directory

**Status:** Not Started

---

### TASK-004 — DocExtractor Module

**Description:** Implement `src/docs-sync/doc-extractor.ts` using `ts-morph`. Extract exported functions/classes/interfaces with JSDoc. Extract `@openapi` blocks from route files. Return `DocData[]`. Pure function — no I/O.

**Related Requirement:** FR-002, FR-003

**Dependencies:** TASK-001

**Files / Components Affected:**
- `backend/src/docs-sync/doc-extractor.ts` (create)
- `backend/src/docs-sync/types.ts` (update)

**Acceptance Criteria:**
- AC-002-1 through AC-002-4
- AC-003-1 through AC-003-3

**Testing Requirements:** Unit tests against `tests/fixtures/` TypeScript files covering: with JSDoc, without JSDoc, private functions, generics, @openapi blocks

**Status:** Not Started

---

### TASK-005 — SyncWriter Module

**Description:** Implement `src/docs-sync/sync-writer.ts`. Writes Markdown files to `docs/api/`. Removes orphaned docs. Checks for `<!-- generated:` header before overwriting to protect hand-edited files. Implements secret-detection check per HR-001 decision.

**Related Requirement:** FR-005, NFR-002

**Dependencies:** TASK-001, **HR-001 (human decision required)**

**Files / Components Affected:**
- `backend/src/docs-sync/sync-writer.ts` (create)

**Acceptance Criteria:**
- AC-005-1 through AC-005-3
- AC-NFR-002-1 and AC-NFR-002-2

**Testing Requirements:** Unit tests for: write new file, overwrite generated file, skip hand-edited file, remove orphan, abort on detected secret

**Status:** Blocked — awaiting HR-001

---

### TASK-006 — MarkdownGenerator Module

**Description:** Implement `src/docs-sync/markdown-generator.ts`. Converts `DocData[]` to Markdown string. Includes `<!-- generated: <ISO timestamp> -->` header. Pure function.

**Related Requirement:** FR-004

**Dependencies:** TASK-004

**Files / Components Affected:**
- `backend/src/docs-sync/markdown-generator.ts` (create)

**Acceptance Criteria:**
- AC-004-1 through AC-004-4

**Testing Requirements:** Unit tests: snapshot tests for known DocData inputs

**Status:** Not Started

---

### TASK-007 — DriftDetector Module

**Description:** Implement `src/docs-sync/drift-detector.ts`. Reads `<!-- generated: <timestamp> -->` from each doc file and compares to source file `mtime`. Returns `DriftResult[]`.

**Related Requirement:** FR-006

**Dependencies:** TASK-001

**Files / Components Affected:**
- `backend/src/docs-sync/drift-detector.ts` (create)

**Acceptance Criteria:**
- AC-006-1 through AC-006-3

**Testing Requirements:** Unit tests using temp files with controlled timestamps

**Status:** Not Started

---

### TASK-008 — ReportGenerator Module

**Description:** Implement `src/docs-sync/report-generator.ts`. Formats `SyncResult` into Markdown report. Writes to `docs/sync-report.md`.

**Related Requirement:** FR-007

**Dependencies:** TASK-006, TASK-007

**Files / Components Affected:**
- `backend/src/docs-sync/report-generator.ts` (create)

**Acceptance Criteria:**
- AC-007-1 through AC-007-3

**Testing Requirements:** Unit test: verify output Markdown contains required sections

**Status:** Not Started

---

### TASK-009 — SyncEngine Module

**Description:** Implement `src/docs-sync/sync-engine.ts`. Orchestrates the full pipeline for `syncAll()`, `handleChange()`, and `check()` methods.

**Related Requirement:** FR-001 through FR-008

**Dependencies:** TASK-003, TASK-004, TASK-005, TASK-006, TASK-007, TASK-008

**Files / Components Affected:**
- `backend/src/docs-sync/sync-engine.ts` (create)

**Acceptance Criteria:**
- All pipeline modes work end-to-end
- Errors in one file do not abort the full pipeline

**Testing Requirements:** Unit tests with mocked dependencies for each mode

**Status:** Not Started

---

### TASK-010 — CLI Entry Point

**Description:** Implement `src/docs-sync/cli.ts`. Parses `process.argv` for `sync | watch | check`. Reads env vars. Invokes SyncEngine. Exits correctly. Depends on HR-002 to determine `docs:check` behaviour.

**Related Requirement:** FR-008

**Dependencies:** TASK-009, **HR-002 (human decision required)**

**Files / Components Affected:**
- `backend/src/docs-sync/cli.ts` (create)

**Acceptance Criteria:**
- AC-008-1 through AC-008-4

**Testing Requirements:** End-to-end test in CI against a fixture directory

**Status:** Blocked — awaiting HR-002

---

### TASK-011 — Unit Tests: DocExtractor

**Description:** Write comprehensive unit tests for `doc-extractor.ts` using fixture TypeScript files in `tests/fixtures/`.

**Related Requirement:** NFR-003

**Dependencies:** TASK-004

**Files / Components Affected:**
- `backend/tests/unit/doc-extractor.test.ts` (create)
- `backend/tests/fixtures/` (create fixture files)

**Acceptance Criteria:** ≥ 80 % line coverage on `doc-extractor.ts`

**Testing Requirements:** Happy path + 6 edge cases (no JSDoc, private only, empty file, @openapi block, generic types, syntax error)

**Status:** Not Started

---

### TASK-012 — Unit Tests: MarkdownGenerator

**Description:** Write snapshot-based unit tests for `markdown-generator.ts`.

**Related Requirement:** NFR-003

**Dependencies:** TASK-006

**Files / Components Affected:**
- `backend/tests/unit/markdown-generator.test.ts` (create)

**Acceptance Criteria:** ≥ 80 % line coverage on `markdown-generator.ts`

**Testing Requirements:** Snapshot tests for known inputs; test generated-timestamp comment present

**Status:** Not Started

---

### TASK-013 — Unit Tests: DriftDetector

**Description:** Write unit tests for `drift-detector.ts` using controlled temp-file timestamps.

**Related Requirement:** NFR-003

**Dependencies:** TASK-007

**Files / Components Affected:**
- `backend/tests/unit/drift-detector.test.ts` (create)

**Acceptance Criteria:** ≥ 80 % line coverage on `drift-detector.ts`

**Testing Requirements:** Test: in-sync, drifted, missing doc file, missing source file

**Status:** Not Started

---

### TASK-014 — Unit Tests: SyncEngine

**Description:** Write unit tests for `sync-engine.ts` with all dependencies mocked.

**Related Requirement:** NFR-003

**Dependencies:** TASK-009

**Files / Components Affected:**
- `backend/tests/unit/sync-engine.test.ts` (create)

**Acceptance Criteria:** ≥ 80 % line coverage on `sync-engine.ts`

**Status:** Not Started

---

### TASK-015 — Integration Tests

**Description:** Write integration tests that run the full pipeline against `tests/fixtures/` directory. Verify Markdown output, sync-report.md, and drift detection.

**Related Requirement:** NFR-003, FR-001 through FR-007

**Dependencies:** TASK-009, TASK-011, TASK-012, TASK-013

**Files / Components Affected:**
- `backend/tests/integration/docs-sync.test.ts` (create)

**Acceptance Criteria:** Full pipeline produces correct output for fixture inputs; no secrets in output

**Status:** Not Started

---

### TASK-016 — npm Script Wiring

**Description:** Add `docs:sync`, `docs:watch`, and `docs:check` scripts to `backend/package.json`.

**Related Requirement:** FR-008

**Dependencies:** TASK-010

**Files / Components Affected:**
- `backend/package.json`

**Acceptance Criteria:**
- AC-008-1 through AC-008-4

**Status:** Not Started

---

### TASK-017 — Documentation Update

**Description:** Update `docs/technical-profile.md` with `DOCS_SYNC_*` environment variable names. Update `CHANGELOG.md`. Add `docs/api/README.md` per REC-001.

**Related Requirement:** REC-001, REC-002 from `design-review.md`

**Dependencies:** TASK-016

**Files / Components Affected:**
- `docs/technical-profile.md`
- `CHANGELOG.md`
- `docs/api/README.md` (create)

**Status:** Not Started

---

---

# Implementation Plan — Edit Task Title (Inline)

**Project:** TaskLite
**Feature:** Edit Task Title (Inline)
**Story Type:** UI
**Status:** In Progress
**Last Updated:** 2026-10-01
**Inputs:** `requirements.md` FR-009–FR-011, NFR-006–007; `architecture.md` Edit Task Title section; `design-review.md` CI-004, HR-003

> **Note:** TASK-021 (Escape key handler) is conditional on HR-003 resolution. Recommended to implement (Option A).

---

## Task Summary

| Task ID | Description | Status | Depends On |
|---------|-------------|--------|-----------|
| TASK-018 | Lift `editingTaskId` state to `App` | Done | — |
| TASK-019 | Update `TaskList` props | Done | TASK-018 |
| TASK-020 | Update `TaskItem` — edit button + input | Done | TASK-019 |
| TASK-021 | Escape key handler to exit edit mode | Done | TASK-020, HR-003 |
| TASK-022 | Component tests — `TaskItem` edit mode | Done | TASK-020 |

---

### TASK-018 — Lift `editingTaskId` State to `App`

**Description:** Add `editingTaskId: number | null` state and `handleStartEdit(task: Task)` handler to `App.tsx`. Pass both as props to `TaskList`.

**Related Requirement:** FR-010

**Files Affected:**
- `frontend/src/App.tsx`

**Acceptance Criteria:**
- `editingTaskId` initialises to `null`
- Calling `handleStartEdit(task)` sets `editingTaskId` to `task.id`
- Activating edit on task B while task A is editing sets `editingTaskId` to B's id (AC-010-1)

**Status:** Done

---

### TASK-019 — Update `TaskList` Props

**Description:** Add `editingTaskId: number | null` and `onStartEdit: (task: Task) => void` props to `TaskList`. Thread them through to each `TaskItem`.

**Related Requirement:** FR-010

**Files Affected:**
- `frontend/src/components/TaskList.tsx`

**Acceptance Criteria:**
- `isEditing={editingTaskId === task.id}` passed to each `TaskItem`
- `onStartEdit` passed to each `TaskItem`

**Status:** Done

---

### TASK-020 — Update `TaskItem` — Edit Button and Inline Input

**Description:** Add `isEditing: boolean` and `onStartEdit: (task: Task) => void` props. In view mode: render Edit button with `aria-label`. In edit mode: render `<input>` prefilled with `task.title`, auto-focused via `useRef` + `useEffect`. Disable Toggle/Delete buttons while editing.

**Related Requirement:** FR-009, FR-011, NFR-006

**Files Affected:**
- `frontend/src/components/TaskItem.tsx`

**Acceptance Criteria:**
- AC-009-1: Edit button visible in view mode
- AC-009-2: Input shown prefilled with title in edit mode
- AC-009-3: Input is focused on edit mode entry
- AC-009-4: No API call on edit entry
- AC-011-3: `aria-label="Edit <task.title>"` on the Edit button

**Status:** Done

---

### TASK-021 — Escape Key Handler

**Description:** In edit mode, pressing Escape calls `onCancelEdit()` which sets `editingTaskId` back to `null` in `App`. Requires HR-003 Option A decision.

**Related Requirement:** CI-004 (design-review)

**Files Affected:**
- `frontend/src/components/TaskItem.tsx`
- `frontend/src/App.tsx`

**Status:** Done (HR-003 resolved as Option A)

---

### TASK-022 — Component Tests: `TaskItem` Edit Mode

**Description:** Write Vitest + React Testing Library tests for `TaskItem` covering edit mode entry, mutual exclusion, auto-focus, and accessibility.

**Related Requirement:** NFR-006

**Files Affected:**
- `frontend/src/components/TaskItem.test.tsx` (create)

**Acceptance Criteria:**
- Edit button renders and is clickable
- Input renders prefilled with title when `isEditing` is true
- axe scan passes with zero violations in both view and edit mode
- Only one task in edit mode at a time (tested via `TaskList` wrapper)

**Status:** Done
