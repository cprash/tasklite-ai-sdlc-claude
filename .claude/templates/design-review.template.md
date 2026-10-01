---
name: Design Review Doc Shape
description: The layout the design-critic must follow for docs/{{STORY_ID}}/design-review.md (capstone Step 3).
---

# Design Review Doc Shape

- Written by: `.claude/subagents/design-critic.md`
- Produces: `docs/{{STORY_ID}}/design-review.md`

The design-critic reads the architecture as a senior reviewer would,
before any code exists, and surfaces risks and gaps. Every finding
needs a severity and a concrete fix.

```markdown
# Design Review — {{STORY_ID}}: <story title>

## What was reviewed
- docs/{{STORY_ID}}/requirements.md
- docs/{{STORY_ID}}/architecture.md

## Findings
| Severity | Lens | What's wrong | Suggested fix |
|---|---|---|---|
| HIGH/MED/LOW | Correctness/Security/Scalability/Scope/Error Handling | <finding> | <fix> |

## Decisions we agreed on
<each decision reached in review, with a one-line reason>

## Changes the architecture needs
<specific edits architecture.md should receive, or "None — good as is">

## Verdict
<APPROVED or NEEDS CHANGES, plus a one-line reason>
```

## Lenses to look through
- **Correctness** — does the design satisfy `requirements.md`?
- **Security** — input validation, secret handling, authorization edges
- **Scalability** — holds up as data and load grow?
- **Scope** — stays within the story and `data_model.entities`?
- **Error Handling** — failure paths designed, not just the happy path?

## Filled-in sketch (EPMCDMETST-42 — due dates on tasks)

```markdown
## Findings
| Severity | Lens | What's wrong | Suggested fix |
|---|---|---|---|
| MED | Error Handling | Behaviour for a bad date string is unspecified | Reject non-ISO input with 400 + a clear message |
| LOW | Scalability | No index noted for the due-date filter | Add one if the dataset grows |

## Verdict
NEEDS CHANGES — pin down date validation, then this is good to build.
```
