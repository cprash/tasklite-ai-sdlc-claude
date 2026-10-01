---
name: Requirements Doc Shape
description: The layout the requirements-author must follow for docs/{{STORY_ID}}/requirements.md (capstone Step 1).
---

# Requirements Doc Shape

- Written by: `.claude/subagents/requirements-author.md`
- Produces: `docs/{{STORY_ID}}/requirements.md`

Keep every heading below. If a section genuinely has nothing, write
`None identified` rather than deleting it. Every line must trace to the
story, `app-profile.yml`, or a human answer (G4) and stay inside
`data_model.entities`.

```markdown
# Requirements — {{STORY_ID}}: <story title>

## Story at a glance
<source (Jira/Confluence/Word), summary, estimate, owner, status>

## What it must do (functional)
<bullets, each a concrete behaviour the system must exhibit>

## How well it must do it (non-functional)
<performance, security, accessibility, scalability — from the NFR answer>

## Acceptance criteria
<from the story, tidied but not reinterpreted>

## Decisions captured
<the clarifying Q&A, one bullet per answer: constraints, dependencies,
 definition of done, NFRs, exclusions>

## Explicitly out of scope
<what we are deliberately not doing>
```

## Filled-in sketch (EPMCDMETST-42 — due dates on tasks)

```markdown
## What it must do (functional)
- A task may carry an optional due date (ISO calendar date)
- The task list shows the due date and marks open tasks that are overdue
- Tasks can be filtered by due-date state: overdue, due today, upcoming

## Decisions captured
- Constraint: reuse the existing `tasks` entity — no new entity
- Dependency: none; self-contained in the task feature
- Definition of done: create, show, and filter by due date all work
- NFR: the list responds under 200 ms at current data volumes
- Exclusions: recurring due dates and reminders are out of scope
```
