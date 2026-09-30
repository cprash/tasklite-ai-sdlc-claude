# User Story — Edit Task Title (Inline)

**As a** user,
**I want to** enter edit mode for a task,
**So that** I can change its title.

---

## Business Value

Enables the primary edit workflow entry point.

## Scope

Add Edit control per task; show editable input state.

## Assumptions

Inline edit pattern is acceptable.

## Dependencies

None (frontend-only UI state).

## Priority

High

## Estimate

3 SP

## Recommended Implementation Order

1

---

## Definition of Ready

- Task list item component identified
- UI conventions from Release 1 understood

## Definition of Done

- Edit mode can be entered
- Keyboard accessible entry
- No API call required for entering edit mode

---

## Acceptance Criteria

**AC-1**
- Given the task list is displayed with at least one task
- When I activate the Edit control for a task
- Then that task switches into edit mode showing a text input prefilled with the current title

**AC-2**
- Given a task is in edit mode
- When I focus the edit input
- Then the cursor is placed in the input and the current title is available for editing

**AC-3**
- Given multiple tasks exist
- When I enter edit mode for one task
- Then only that task is in edit mode and the others remain in view mode

---

## Traceability

- BRD: FR-1, FR-2
- Source: https://epamrahulsharma7.atlassian.net/wiki/spaces/TaskLite/pages/40599555/Task+Lite+-+Release+2
