---
name: Guardrails
description: The shared, numbered rules every agent and sub-agent in the pipeline obeys. Each agent points here from its own Guardrails section instead of restating them.
---

# Guardrails

One place for the rules that bind the whole pipeline, so a rule only
ever changes once. Agents reference these by number (G1, G2, …). The
always-on `CLAUDE.md` holds the global principles; this file holds the
enforceable detail.

## G1 — Jira stays read-only
- Only the **Intake agent** reads Jira, and only through the Atlassian
  MCP server via the `story-fetcher` skill.
- Reading means browsing the backlog or pulling one story. Creating,
  editing, transitioning, commenting on, or deleting an issue is never
  allowed — not even on request.
- If a later stage would normally nudge a Jira status ("now in dev"),
  it must not; instead, tell the human to update Jira themselves.
- No agent other than Intake references Jira at all.

## G2 — GitHub writes go through named skills only
- Commits/pushes happen only via `branch-committer`; PRs only via
  `pull-request-opener`; PR comments only via `review-poster`. Nothing
  else writes git history or calls GitHub.
- Merging is always the human's hand on the button — no agent merges.
- No direct pushes to `github.base_branch`; always a feature branch per
  `pipeline-settings.md`.
- The documentation authors never commit or open PRs — their files ride
  along in the Build stage's first commit.

## G3 — Confluence: one summary page, one space
- Only the **Publish agent** reaches Confluence, through the Atlassian
  MCP server via `page-publisher`.
- It may only create or update the single summary page for the story in
  `confluence.space_key`. Never delete pages; never touch anything
  outside that space or off the title pattern.

## G4 — Everything traces to a real source
- Each statement in a generated document must come from the story, from
  `app-profile.yml`, from a file actually read, or from a human answer
  — never from imagination.
- Genuinely missing information is marked `[pending]` or raised as a
  question; gaps are never quietly filled.
- The data model is closed: only the entities in
  `data_model.entities` exist. No inventing tables, columns, endpoints,
  or screens — and no reading app source to discover them.

## G5 — Secrets stay out
- No credentials, tokens, or passwords in generated code or docs — read
  them from the environment or let the MCP server handle auth.
- `.env` is never read into context, written, or committed. The
  `workspace-writer` and `branch-committer` skills enforce this.

## G6 — Checkpoints are real stops
- A skippable stage is still only skipped with explicit human consent,
  and the skip is logged in `docs/{{STORY_ID}}/trace-log.md`.
- Nothing leaves the repo — a PR, a PR comment, a Confluence page —
  before the human has seen the exact content and said go.

## G7 — Stay in your lane
- Each stage edits only the files it owns. The design-critic does not
  rewrite `impl-plan.md`; the Build agent implements only what the
  approved plan covers, with no opportunistic extras.
- A rejected checkpoint bounces back to the stage that owns the rejected
  file; it does not restart the pipeline.
- On a rejection, ask what specifically is wrong and patch just those
  lines — never regenerate a whole document from scratch. Fast
  revisions, visible diffs.
