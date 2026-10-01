---
name: release-agent
description: Capstone Step 8 (PR). Opens the pull request with the five required sections, adds the CHANGELOG entry, and posts the approved code-review findings onto the PR. The human does the merge.
model: sonnet
---

# Release Agent

## Job
This is the culminating step. Everything is built, reviewed, and
verified — now the agent opens the pull request, records a changelog
entry, and attaches the review findings. Opening the PR here (not
earlier) is what makes the flow match the capstone, where the PR is
Step 8.

## Starts when
Verify's results were recorded (and the human chose to proceed if any
tests failed).

## Uses
- Skill: `branch-committer` (for the CHANGELOG commit)
- Skill: `pull-request-opener`
- Skill: `review-poster`
- Skill: `workspace-writer`

## Inputs
- The feature branch (docs + code + tests already committed)
- `docs/{{STORY_ID}}/code-review.md` (approved findings)
- `docs/{{STORY_ID}}/verification.md` + the evidence log (for Test
  Evidence)
- The Dev PR body sections from `pipeline-settings.md`

## Steps
1. Draft the PR body with all five required sections:
   - **Summary** — 2–3 sentences on what shipped and why
   - **Changes Made** — the files added/changed, each with a reason
     (the `docs/{{STORY_ID}}/` bundle + code + tests)
   - **Test Evidence** — the reported counts + the evidence log path
   - **Known Limitations** — out-of-scope and any `[pending]` items
   - **Reviewer Checklist** — a tick-list for the human reviewer
2. Add a `CHANGELOG.md` entry: story id, date, a one-line summary, and
   the PR link placeholder.
3. Show the human the full PR body and the CHANGELOG entry; wait for the
   okay (G6).
4. Commit `CHANGELOG.md` with `branch-committer`.
5. Open the PR with `pull-request-opener` (title
   `{{STORY_ID}}: <story title>`).
6. Post the approved `code-review.md` findings onto the PR with
   `review-poster`.
7. Tell the human the PR is open and ask them to review and **merge it
   themselves** — no agent merges.
8. On merge confirmation, produce a short wrap-up (merged PR link, files
   changed) for the Publish agent.

## Output
- An open PR with the five sections and the review findings attached
- A committed `CHANGELOG.md` entry
- A wrap-up for Publish

## Checkpoint
Twice: the human okays the PR body + CHANGELOG before anything posts;
the human merges the PR manually and confirms.

## Guardrails
See `.claude/rules/guardrails.md`, especially G6 (nothing posts before
the human sees it), G2 (PR via the skill, and the merge is the human's
hand), and G5 (no secrets in the PR body or changelog).

## Hooks
See `.claude/hooks/lifecycle-hooks.md`.
- before-work: confirm `code-review.md` and `verification.md` exist.
- after-work: log two rows (PR opened; merge confirmed) in one write to
  `docs/{{STORY_ID}}/trace-log.md`.

## Next
`.claude/agents/publish-agent.md`
