# Skill: Documentation Sync

Load this skill when implementing, debugging, or extending the Automated Documentation Sync feature. It describes the domain model, extraction rules, and sync pipeline in detail.

---

## When to Use

- When implementing any module in `src/docs-sync/`
- When debugging unexpected sync output
- When adding support for a new JSDoc tag or annotation type

---

## Domain Model

### DocData

The central data transfer object produced by `DocExtractor` and consumed by `MarkdownGenerator`.

```typescript
interface DocData {
  moduleId: string;          // kebab-case source file name without extension
  modulePath: string;        // relative path from project root
  moduleDescription: string; // from @module JSDoc tag or first class/file comment
  exports: ExportDoc[];
}

interface ExportDoc {
  name: string;              // exported identifier name
  kind: 'function' | 'class' | 'interface' | 'type' | 'const';
  signature: string;         // full TypeScript signature string
  description: string;       // JSDoc description text
  params: ParamDoc[];
  returns: ReturnDoc | null;
  throws: ThrowDoc[];
  examples: string[];
  deprecated: string | null; // deprecation message if @deprecated present
  isUndocumented: boolean;   // true if no JSDoc found
}

interface ParamDoc {
  name: string;
  type: string;
  description: string;
  optional: boolean;
}

interface ReturnDoc {
  type: string;
  description: string;
}

interface ThrowDoc {
  type: string;
  description: string;
}
```

### SyncResult

Produced by `SyncEngine` after a sync run.

```typescript
interface SyncResult {
  timestamp: string;           // ISO 8601
  mode: 'watch' | 'sync' | 'check';
  filesProcessed: string[];
  filesWritten: string[];
  filesRemoved: string[];
  filesSkipped: string[];      // hand-edited files that were not overwritten
  undocumentedExports: UndocumentedExport[];
  errors: SyncError[];
  driftResults: DriftResult[];
}
```

### DriftResult

```typescript
interface DriftResult {
  sourceFile: string;
  docFile: string;
  sourceMtime: Date;
  docTimestamp: Date | null;  // null if generated header missing
  isDrifted: boolean;
}
```

---

## JSDoc Extraction Rules

### Supported Tags

| Tag | Field | Notes |
|-----|-------|-------|
| `@param {type} name - description` | `params` | Type annotation is optional |
| `@returns {type} description` | `returns` | Also `@return` |
| `@throws {ErrorType} description` | `throws` | Multiple allowed |
| `@example` | `examples` | Content until next tag or block end |
| `@deprecated description` | `deprecated` | Description is the migration hint |
| `@module description` | `moduleDescription` | File-level description |

### Private / Internal Exclusions

Do NOT extract the following:

- Functions with names prefixed `_` (convention for internal)
- Class members with `private` or `protected` modifier
- Symbols decorated with `@internal` JSDoc tag
- Non-exported symbols (not in the module's public API surface)

### Undocumented Export Detection

If an exported symbol has no JSDoc comment:
- Set `isUndocumented: true`
- Include it in `undocumentedExports` in `SyncResult`
- List it in `sync-report.md` under "Undocumented Exports"
- Do NOT omit it from the generated Markdown — show it with a `> ⚠️ Undocumented` note

---

## OpenAPI Annotation Extraction Rules

Route files (matched by `*.routes.ts` pattern) may contain `@openapi` JSDoc blocks:

```typescript
/**
 * @openapi
 * /tasks:
 *   get:
 *     summary: List all tasks
 *     responses:
 *       200:
 *         description: Array of tasks
 */
router.get('/', listTasks);
```

Extraction rules:
1. Find all JSDoc blocks containing `@openapi`
2. Extract the YAML content following `@openapi`
3. Parse with a YAML parser — if parse fails, log error with `sourceFile:line` and continue
4. Merge into the module's `exports` as a special `kind: 'route'` entry
5. Validate the parsed fragment against OpenAPI 3.0 path schema — log validation errors

---

## Markdown Generation Rules

### File Header

Every generated Markdown file must start with:
```
<!-- generated: 2026-09-30T12:00:00.000Z -->
<!-- source: backend/src/routes/tasks.routes.ts -->
```

This header is used by `DriftDetector` and `SyncWriter`. Files without this header are treated as hand-edited and are not overwritten.

### File Structure

```markdown
# <moduleId>

> <moduleDescription>

Generated from `<modulePath>`.

---

## <ExportName>

**Kind:** function | class | interface | type | const  
**Signature:** `<signature>`

<description>

### Parameters

| Name | Type | Required | Description |
|------|------|---------|-------------|
| <name> | `<type>` | Yes/No | <description> |

### Returns

`<type>` — <description>

### Throws

- `<ErrorType>`: <description>

### Examples

\```typescript
<example content>
\```
```

---

## Drift Detection Rules

`DriftDetector` reads the `<!-- generated: <ISO timestamp> -->` comment from each file in `docs/api/`.

A document is considered **drifted** if:
- The source file's `mtime` is **newer** than the `generated` timestamp in the doc header
- The doc file exists but the `<!-- generated:` header is missing or unparseable
- The source file no longer exists (orphaned doc)

`docs:check` exits with code **1** if any file is drifted or orphaned.

---

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DOCS_SYNC_SOURCE_DIRS` | `backend/src,frontend/src` | Comma-separated directories to watch |
| `DOCS_SYNC_OUTPUT_DIR` | `docs/api` | Directory for generated Markdown files |
| `DOCS_SYNC_EXCLUDE` | `node_modules,dist,coverage` | Comma-separated exclusion patterns |
| `DOCS_SYNC_DEBOUNCE_MS` | `500` | Debounce delay for file watcher events |
| `DOCS_SYNC_USE_POLLING` | `false` | Enable polling mode (for network drives) |
| `DOCS_SYNC_LOG_LEVEL` | `info` | Log level: debug, info, warn, error |

---

## Secret Detection Patterns

Before `SyncWriter` writes a file, scan content for these patterns. If matched, abort the write.

```
/api[_-]?key\s*[:=]\s*['"][^'"]{8,}/i
/password\s*[:=]\s*['"][^'"]{4,}/i
/secret\s*[:=]\s*['"][^'"]{8,}/i
/token\s*[:=]\s*['"][^'"]{8,}/i
/postgres(ql)?:\/\/[^@]+@/i
/mongodb(\+srv)?:\/\/[^@]+@/i
/AKIA[0-9A-Z]{16}/
```

Log: `secret pattern detected in generated content, write aborted: <file>`  
Never log the matched value.
