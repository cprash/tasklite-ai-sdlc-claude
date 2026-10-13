# Implementation Plan — EPMCDMETST-66637: UI: Enter edit mode for a task from the task list

Inputs honoured: `requirements.md`, `architecture.md` (patched, approved) and `design-review.md` (round 2, APPROVED, including its three advisories). Facts about the app come only from `.claude/config/app-profile.yml` (TypeScript; React frontend; Vitest; entity `tasks` only; code in `frontend/src`). No app source was read to write this plan (G4). Scope is frontend only: no API call, no schema change, no backend change (G7).

## Phases
1. **Test-setup check (T1, T2)** — confirm the frontend can render components under Vitest before anything is built; if a test-only dependency is needed, stop at a human-approval gate.
2. **Orient (T3)** — Build locates the task-list and task-row components inside `frontend/src` and reconciles with anything already there. The plan does not name files or components.
3. **Implement (T4, T5, T6, T7)** — single edit-mode state, per-task Edit control, prefilled and autofocused input, and safe re-activation on the row already in edit mode.
4. **Prove (T8, T9)** — Vitest component checks mapped to AC1 to AC3, then a regression run of the existing frontend tests and build.

## Tasks
| Id | Task | Effort | Waits on |
|---|---|---|---|
| T1 | **First task.** Confirm the frontend Vitest setup can render React components (DOM test environment and component-testing utilities available and working). Check only what the frontend already declares and runs; record the finding in Build's work notes. Traces to: architecture "Technology picks"; design-review round 2 advisory 2. | LOW | none |
| T2 | **Human-approval gate, only if T1 finds components cannot be rendered.** Do not add anything silently. Ask the human whether a test-only dependency may be added, naming the package and why. On yes, add it as a dev-only dependency and note it; on no, stop and report back. If T1 passes, T2 is closed as "not needed" and "No new dependency" stands. Traces to: design-review round 2 advisory 2; architecture "Technology picks" (No new dependency). | LOW | T1 |
| T3 | Locate the existing task-list component and per-task row component within `code_locations` `frontend/src`, and record their names and paths in Build's work notes. Reconcile with any related edit behaviour that may already exist (the story is Closed in Jira and deliberately re-run). Do not create files or components under invented names; follow what is found. Traces to: architecture "Components" table ([pending] names) and "Risks and assumptions" (re-run). | LOW | T1 |
| T4 | Add the edit-mode state: one value holding the `id` of the single task in edit mode, or none. Setting it for one task returns every other task to view mode. Location (list-level state or elsewhere in the existing frontend) is Build's choice and is recorded. The row whose `id` matches renders in edit mode; if the id matches no rendered row, nothing is in edit mode and nothing breaks. Traces to: AC3; architecture "Edit-mode state", "Edge paths". | LOW | T3 |
| T5 | Add an Edit control to every task row, reachable and activatable by keyboard alone. Activating it sets the edit-mode state to that task's `id`. Entering edit mode makes no API call and writes nothing. Do not bind exact keys beyond what the chosen control natively provides, and bind no Esc, cancel or leave behaviour (keys and Esc stay [pending]). Build records which keys work and **whether the Edit control stays visible in edit mode**. Traces to: AC1; requirements functional bullets 1, 2, 5, 6 and Definition of Done "Keyboard accessible entry"; design-review advisory 1. | LOW | T4 |
| T6 | In edit mode, render in place of the plain title a text input whose initial value equals the task's current `title`, and give it focus automatically when it appears (cursor in the input, current title available for editing). The focus step must tolerate an absent input. Caret and selection behaviour is left to Build and recorded. Only the existing `title` field is read; `id` only identifies the row. Traces to: AC1, AC2; architecture "How data moves" steps 3 to 5, "Edge paths"; design-review "Decisions we agreed on". | MED | T4 |
| T7 | Make activating Edit on the row already in edit mode leave the state unchanged and **not discard typed text** (no remount of the input, no unpredictable refocus that loses the typing). Switching edit mode from task A to task B discards A's unsaved typing; this is accepted and is not to be "fixed" with drafts. Build records the behaviour chosen. Traces to: design-review round 2 advisory 1 and agreed decision on A to B discard; architecture "Risks and assumptions". | LOW | T5, T6 |
| T8 | Write the Vitest component-level tests listed under "Tests" below, one or more per AC, plus the keyboard, no-API-call, re-activation and edge-path checks. If T2 was triggered, depends on its approved outcome. No E2E tests (tool stays [pending]; EPMCDMETST-66824 and EPMCDMETST-66825 are context only). Traces to: AC1 to AC3; architecture "Technology picks"; design-review agreed decision on verification. | MED | T7 (and T2 outcome if triggered) |
| T9 | Run the existing frontend tests and the frontend build (`local_run.build` for the frontend) and confirm nothing regressed and the new tests pass. Report counts to the human for the Verify stage; do not invent results. Traces to: Definition of Done; guardrail G7 (no regressions beyond scope). | LOW | T8 |

