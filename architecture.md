# Architecture — Automated Documentation Sync

**Project:** TaskLite  
**Feature:** Automated Documentation Sync  
**Status:** Approved  
**Last Updated:** 2026-09-30  
**Based on:** `requirements.md` v1.0

---

## 1. System Overview

The Automated Documentation Sync (ADS) feature is a developer-tooling layer that lives inside the existing TaskLite backend project. It introduces a `src/docs-sync/` module that provides three operational modes:

- **Watch mode** (`docs:watch`) — monitors file-system events and re-syncs incrementally
- **One-shot sync** (`docs:sync`) — full sync of all source files; used in CI
- **Drift check** (`docs:check`) — validates that docs are current; exits non-zero on drift

The feature does not modify the Express API, the Prisma schema, or any frontend code. It is a pure developer-side utility.

---

## 2. Architecture Diagram

```
┌──────────────────────────────────────────────────────────────┐
│                        CLI Entry Point                       │
│                   src/docs-sync/cli.ts                       │
│              (watch | sync | check sub-commands)             │
└────────────────────────────┬─────────────────────────────────┘
                             │
              ┌──────────────▼──────────────┐
              │         SyncEngine          │
              │   src/docs-sync/sync-engine │
              │  Orchestrates the pipeline  │
              └──────┬──────────────┬───────┘
                     │              │
        ┌────────────▼──┐    ┌──────▼──────────────┐
        │  FileWatcher  │    │    DocExtractor      │
        │  (chokidar)   │    │  (ts-morph AST)      │
        │  Emits change │    │  JSDoc + OpenAPI     │
        │  events       │    │  → DocData[]         │
        └───────────────┘    └──────┬───────────────┘
                                    │
                      ┌─────────────▼──────────────┐
                      │     MarkdownGenerator       │
                      │  DocData[] → .md strings    │
                      └─────────────┬──────────────┘
                                    │
                      ┌─────────────▼──────────────┐
                      │        SyncWriter           │
                      │  Writes / removes files in  │
                      │  docs/api/                  │
                      └─────────────┬──────────────┘
                                    │
               ┌────────────────────┼──────────────────────┐
               │                    │                      │
  ┌────────────▼──┐    ┌────────────▼──┐    ┌─────────────▼──┐
  │ DriftDetector │    │ ReportGenerator│    │    Logger      │
  │ Compares file │    │ Writes         │    │ Structured     │
  │ timestamps    │    │ sync-report.md │    │ JSON to stdout │
  └───────────────┘    └───────────────┘    └────────────────┘
```

---

## 3. Component Responsibilities

### 3.1 CLI Entry Point (`src/docs-sync/cli.ts`)

- Parses `process.argv` for sub-commands: `sync`, `watch`, `check`
- Reads configuration from environment variables (paths, exclusions)
- Instantiates `SyncEngine` and invokes the appropriate method
- Exits with code 0 on success, 1 on failure or detected drift

### 3.2 SyncEngine (`src/docs-sync/sync-engine.ts`)

- Orchestrates the full pipeline: watch → extract → generate → write → report
- In watch mode: subscribes to `FileWatcher` events and triggers incremental extraction
- In sync mode: enumerates all `.ts`/`.tsx` files and runs full pipeline
- In check mode: runs `DriftDetector` only and returns exit code

### 3.3 FileWatcher (`src/docs-sync/file-watcher.ts`)

- Wraps `chokidar` to watch `backend/src/` and `frontend/src/`
- Emits typed events: `{ event: 'add' | 'change' | 'unlink', path: string }`
- Supports graceful shutdown (`close()` method)
- Ignores `node_modules/`, `dist/`, `coverage/`, `.prisma/`

### 3.4 DocExtractor (`src/docs-sync/doc-extractor.ts`)

- Uses `ts-morph` to parse TypeScript source files into an AST
- Extracts exported functions, classes, and interfaces with their JSDoc
- Extracts `@openapi` JSDoc blocks from Express route files
- Returns a typed `DocData` array — no I/O, pure function

