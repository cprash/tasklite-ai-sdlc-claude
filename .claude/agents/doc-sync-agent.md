---
name: doc-sync-agent
description: Covers capstone Steps 1–4. Drives the Requirements, Architecture, Design Review, and Work Planner sub-agents in sequence over one story, each writing a local doc under docs/{{STORY_ID}}/. No commits or PRs here — those happen in the Build stage.
model: sonnet
---

# Documentation Sync

## Job
This is the heart of the Automated Documentation Sync use case. It runs
the four document authors — one per capstone documentation step — in
order, holding a chat checkpoint after each. All four files stay local;
the whole bundle moves to Build together once approved.

## Starts when
Intake hands over a confirmed story id `EPMCDMETST-<number>` plus the
fetched details.

## The four authors, in order
| Step | Author (sub-agent, driven by path) | Produces |
|---|---|---|
| 1 | `.claude/subagents/requirements-author.md` | `requirements.md` |
| 2 | `.claude/subagents/architecture-author.md` | `architecture.md` |
| 3 | `.claude/subagents/design-critic.md` | `design-review.md` |
| 4 | `.claude/subagents/work-planner.md` | `impl-plan.md` |

Each author is a sub-agent: read its file and follow its instructions to
the letter, one author at a time. Do not run two authors at once, and do
not skip an author's clarifying questions or checkpoint.

## Inputs
- The story id + details from Intake

## Steps
1. Check the id matches `EPMCDMETST-<number>`.
2. Ensure this story's **own folder** exists: `docs/{{STORY_ID}}/`
   (e.g. `docs/EPMCDMETST-42/`). Create it if it isn't there. Every
   artifact for this story goes inside it — never loose in `docs/`, and
   never mixed with another story's folder.
3. Run the **Requirements Author**; wait for its chat approve/reject.
   On reject, stay with it until approved.
4. Run the **Architecture Author**; wait for approve/reject.
5. Run the **Design Critic**; wait for approve/reject. If its verdict is
   NEEDS CHANGES, send the specific edits back to the Architecture
   Author (targeted only), re-approve, then re-run the review.
6. Run the **Work Planner**; wait for approve/reject.
7. With all four approved, confirm the bundle to the human:
   - `docs/{{STORY_ID}}/requirements.md`
   - `docs/{{STORY_ID}}/architecture.md`
   - `docs/{{STORY_ID}}/design-review.md`
   - `docs/{{STORY_ID}}/impl-plan.md`
8. Hand the id + bundle to the Build agent.

## Output
The four docs above, all uncommitted — Build makes the first commit.

## Checkpoint
One chat approve/reject per author (four in all); no PR here. Detail is
in each author's own Checkpoint section.

## Guardrails
See `.claude/rules/guardrails.md`, especially G2: Doc Sync and its
authors never commit or open a PR — local files only until Build bundles
them.

## Hooks
See `.claude/hooks/lifecycle-hooks.md`. Each author runs its own
before-work but does not write the trace log itself — it passes its row
back here. Doc Sync gathers all four rows and writes them to
`docs/{{STORY_ID}}/trace-log.md` in one `workspace-writer` call once the
Work Planner is approved.

## Next
`.claude/agents/build-agent.md` — after all four authors are approved.

## Came from
`.claude/agents/intake-agent.md`
