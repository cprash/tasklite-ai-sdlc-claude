# Design Review — EPMCDMETST-66637: UI: Enter edit mode for a task from the task list

Review round 2 (re-review of the patched architecture). Round 1 verdict was NEEDS CHANGES; the five targeted edits it asked for were applied to `architecture.md` and approved by the human. This file records round 1 briefly, then the fresh review.

## What was reviewed
- docs/EPMCDMETST-66637/requirements.md
- docs/EPMCDMETST-66637/architecture.md (patched version, read from disk)

Facts about the app were taken only from `.claude/config/app-profile.yml` (TypeScript; React frontend; Express/Prisma backend; SQLite; entity `tasks`; Vitest). No app source was read (G4).

## Round 1 record (first review, NEEDS CHANGES)
| # | Round 1 finding | Sev / Lens | Resolution in patched `architecture.md` | Status |
|---|---|---|---|---|
| 1 | Discard of unsaved typing when switching tasks still described as an open question | MED / Correctness | "Risks and assumptions", second bullet now says the human accepted the discard. Edit 1. | Resolved |
| 2 | Esc carried over as a pending key could invite an opportunistic cancel/leave handler | MED / Scope | Picture edge label, Edit control table row and "UI contract, Edit control" now state that Esc and any cancel or leave behaviour are not bound by this story and that Esc stays [pending] only as the requirements list it. Edit 2. | Resolved |
| 3 | No statement of how AC1 to AC3 are verified | LOW / Correctness | "Technology picks" now says AC1 to AC3 are verified by Vitest component-level checks and that E2E tooling for EPMCDMETST-66824 and EPMCDMETST-66825 is [pending]. Edit 3. | Resolved |
| 4 | Edge paths unstated (id matching no row; focus when the input is absent) | LOW / Error Handling | "Risks and assumptions" has an "Edge paths" bullet covering both. Edit 4. | Resolved |
| 5 | Not stated that this story is only the entry point to edit mode | LOW / Scope | Final "Risks and assumptions" bullet says leaving edit mode is covered by other work and the id-or-none state allows a later story to return it to none. Edit 5. | Resolved |
| 6 | List-level state re-renders the whole list | LOW / Scalability | No architecture change was requested (note for Build and the Work Planner only). | Closed, advisory carries forward |

All five requested edits are present and match the wording the review asked for. The human's defaults hold: no Esc, cancel or leave behaviour is bound by this story (Esc stays [pending]); the E2E tool for EPMCDMETST-66824 and EPMCDMETST-66825 stays [pending]; caret and selection behaviour is left to Build.

## Findings (round 2)
| Severity | Lens | What's wrong | Suggested fix |
|---|---|---|---|
| LOW | Correctness | The patched "Components" table says the task row "shows the Edit control in view mode", while "UI contract, Edit control" says it is "present on every task row". It is not stated whether the Edit control stays visible or active on the row that is already in edit mode, nor what activating it again on that row does. With a single id-or-none state, re-activation sets the same id; the risk is that Build remounts the input and loses what the user typed, or refocuses it unpredictably. | No architecture edit required. This sits in the same class as the caret and selection behaviour the human left to Build. Advisory for the Work Planner: add a check that activating Edit on the row already in edit mode leaves state unchanged and does not discard typed text, and that Build records which choice it made on control visibility in edit mode. If the human wants it pinned, the single sentence belongs in "Components", Edit control row. |
| LOW | Correctness | The architecture says "No new dependency" and relies on Vitest component-level checks for AC1 to AC3 (rendered input, prefilled value, focus, one row in edit mode). `app-profile.yml` names Vitest for the frontend but says nothing about a DOM test environment or component-testing utilities, so whether the frontend can already run such checks is not known. | No architecture edit required. Advisory for the Work Planner: include a first step to confirm that the frontend test setup can render components. If a test-only dependency turns out to be needed, raise it as a question to the human; do not add it silently (this keeps "No new dependency" honest). |
| LOW | Scalability | Carried from round 1 and unchanged: list-level edit-mode state re-renders the list on each activation. Negligible for small lists; task count and performance expectations are [pending]. | None. Row-level memoisation is an option for Build only if list size warrants it. |

Lens coverage notes (no finding raised):
- Security: no API call, no write and no secret. The title is only read into an input's initial value and nothing is submitted, so no validation or authorisation edge exists in this story. Security expectations stay [pending], as in the requirements.
- Scope (data): only `tasks` is used, `title` is read and `id` identifies the row. This matches `data_model.entities`. No new entity, field or endpoint.
- Scope (behaviour): the patched architecture now explicitly excludes saving, cancelling, Esc and any other leave path. The Picture, the table and the contracts are mutually consistent on this.
- Error Handling: for a frontend-only, in-memory change, the unmatched-id and absent-input paths are now covered. Network and persistence failure paths do not exist because there is no API call.
- Correctness against the acceptance criteria: AC1 (prefilled input), AC2 (focus on appearing) and AC3 (a single id value means only one row can match) are each met by the described design.
- Cosmetic, not a finding: the Mermaid diagram uses `\n` inside labels. Some Mermaid renderers show it as a literal `\n`; this has no effect on the design and can be fixed by whoever next touches the diagram. Rendering was not verified here.
- [pending] items remain [pending] and are not invented: exact keys, Esc, Release 1 UI conventions, accessibility beyond keyboard entry, performance, security, concrete component names and locations under `frontend/src`, E2E tooling.

## Decisions we agreed on
- Switching edit mode from task A to task B discards A's unsaved typing. Accepted by the human, because saving and cancelling are out of scope and no draft is kept.
- This story binds no Esc, cancel or leave behaviour. Esc stays [pending] exactly as in the requirements. Reason: leaving edit mode is explicitly out of scope.
- AC1 to AC3 are verified by Vitest component-level checks. The E2E tool for EPMCDMETST-66824 and EPMCDMETST-66825 stays [pending]. Reason: `app-profile.yml` declares only Vitest.
- Caret and selection behaviour on entering edit mode is left to Build. Reason: the story requires only that the cursor is in the input and the title is available for editing.
- A single edit-mode value (task `id` or none) is the right shape: it enforces "only one task in edit mode" by construction, needs no new dependency and keeps the story frontend-only.
- Autofocus on entering edit mode is intended (human answer on AC2).
- The two round 2 LOW correctness items are handled as advisories for the Work Planner rather than architecture edits. Reason: neither contradicts the requirements, and each is a small implementation or setup detail that planning can verify.

## Changes the architecture needs
None — good as is.

Advisories for the Work Planner (not architecture edits): (1) re-activating Edit on the row already in edit mode must not discard typed text, and the Edit control's visibility in edit mode should be recorded by Build; (2) first confirm the frontend test setup can render components, and ask the human before adding any test-only dependency; (3) row-level memoisation only if list size warrants it.

Note for Doc Sync: `requirements.md` "Decisions captured" still does not record the accepted discard decision; it now lives in `architecture.md`. This is a record-keeping gap rather than a defect, and no edit is requested here.

## Verdict
APPROVED — the five round 1 edits are all in place, no HIGH or MED issue remains, and the design satisfies AC1 to AC3; only two LOW advisories remain, for the Work Planner.
