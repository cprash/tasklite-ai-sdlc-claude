# Implementation Plan — EPMCDMETST-66640: Persist edited task title

## Phases
1. **Validation** — ensure Zod is available and define the title-update schema (non-empty, trimmed, ≤255).
2. **Data access** — extend the task service to find by integer id and persist the trimmed title via Prisma, mapping the missing-row case to 404.
3. **Route** — wire `PATCH /api/tasks/:id` into the existing tasks router with the full error mapping (404 / 400 / 500 / 200).
4. **Tests** — add Vitest + Supertest coverage for every acceptance criterion plus the design-review edge cases.

## Tasks
| Id | Task | Effort | Waits on |
|---|---|---|---|
| T1 | Confirm Zod is a backend dependency; install it only if missing (per architecture Technology picks — no stack change). | LOW | none |
| T2 | Create the Zod `updateTaskTitle` schema: `title` present, string, non-empty after trim, `.max(255)` (interim cap). | LOW | T1 |
| T3 | Extend the task update service/repository: parse id as integer, load the `tasks` row, persist the **trimmed** `title` via Prisma, and map a missing row / `P2025` to a not-found outcome. | MED | none |
| T4 | Add `PATCH /api/tasks/:id` to the existing tasks router: non-integer id → **404** before any DB call; Zod validation failure → **400**; unknown id → **404**; unexpected DB error → **500** (generic); success → **200** with the updated task. | MED | T2, T3 |
| T5 | Add automated tests (Vitest + Supertest): AC1 valid title → 200 and title persisted; AC2 unknown id → 404; AC3 empty/whitespace title → 400 and no change; plus non-integer id → 404 and >255-char title → 400. | MED | T4 |

## Blocked
None. Zod availability (T1) is confirmed during Build, not a pre-run blocker; everything else is self-contained on the existing stack.

## Effort roll-up
2 LOW, 3 MED. **Overall: MED (lower end)** — a single new endpoint on the
existing `tasks` entity, no schema migration, with the main effort in the
route's error mapping and the test matrix. Consistent with the story's 5 SP.

---
*Trace note:* T1–T2 ← architecture "Technology picks" + requirements validation
rules; T3 ← architecture "How data moves" + error mapping; T4 ← acceptance
criteria + design-review findings #1/#2; T5 ← Definition of Done + all three
acceptance criteria + design-review edge cases. No task introduces scope beyond
the `tasks.title` update (G4/G7).