### 3.5 MarkdownGenerator (`src/docs-sync/markdown-generator.ts`)

- Converts `DocData[]` to a Markdown string
- Includes generated-timestamp comment at the top
- No I/O — pure function taking `DocData[]` returning `string`

### 3.6 SyncWriter (`src/docs-sync/sync-writer.ts`)

- Writes Markdown files to `docs/api/<module-name>.md`
- Removes orphaned doc files when source files are deleted
- Warns (does not overwrite silently) when an existing file was not previously generated

### 3.7 DriftDetector (`src/docs-sync/drift-detector.ts`)

- Compares the `<!-- generated: <timestamp> -->` header in each doc file against the `mtime` of the corresponding source file
- Returns a list of `DriftResult` objects: `{ sourceFile, docFile, sourceMtime, docTimestamp, isDrifted }`

### 3.8 ReportGenerator (`src/docs-sync/report-generator.ts`)

- Formats a `SyncResult` object into a human-readable Markdown report
- Writes the report to `docs/sync-report.md`

### 3.9 Logger (`src/docs-sync/logger.ts`)

- Emits structured JSON log lines to `stdout`
- Fields: `timestamp`, `level`, `event`, `sourceFile`, `outputFile`, `status`, `durationMs`, `error?`
- In development mode (`NODE_ENV=development`), pretty-prints with colours

---

## 4. Data Flow

### 4.1 Watch Mode

```
File saved by developer
    → chokidar emits 'change' event
    → FileWatcher emits typed ChangeEvent
    → SyncEngine.handleChange(path)
    → DocExtractor.extract(path) → DocData[]
    → MarkdownGenerator.generate(DocData[]) → string
    → SyncWriter.write(outputPath, markdown)
    → ReportGenerator.appendEntry(result)
    → Logger.log(entry)
```

### 4.2 One-Shot Sync Mode

```
npm run docs:sync
    → CLI invokes SyncEngine.syncAll()
    → Glob all .ts/.tsx files in backend/src/, frontend/src/
    → For each file: extract → generate → write
    → DriftDetector.scan() to verify all docs are current
    → ReportGenerator.writeFullReport()
    → Exit 0
```

### 4.3 Drift Check Mode

```
npm run docs:check (CI)
    → CLI invokes SyncEngine.check()
    → DriftDetector.scan() → DriftResult[]
    → If any isDrifted=true → log drift, exit 1
    → If all current → exit 0
```

---

## 5. Technology Choices

| Technology | Version | Rationale |
|-----------|---------|-----------|
| `ts-morph` | ^23.x | Provides a high-level TypeScript AST API built on the TS compiler; handles generics, unions, and decorators natively. See ADR-001. |
| `chokidar` | ^4.x | Cross-platform file watching; handles Windows, macOS, and Linux reliably; supports debouncing |
| Node.js 20 LTS | 20.x | Existing runtime; native ESM support |
| TypeScript 5 | 5.x | Existing project standard; strict mode |
| Jest 29 | 29.x | Existing test framework |

---

## 6. External Integrations

| Integration | Status | Notes |
|------------|--------|-------|
| Confluence | Not Identified | No instance URL or credentials configured; deferred to future iteration |
| GitHub Wiki | Not in scope | Deferred |
| Slack notifications | Not in scope | Deferred |

---

## 7. Security Considerations

- **No secrets in docs:** `SyncWriter` must check generated content against a regex pattern for common secret patterns before writing. If a match is found, the write is aborted and an error is logged.
- **Environment variables:** Configuration (watched paths, output path, exclusion patterns) is read from environment variables; values never appear in generated docs.
- **Input validation:** Source file paths are resolved with `path.resolve()` and validated to be within the project root before processing.
- **No network calls:** The current scope involves no outbound HTTP; this eliminates a class of SSRF/injection risks.

---

## 8. Deployment Considerations

