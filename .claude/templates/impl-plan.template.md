---
name: Implementation Plan Doc Shape
description: The layout the work-planner must follow for docs/{{STORY_ID}}/impl-plan.md (capstone Step 4).
---

# Implementation Plan Doc Shape

- Written by: `.claude/subagents/work-planner.md`
- Produces: `docs/{{STORY_ID}}/impl-plan.md`

Give every task a stable id (T1, T2, …) so the Build agent can call them
out. Order strictly by dependency, and flag anything blocked. Every task
must trace to an approved requirement or design decision.

```markdown
# Implementation Plan — {{STORY_ID}}: <story title>

## Phases
<a sentence per logical phase, in the order they run>

## Tasks
| Id | Task | Effort | Waits on |
|---|---|---|---|
| T1 | <task> | LOW/MED/HIGH | none / <task id> |

## Blocked
<task id + what unblocks it, or "None">

## Effort roll-up
<count of LOW/MED/HIGH, and an overall read on the story>
```

## Filled-in sketch (EPMCDMETST-42 — due dates on tasks)

```markdown
## Tasks
| Id | Task | Effort | Waits on |
|---|---|---|---|
| T1 | Add dueDate to the task schema/model | MED | none |
| T2 | Validate dueDate on create/update | LOW | T1 |
| T3 | Return dueDate + overdue flag from the list endpoint | MED | T1 |
| T4 | Show due date + a filter control in the UI | MED | T3 |

## Effort roll-up
1 LOW, 3 MED. Overall: MED — one schema change, contained to the task
feature.
```
