# Requirements — EPMCDMETST-66637: UI: Enter edit mode for a task from the task list

## Story at a glance
- Source: Jira story EPMCDMETST-66637 (type Story), read-only fetch by Intake. Parent epic EPMCDMETST-66636 "TaskLite R2 Edit Task Title". Traceability: BRD FR-1, FR-2; source page https://epamrahulsharma7.atlassian.net/wiki/spaces/TaskLite/pages/40599555/TaskLite-Release2
- Summary: As a user, I want to enter edit mode for a task, so that I can change its title. Business value: enables the primary edit workflow entry point.
- Estimate: 3 SP (initial). Priority: High. Recommended implementation order: 1.
- Owner: unassigned.
- Status: Closed in Jira; deliberately re-run in this repo (cprash/tasklite-ai-sdlc-claude), where Build will implement the feature as new work.
- Linked tests (context only): EPMCDMETST-66824 (E2E: edit mode shows prefilled input and autofocus, AC1/AC2); EPMCDMETST-66825 (E2E: only one task in edit mode, AC3).
- Data scope: entity `tasks` only; only the existing `title` field is involved. No new entities.

## What it must do (functional)
- Each task in the task list offers an Edit control. (Story scope: "Add Edit control per task")
- Activating a task's Edit control switches that task into edit mode, showing a text input prefilled with the task's current title.
- On entering edit mode, the input receives focus automatically (autofocus), so the cursor is placed in the input and the current title is available for editing.
- Only one task is in edit mode at a time: entering edit mode for one task leaves every other task in view mode.
- The Edit control can be reached and activated by keyboard alone (Definition of Done: "Keyboard accessible entry"). The exact keys (Enter/Space on the Edit control, Esc) are [pending].
- Entering edit mode is purely frontend UI state: no API call is made to enter edit mode.

## How well it must do it (non-functional)
- Accessibility: entry into edit mode is keyboard accessible (Definition of Done). Any further accessibility standard or screen-reader expectation is [pending].
- Consistency: follows the UI conventions established in Release 1 and the inline edit pattern assumed by the story (Definition of Ready / Assumptions). The specific conventions are not described in the story or app profile, so they are [pending] until the human confirms them.
- Performance: [pending] (no expectation stated in the story).
- Security: [pending] (no expectation stated in the story). Note that entering edit mode makes no API call and writes no data.

## Acceptance criteria
1. Given the task list is displayed with at least one task, when I activate the Edit control for a task, then that task switches into edit mode showing a text input prefilled with the current title.
2. Given a task is in edit mode, when I focus the edit input, then the cursor is placed in the input and the current title is available for editing.
3. Given multiple tasks exist, when I enter edit mode for one task, then only that task is in edit mode and the others remain in view mode.

## Decisions captured
- Constraint: frontend-only UI state; the inline edit pattern is acceptable (story Assumptions). Stack is per `app-profile.yml` (TypeScript, React frontend). Further technical constraints: [pending].
- Dependency: none per the story ("None (frontend-only UI state)"). EPMCDMETST-66640 (title-edit PATCH) is existing, already merged context; this story does not depend on it for entering edit mode.
- Definition of done (from the story): edit mode can be entered; keyboard accessible entry; no API call required for entering edit mode.
- Data scope (human answer): no new entities; only `tasks`, only the existing title field.
- Re-run context (human answer): deliberate re-run in cprash/tasklite-ai-sdlc-claude; requirements are written as for new work in this repo.
- AC2 wording (human answer): autofocus on entering edit mode is intended, which resolves the "when I focus the edit input" wording.
- Keyboard entry (human answer): keep the DoD wording "Keyboard accessible entry"; the exact keys (Enter/Space on the Edit control, Esc) are [pending].
- NFRs (performance, security): not yet answered; recorded as [pending] above.

## Explicitly out of scope
- Saving an edited title.
- Cancelling edit mode, and any other way of leaving edit mode.
- Any API call, including the title-edit PATCH of EPMCDMETST-66640 (already merged; not part of this story).
- New data entities or fields; only `tasks` and its existing title are involved.
