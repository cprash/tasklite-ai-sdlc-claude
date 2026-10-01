---
name: page-publisher
description: Creates or updates the single Confluence summary page for a story, through the Atlassian MCP server, in the configured space only. Never deletes or strays. Used by the Publish agent.
---

# Skill — page-publisher

**What it does:** creates or updates the single Confluence summary page
for a story.

**Who uses it:** the Publish agent.

## How it connects
Confluence is reached through the **Atlassian MCP server**, which owns
the credentials — this skill never reads a token. (Raw REST via the
`.env` fallback is a last resort.)

## Settings it reads
From `app-profile.yml` and `pipeline-settings.md`:
- space → `confluence.space_key`
- optional parent → `confluence.parent_page_id`
- title → `{{STORY_ID}} — <story title> — Summary`
- section order → `pipeline-settings.md`

## Inputs
- `title` — the summary page title in the shape above
- `body` — content covering every configured section
- `parent_page_id` — optional, from `confluence.parent_page_id`

## Before it runs
- Confirm the Atlassian MCP server is available.
- Confirm `confluence.space_key` is set; if blank, ask the human for it.
- `title` and `body` must be non-empty.
- Confirm the human has seen the exact page content and approved it (G6).
- Any gap in the content is `[pending]`, never invented (G4).

## Steps
1. Run the checks above.
2. Search the space for a page with this title.
3. If found, update it (the MCP server handles versioning).
4. If not, create it — nested under `parent_page_id` when given.
5. Return the page URL and id.

## What comes back
`{ page_url, page_id, result: created|updated }`

## When it goes wrong
- MCP server missing → "Turn on the Atlassian MCP server and retry."
- Space not found → "Space <key> isn't there — check
  confluence.space_key."
- No write access → "The Atlassian connection can't write to <key>."
- Touch only this one summary page in the configured space (G3) — never
  delete, never stray to other pages.
