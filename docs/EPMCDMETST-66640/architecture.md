# Architecture — EPMCDMETST-66640: Persist edited task title

## Where this fits
TaskLite's backend is an Express + Prisma service over SQLite
(TypeScript), living under `backend/src` per `app-profile.yml`. This
story adds a single write path to the existing `tasks` API: a
`PATCH /api/tasks/:id` route that updates one field, `title`. No new
entity, no schema migration, and no frontend change — the React app is
untouched by this story.

## Picture
```
Client
  │  PATCH /api/tasks/:id   { title }
  ▼
Express router (tasks)
  │
  ├─▶ Zod schema: title is non-empty, trimmed string
  │        └─ invalid ──▶ 400 Bad Request  (no write)
  ▼
Task update service
  │  look up task by id (Prisma)
  │        └─ not found ─▶ 404 Not Found   (no write)
  ▼
Prisma  ──▶  SQLite
  │  UPDATE tasks SET title = …, updatedAt = now() WHERE id = :id
  ▼
200 OK  { updated task }
```

## Components and who does what
| Component | Responsibility | New / Changed |
|---|---|---|
| `PATCH /api/tasks/:id` route handler | Accept the request, run validation, map outcomes to 200/400/404 | New (added to the existing `tasks` router) |
| Zod `updateTaskTitle` schema | Enforce `title` is a non-empty, non-whitespace string | New |
| Task update service/repository fn | Find the `tasks` row by id; if present, persist the new `title` via Prisma | Changed (extends the existing task data access) |
| Error handling | Return 404 when the id is unknown; 400 on validation failure; neither path writes | Changed |

## Technology picks
Stays on the declared stack — Express, Prisma, SQLite, TypeScript —
with no new dependency. Validation uses **Zod**, which the Build stage
confirmed is already a backend dependency (`zod ^4.6.5` in
`backend/package.json`); no install is needed.

## How data moves
1. Request arrives: `PATCH /api/tasks/:id` with body `{ "title": <string> }`.
2. **Parse `:id` to an integer first** (the `tasks` PK is `id: Int`, per
   `data_model.notes`). If it is not a valid integer, return **404**
   (unknown id) **before any database call** — the non-integer id never
   reaches Prisma.
3. Zod validates `title`: present, a string, non-empty after trimming,
   and at most **255** characters (interim cap — see Risks). Failure →
   **400**, no write.
4. The service loads the `tasks` row by id. Missing → **404**, no write.
5. On success, Prisma updates `title` on that `tasks` row with the
   **trimmed** value (the stored title is the trimmed input, not the raw
   string); `updatedAt` advances automatically (it already exists on the
   entity).
6. Response **200** returns the updated `tasks` record.

**Error mapping (failure paths):**
- Non-integer / unknown `:id` → **404** with a generic not-found message.
- Row removed between find and update (Prisma `P2025`) → **404** (treated
  as unknown id).
- Validation failure (empty/whitespace/too-long/missing `title`) → **400**.
- Any other/unexpected database error → **500** with a generic message;
  no Prisma or stack internals are leaked to the client.

**Entity schema change:** none. `title` and `updatedAt` already exist on
the `tasks` entity (`data_model.notes`); this story writes to existing
columns only.

## Contracts introduced or touched
```
PATCH /api/tasks/:id
  Path:  id — integer, identifies an existing task
  Body:  { "title": string }        // non-empty, non-whitespace, ≤255 chars; stored trimmed

  200 OK            → the updated task object (title is the trimmed value)
  400 Bad Request   → { error: <validation message> }   // empty/whitespace/missing title
  404 Not Found     → { error: <not-found message> }     // no task with that id
```
No event or UI contract is introduced.

## Risks and assumptions
- **Assumption:** the `tasks` PK is an integer (`id: Int`, from
  `data_model.notes`); `:id` is matched on that basis.
- **Assumption:** the existing `tasks` router and task data-access layer
  follow current project routing conventions, which this route reuses
  (the pipeline does not read source to confirm their exact shape — Build
  aligns to them).
- **Assumption:** Zod is available (story) — see Technology picks.
- **Risk / decision:** no product-confirmed maximum `title` length. An
  **interim cap of 255 characters** is enforced via Zod `.max(255)`,
  marked provisional pending product confirmation (still `[pending]` in
  requirements).
- **Risk:** concurrent edits to the same task are last-write-wins; no
  optimistic locking is introduced (out of scope for this story).
- **Note:** no authentication/authorization — consistent with the
  approved requirements.
