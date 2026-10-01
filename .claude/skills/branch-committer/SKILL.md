---
name: branch-committer
description: Cuts a feature branch, stages named files, commits, and pushes — through the GitHub MCP server, never to the base branch, never .env, never merge. Used by Build, Verify, and Release.
---

# Skill — branch-committer

**What it does:** cuts a feature branch (if needed), stages named files,
commits, and pushes — all within the single application repo.

**Who uses it:** the Build agent (docs bundle + code), the Verify agent
(generated tests), the Release agent (CHANGELOG).

## How it connects
Branch, commit, and push run through the **GitHub MCP server**, which
holds the credentials — this skill never reads a token. (Raw `git` with
the `.env` fallback is a last resort.)

## Settings it reads
From `app-profile.yml` and `pipeline-settings.md`:
- repo → `github.repo`
- base branch → `github.base_branch`
- branch shape → `feature/{{STORY_ID}}-<slug>`
- commit subject → `{{STORY_ID}}: <imperative summary>`

## Inputs
- `files` — an explicit list of paths to stage (never "everything")
- `subject` — the commit subject in the configured shape
- `branch` — optional; derived from the story id if omitted
- `story_id` — `EPMCDMETST-<number>`

## Before it runs
- Confirm the GitHub MCP server is available.
- `files` must be non-empty.
- None of `files` may be `.env` (drop it if it slipped in).
- `subject` must be present and in the right shape.
- Confirm the human has approved this commit (G6) — no commit without a
  go-ahead.

## Steps
1. Run the checks above.
2. Resolve the repo from `github.repo`.
3. If the feature branch is absent, branch it from `github.base_branch`.
4. Stage only the listed files.
5. Double-check `.env` is not staged; remove it if it is.
6. Commit with the configured subject.
7. Push the feature branch.
8. Return the commit sha, branch, and repo.

## What comes back
`{ repo, sha, branch, files, remote_url }`

## When it goes wrong
- MCP server missing → "Turn on the GitHub MCP server and retry."
- Branch already there → reuse it, note "Using existing branch <name>".
- `.env` staged → unstage it, note "Dropped .env — secrets never ship."
- Push rejected → show why, suggest pulling latest and retrying.
- Never push to the base branch, never merge (G2).
