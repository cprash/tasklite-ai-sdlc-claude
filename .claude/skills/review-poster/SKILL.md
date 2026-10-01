---
name: review-poster
description: Posts already-approved code-review findings as comments on the open pull request, through the GitHub MCP server. Comments only — never approves, requests changes, or merges. Used by the Release agent.
---

# Skill — review-poster

**What it does:** takes the already-approved code-review findings and
posts them as comments on the pull request.

**Who uses it:** the Release agent, once the PR is open (the Review
stage itself runs before the PR exists and writes its findings to
`docs/{{STORY_ID}}/code-review.md`).

## How it connects
Comments are posted through the **GitHub MCP server**, which owns the
credentials — this skill never reads a token.

## Inputs
- `pr` — the pull request number or URL
- `findings` — a list of `{ area, severity, kind, note, file?, line? }`
  where `kind` is `Issue` or `Suggestion`

## Before it runs
- Confirm the GitHub MCP server is available.
- Confirm the PR exists and is open.
- Confirm the human already saw this findings list and said to post it
  (G6). Never post unseen content.

## Steps
1. Run the checks above.
2. For each finding, post a PR comment tagged `Issue` or `Suggestion` —
   a line comment when `file`/`line` are present, otherwise a general
   PR comment.
3. Return the posted comment URLs.

## What comes back
`{ count, comment_urls }`

## When it goes wrong
- MCP server missing → "Turn on the GitHub MCP server and retry."
- PR not open → "That PR isn't open; nothing to comment on."
- Not yet confirmed → stop: "Show the findings and get a yes before
  posting (G6)."
- Comments only — never approve, request changes, or merge.
