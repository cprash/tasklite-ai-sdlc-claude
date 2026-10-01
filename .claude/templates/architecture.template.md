---
name: Architecture Doc Shape
description: The layout the architecture-author must follow for docs/{{STORY_ID}}/architecture.md (capstone Step 2).
---

# Architecture Doc Shape

- Written by: `.claude/subagents/architecture-author.md`
- Produces: `docs/{{STORY_ID}}/architecture.md`

Stay inside the stack declared in `app-profile.yml`. Only propose a new
dependency when the story truly needs one, and justify it in writing.
Never name an entity outside `data_model.entities`.

```markdown
# Architecture — {{STORY_ID}}: <story title>

## Where this fits
<how the change sits within the existing app, per app-profile.yml>

## Picture
<a Mermaid or ASCII diagram of the new and changed parts>

## Components and who does what
| Component | Responsibility | New / Changed |
|---|---|---|
| <name> | <role> | New / Changed |

## Technology picks
<stack used; any new dependency with a one-line justification, or "none">

## How data moves
<request/response or event flow; any entity schema change, limited to
 data_model.entities>

## Contracts introduced or touched
<API signatures, event shapes, or UI contracts>

## Risks and assumptions
<what could bite us, and what this design takes for granted>
```

## Filled-in sketch (EPMCDMETST-42 — due dates on tasks)

```markdown
## Technology picks
Stays on the declared stack; no new dependency. Dates use the standard
library already in the project.

## How data moves
Create/update carries an optional `dueDate` → validator checks the ISO
format → stored on the existing `tasks` entity → the list response adds
`dueDate` plus a derived `overdue` flag.
```
