---
name: pull-request-opener
description: Opens a pull request from the feature branch into the base branch with all five required body sections, through the GitHub MCP server. Never merges. Used by the Release agent.
---

# Skill — pull-request-opener

**What it does:** opens a pull request from the feature branch into the
base branch, with a fully-formed description.

**Who uses it:** the Release agent (capstone Step 8).

## How it connects
The PR is created through the **GitHub MCP server**, which owns the
credentials — this skill never reads a token.

## Settings it reads
From `app-profile.yml` and `pipeline-settings.md`:
- repo → `github.repo`, base → `github.base_branch`
- PR title + required sections → `pipeline-settings.md`

## Inputs
- `branch` — the feature branch to merge from
- `title` — `{{STORY_ID}}: <story title>`
- `body` — must contain all five required sections:
  Summary · Changes Made · Test Evidence · Known Limitations ·
  Reviewer Checklist

## Before it runs
- Confirm the GitHub MCP server is available.
- Confirm `branch` exists on the remote.
- Confirm `body` carries every required section; if any is missing, list
  exactly which and stop.
- Confirm the human has seen the full body and approved it (G6).
- Check whether a PR for this branch already exists.

## Steps
1. Run the checks above.
2. If a PR already exists for `branch`, return its URL and stop (no
   duplicate).
3. Create the PR through the GitHub MCP server: title, head = `branch`,
   base = `github.base_branch`, body.
4. Return the PR URL and number.

## What comes back
`{ pr_url, pr_number, title, result: created|already_open }`

## When it goes wrong
- MCP server missing → "Turn on the GitHub MCP server and retry."
- Branch not on remote → "Branch <branch> isn't pushed — run
  branch-committer first."
- PR already open → return its URL, don't duplicate.
- Missing sections → name exactly which, and don't open until complete.
- Never merge — that's the human's call (G2).
