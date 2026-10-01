# Code Review — EPMCDMETST-66640

**Story:** Persist edited task title
**Branch:** `feature/EPMCDMETST-66640-edit-task-title`
**Reviewed commit:** `b7d6e55` — "EPMCDMETST-66640: add PATCH endpoint to edit task title"
**Reviewer:** review-agent (Capstone Step 6)
**Date:** 2026-10-01

Scope of this review is the diff on the feature branch against `main`:
`updateTaskTitle` controller, the `updateTaskTitleSchema` validator, the
`PATCH /tasks/:id` route, the Vitest suite, and the build/test config
changes. The review follows the capstone's seven-area checklist. Each
finding is tagged **Issue** (should fix) or **Suggestion** (optional),
with a severity.

## 1. Correctness
The handler meets all three acceptance criteria and the architecture
contract: `PATCH /api/tasks/:id` parses the id, validates the body with
Zod, persists the trimmed title via `prisma.task.update`, and returns the
updated row as JSON (200). The route is registered **after**
`/tasks/:id/status` so the more specific path still matches first, and
before `delete` — no shadowing. `updatedAt` is maintained automatically by
Prisma's `@updatedAt`.

- **No issue.** Behaviour matches `requirements.md` and `architecture.md`.

## 2. Security
- Input is validated and length-bounded (`.max(255)`) before it reaches
  the database; Prisma parameterises the query, so there is no injection
  surface. No secrets appear in code or docs.
- **Suggestion (LOW):** The endpoint has no authentication/authorisation —
  any caller can rename any task. This is explicitly **out of scope** per
  `requirements.md` (no auth in this story) and matches the existing
  endpoints, so it is recorded as a known limitation, not a regression.

## 3. Error Handling
- Non-integer id → 404 before any DB call; unknown id → Prisma `P2025`
  caught and remapped to 404 `{error:"Task not found"}`; invalid body →
  400 with the specific failing rule; anything unexpected falls through to
  the shared error middleware (generic 500). This mirrors the established
  `updateTaskStatus` / `deleteTask` pattern exactly.
- **No issue.**

## 4. Test Coverage
Six Vitest + Supertest cases cover AC1 (trimmed save → 200, asserts
`update` called with the trimmed value), AC2 (P2025 → 404), AC3 (empty and
whitespace-only → 400, no write), plus two edges (non-integer id → 404,
>255 chars → 400). All assert that no write happens on the rejection
paths.

- **Suggestion (MED):** The suite mocks `../src/lib/prisma.js`, so it
  proves the HTTP / validation / error-mapping layers but **not** real
  persistence against SQLite. The test file header and `architecture.md`
  both acknowledge this and defer the real-DB persistence check to the
  Verify stage (Step 7). Confirm Verify exercises an actual round-trip so
  AC1's "changes persist" is covered end to end.

## 5. Code Clarity
- Names are descriptive (`updateTaskTitle`, `updateTaskTitleSchema`),
  comments explain the *why* (non-integer id treated as not-found; title
  already trimmed by the schema), and the structure is identical to the
  neighbouring handlers, so a reader familiar with the file needs no ramp-up.
- **No issue.**

## 6. DRY
- **Suggestion (LOW):** `updateTaskTitle`, `updateTaskStatus`, and
  `deleteTask` repeat the same id-parse-and-404 guard and the same
  `P2025 → 404` catch block. Extracting a small `parseTaskId` helper and a
  shared not-found mapper would remove the triplication. It is deliberately
  **not** done in this story: G7 keeps the Build stage inside the approved
  plan's scope (no opportunistic refactors), and the duplication is
  consistent with the existing code. Recommend a follow-up tidy-up ticket.

## 7. Dependency Safety
- No new runtime dependency was added — `zod` was already present
  (confirmed in `package.json`), as the architecture noted.
- **Issue (MED):** `npm audit` reports **3 high-severity** advisories, all
  from one transitive chain under the dev dependency `prisma`:
  `prisma → @prisma/config → deepmerge-ts <8.0.0`
  (GHSA-ggr8-5vv4-36mx, stack exhaustion on recursive object graphs). These
  are **pre-existing** on `main`, not introduced by this change, and the
  package is a build-time dev dependency (not shipped at runtime). The only
  fix npm offers is `npm audit fix --force`, which pulls a **breaking**
  `prisma@6.12.0` downgrade — out of scope here and risky to apply blind.
  Recommend a separate dependency-maintenance ticket to upgrade the Prisma
  toolchain to a patched line rather than forcing it in this PR.

## Verdict
**APPROVED — no blocking issues.** The implementation is correct, well
tested at the HTTP/validation layer, and consistent with the codebase.
Four non-blocking findings carry forward:

| # | Area | Type | Severity | Carry-forward |
| - | --- | --- | --- | --- |
| 1 | Security | Suggestion | LOW | No auth — known limitation (out of scope) |
| 2 | Test Coverage | Suggestion | MED | Verify stage must prove real-DB persistence |
| 3 | DRY | Suggestion | LOW | Follow-up ticket: extract shared id-guard / P2025 helper |
| 4 | Dependency Safety | Issue | MED | Pre-existing Prisma→deepmerge-ts advisories; dependency ticket |

These findings are posted onto the PR by the Release agent (Step 8).
