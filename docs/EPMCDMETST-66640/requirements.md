# Requirements — EPMCDMETST-66640: Persist edited task title

## Story at a glance
- **Source:** Jira story EPMCDMETST-66640 (provided at intake); traces to BRD **FR-4, FR-7**; origin page: TaskLite — Release 2 (Confluence space `TaskLite`).
- **Summary:** As a user, I want my edited task title saved so that changes persist. Adds/updates an endpoint that edits a task's `title`, validates the input, returns the updated task, and responds 404 when the id does not exist.
- **Estimate:** 5 SP
- **Priority:** High
- **Owner:** [pending] — not supplied in the story
- **Status:** [pending] — not supplied in the story

## What it must do (functional)
- Expose `PATCH /api/tasks/:id` that updates the `title` of an existing `tasks` record.
- Validate the incoming `title` with Zod: it must be a non-empty, non-whitespace-only string.
- On a valid request, persist the new `title` and return the updated `tasks` record with a success status (200).
- When no `tasks` record exists for `:id`, respond **404 Not Found** and change nothing.
- When `title` is empty or whitespace-only, respond **400 Bad Request** and change nothing.

## How well it must do it (non-functional)
- **Security:** input is validated server-side (reject empty/whitespace `title`). No authentication or authorization is in scope for this story — the endpoint is open (confirmed: no dependency on an auth story).
- **Validation detail:** a maximum `title` length is **not specified** in the story — [pending] confirmation at review; absent a value, only the non-empty/non-whitespace rule is enforced.
- **Performance:** no specific latency or throughput target was given; none is imposed by this story.
- **Accessibility / scalability:** None identified (backend endpoint only; no UI change).

## Acceptance criteria
1. **Given** a task exists with id `X`, **when** the client sends `PATCH /api/tasks/X` with a non-empty title, **then** the API responds with success and the persisted task title is updated.
2. **Given** no task exists with id `X`, **when** the client sends `PATCH /api/tasks/X` with a non-empty title, **then** the API responds with **404 Not Found**.
3. **Given** a task exists with id `X`, **when** the client sends `PATCH /api/tasks/X` with an empty or whitespace-only title, **then** the API responds with **400 Bad Request** and does not update the task.

## Decisions captured
- **Constraint (persistence):** persistence is **Prisma over SQLite** (`backend/prisma/schema.prisma` declares `provider = "sqlite"`; `app-profile.yml` corrected to match). The story's "SQLite" wording was correct. Prisma abstracts the datastore, so the update logic is engine-independent.
- **Constraint (API shape):** method is `PATCH` on route `/api/tasks/:id`; validation library is **Zod** (named in the story, available per its assumptions).
- **Dependency:** None. No dependency on an auth/permissions story; the endpoint requires no caller identity.
- **Definition of done (verbatim from story):** endpoint works end-to-end; 400 on invalid title, 404 on missing id; update is persisted; automated tests added/updated. Tests use **Vitest + Supertest** per `app-profile.yml`.
- **NFR:** no latency target; security limited to input validation; no authorization; max title length unspecified ([pending]).
- **Exclusions:** see below.

## Explicitly out of scope
- Editing any field other than `title` (including `status`).
- Bulk or multi-task edits.
- Frontend/UI changes (this story is the backend endpoint only).
- Authentication and authorization.
- Edit history / audit trail of title changes.
