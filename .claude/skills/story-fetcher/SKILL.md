---
name: story-fetcher
description: Pulls a user story to work on — from Jira, a Confluence page, or a Word document — read-only, via the Atlassian MCP server. Used only by the Story Intake agent.
---

# Skill — story-fetcher

**What it does:** pulls a user story to work on, from whichever source
holds it — Jira, a Confluence page, or a Word document. Read-only.

**Who uses it:** the Intake agent (`.claude/agents/intake-agent.md`) only.

## How it connects
Jira and Confluence are reached through the **Atlassian MCP server**,
which owns the credentials — this skill never reads a token. A Word
document is read from a local path the human supplies. (Raw REST using
the `.env` fallback variables is a last resort, not the norm.)

## Before it runs
- For a Jira or Confluence source, confirm the Atlassian MCP server is
  available; if not, stop and ask the human to enable it.
- For a single Jira story, check the id matches `EPMCDMETST-<number>`.
- For a Word doc, confirm the file path exists.

## Three ways to call it

### Browse the backlog (Jira)
No input. Ask the Atlassian MCP "search" tool with JQL:
`project = EPMCDMETST AND statusCategory != Done AND issuetype = Story ORDER BY rank ASC`.
Only Story-type issues come back (no sub-tasks, tasks, or bugs). Group
by parent/epic and return a numbered list for the human to pick from.
Strictly read-only.

### Pull one Jira story
Input: `EPMCDMETST-<number>`. Ask the Atlassian MCP "get issue" tool
and return: title, description, acceptance criteria, estimate, status,
owner.

### Read a story from Confluence or Word
Input: a Confluence page (title or id) or a local `.docx` path. Extract
the same fields — title, description, acceptance criteria — mapping
them from the document's headings. Note anything the document does not
provide as `[pending]` rather than inventing it.

## What comes back
- Backlog browse: a numbered list of `{ epic, story_id, title, status }`
- Single story (any source): `{ story_id, title, description,
  acceptance_criteria, estimate, status, owner, source }`

## When it goes wrong
- MCP server missing → "Turn on the Atlassian MCP server and retry."
- Story not found → "Can't find {{STORY_ID}} in EPMCDMETST."
- No read access → "The Atlassian connection can't read EPMCDMETST."
- Empty backlog → "No open stories in EPMCDMETST right now."
- Word file missing → "No document at that path."
- Never attempt a write of any kind — G1 forbids it.
