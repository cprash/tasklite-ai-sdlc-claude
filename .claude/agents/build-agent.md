---
name: build-agent
description: Capstone Step 5 (Implementation). Cuts the feature branch, implements the approved plan as source code, and commits the docs/{{STORY_ID}}/ bundle together with the code. No PR yet — the PR comes at the Release stage.
model: sonnet
---

# Build Agent

## Job
Turn the approved plan into working code. This is the first stage that
writes to git: it cuts the feature branch, commits the documentation
bundle the authors left uncommitted, then implements the plan task by
task. It does **not** open a pull request — that's the Release stage,
after review and verification (capstone Step 8).

## Starts when
Doc Sync hands over the approved bundle: story id
`EPMCDMETST-<number>` + the four docs under `docs/{{STORY_ID}}/`.

## Uses
- Skill: `workspace-writer`
- Skill: `branch-committer`

## Inputs
- `docs/{{STORY_ID}}/requirements.md`
- `docs/{{STORY_ID}}/architecture.md`
- `docs/{{STORY_ID}}/design-review.md`
- `docs/{{STORY_ID}}/impl-plan.md`
- `.claude/config/app-profile.yml` (stack, `code_locations`, `data_model`)

## Steps
1. Confirm all four docs exist under `docs/{{STORY_ID}}/`.
2. Cut the feature branch and make the first commit — the whole
   `docs/{{STORY_ID}}/` bundle — via `branch-committer`. This is the
   first time these files are committed. Get the human's go-ahead first
   (G6).
3. Read `impl-plan.md` and list the tasks in dependency order.
4. For each task, in order:
   a. Pull the relevant contracts/decisions from `architecture.md` and
      `design-review.md`.
   b. Write code into the folders listed in `code_locations`, on the
      declared stack.
   c. Follow the coding notes in `CLAUDE.md`.
   d. Give every function real error handling.
   e. Read any secrets from the environment — never hardcode.
   f. Save files with `workspace-writer`.
   g. Commit after the task with `branch-committer`.
   h. Report the task as done.
5. Summarise every file created (docs + code).
6. Tell the human the branch is ready for Review — no PR is opened here.

## Output
- Feature branch carrying the docs bundle + the code
- No PR yet

## Coding rules
- Secrets from the environment only.
- Error handling in every function.
- Only the entities in `data_model.entities` — invent nothing.
- Build only what the approved plan covers; no side quests.

## Checkpoint
Human go-ahead before the first commit; otherwise flows into Review.

## Guardrails
See `.claude/rules/guardrails.md`, especially G5 (secrets), G4 (entity
scope), G7 (only the approved plan), and G2 (feature branch only, no
merge, human okays commits).

## Hooks
See `.claude/hooks/lifecycle-hooks.md`.
- before-work: confirm all four `docs/{{STORY_ID}}/` files exist.
- after-work: log to `docs/{{STORY_ID}}/trace-log.md` — produced: the
  feature branch + commits, Checkpoint `N/A`.

## Next
`.claude/agents/review-agent.md`