## Blocked
- **T2** is a conditional human-approval gate. It is not blocked unless T1 shows the frontend cannot render components; in that case T2 waits on the human's yes/no about adding a test-only dependency, and **T8 stays blocked until T2 is resolved**. T3 to T7 can still proceed meanwhile (they do not need the test dependency).
- Nothing else is blocked. Items that stay [pending] and do not block any task: exact keys and Esc, Release 1 UI conventions, accessibility beyond keyboard entry, performance, security, E2E tooling, concrete component names (found by T3, not invented here).

## Effort roll-up
7 LOW, 2 MED, 0 HIGH. Overall: LOW to MED — one in-memory state value, one control and one input in an existing frontend area, no backend, API or schema work. Consistent with the story's 3 SP estimate. The main variable is T1/T2: if the test setup needs a dependency, one human decision is added before T8.

## Traceability to acceptance criteria
| Requirement | Tasks |
|---|---|
| AC1 — activating Edit shows a text input prefilled with the current title | T4, T5, T6, T8 |
| AC2 — cursor is in the input and the current title is available for editing (autofocus) | T6, T8 |
| AC3 — only one task in edit mode, others stay in view mode | T4, T5, T7, T8 |
| Definition of Done — keyboard accessible entry | T5, T8 |
| Definition of Done — no API call to enter edit mode | T5, T8, T9 |
| Design-review advisory 1 — re-activation keeps typed text; record Edit-control visibility | T5, T7, T8 |
| Design-review advisory 2 — confirm test setup first; human gate for any new dependency | T1, T2 |
| Design-review advisory 3 — row-level memoisation | Note only, below (no task) |

## Tests (Vitest, component level; names are proposed titles for Build to use)
| Test | Verifies |
|---|---|
| `activating Edit on a task shows a text input prefilled with its current title` | AC1 |
| `the edit input has focus when edit mode is entered` | AC2 |
| `the current title is present in the focused input so it can be edited` | AC2 |
| `with several tasks, entering edit mode for one leaves all others in view mode` | AC3 |
| `entering edit mode for task B returns task A to view mode (A's unsaved typing is discarded)` | AC3, accepted decision |
| `the Edit control is reachable and activatable using the keyboard alone` | Definition of Done (keys recorded by Build, not prescribed) |
| `entering edit mode makes no API call` | Definition of Done |
| `activating Edit again on the task already in edit mode keeps the typed text` | Advisory 1 |
| `an edit-mode id that matches no row leaves every task in view mode without error` | Edge path |

## Notes for Build (not tasks)
- Row-level memoisation is an option only if list size warrants it; task count and performance expectations are [pending]. Do not add it speculatively.
- Build's work notes must record: the located component names (T3), the state location (T4), the keys that work and Edit control visibility in edit mode (T5), caret/selection behaviour (T6), the re-activation behaviour (T7), and the T1/T2 outcome.
- Out of scope and not to be added: saving a title, cancel, Esc or any leave path, any API call (including the EPMCDMETST-66640 PATCH), new entities or fields, backend changes.