- The ADS feature is a dev dependency; it does not run in production.
- `npm run docs:check` should be added to the CI pipeline as a required check.
- No additional infrastructure is required for the current scope.

---

## 9. Scalability and Availability Considerations

- **Incremental sync** in watch mode ensures only changed files are re-processed; full-sync time does not grow linearly with repository size under normal development.
- **Debouncing** (500 ms default) prevents duplicate extraction triggers on rapid saves.
- **Not Identified:** Expected repository size at which performance guarantee (NFR-001) degrades.

---

## 10. Risks and Trade-offs

| Risk | Trade-off |
|------|----------|
| ts-morph API instability across major TypeScript versions | High accuracy vs. maintenance cost on TS upgrades |
| Watcher process memory leak on long-running dev sessions | Convenience vs. need for periodic restart |
| Generated `docs/api/` treated as source of truth by mistake | Automation benefit vs. risk of overwriting hand-edited docs |

---

## 11. Open Questions

| ID | Question | Owner | Status |
|----|---------|-------|--------|
| OQ-001 | Should `docs/api/` be committed to Git or gitignored? | Tech lead | Not Identified |
| OQ-002 | Is there a plan to integrate with Confluence in the next sprint? | Product | Not Identified |
| OQ-003 | Should undocumented functions cause CI to fail? | Team | Not Identified |

---

---

# Architecture — Edit Task Title (Inline)

**Project:** TaskLite
**Feature:** Edit Task Title (Inline)
**Story Type:** UI
**Status:** In Progress
**Last Updated:** 2026-10-01
**Based on:** `requirements.md` — FR-009, FR-010, FR-011, NFR-006, NFR-007

---

## 1. Overview

This feature adds inline title editing to the `TaskItem` component. It is pure frontend state — no new API endpoints, no Prisma changes, and no backend modifications. The existing `PATCH /tasks/:id` endpoint (which already accepts a `title` field) will be used in a future story to persist the edit.

---

## 2. Component Changes

### 2.1 State — `editingTaskId` lifted to `App`

Mutual exclusion (only one task in edit mode at a time — FR-010) requires shared state above `TaskItem`. The `editingTaskId: number | null` state lives in `App` and is passed down via props.

```
App
 ├── editingTaskId: number | null         ← NEW state
 ├── handleStartEdit(task: Task): void    ← NEW handler
 └── TaskList
      ├── editingTaskId (prop)            ← passed through
      ├── onStartEdit (prop)              ← passed through
      └── TaskItem (×N)
           ├── isEditing: boolean         ← derived: editingTaskId === task.id
           └── onStartEdit (prop)
```

### 2.2 `TaskItem` — new props and edit mode branch

| Prop | Type | Description |
|------|------|-------------|
| `isEditing` | `boolean` | When true, render input instead of title span |
| `onStartEdit` | `(task: Task) => void` | Called when Edit button is clicked |

**View mode** (isEditing = false): title `<span>` + Edit button + existing action buttons.  
**Edit mode** (isEditing = true): `<input type="text">` prefilled with `task.title`, autofocused via `useRef` + `useEffect`. Edit button hidden; other action buttons disabled.

### 2.3 `TaskList` — two new props threaded through

| Prop | Type |
|------|------|
| `editingTaskId` | `number \| null` |
| `onStartEdit` | `(task: Task) => void` |

---

## 3. Accessibility Design

- Edit button carries `aria-label="Edit <task title>"` to give screen readers task context.
- Input carries `aria-label="Edit title for task: <task title>"`.
- `useRef` + `useEffect` auto-focuses the input when `isEditing` becomes true.
- Toggle Status and Delete buttons are `disabled` while a task is in edit mode to prevent conflicting mutations.

---

## 4. Out of Scope (this story)

| Item | Reason |
|------|--------|
| Saving the edited title (API call) | Separate story — FR-009 AC-009-4 explicitly excludes API call |
| Cancel / Escape key to exit edit mode | Not in acceptance criteria; deferred |
| Optimistic update | Depends on save story |
