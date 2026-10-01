# CLAUDE.md — Agentic SDLC Pipeline

This file is read at the start of every Claude Code session and is
always in context. It plays the same role GitHub Copilot's
`copilot-instructions.md` plays: the global rules every agent and
sub-agent in this pipeline obeys.

This repository hosts an **Agentic SDLC Pipeline** for the *Automated
Documentation Sync* capstone. The whole software delivery lifecycle —
from capturing a user story through to merging a production-ready pull
request — is driven by Claude Code: a conductor agent, eight stage
agents, four documentation authoring sub-agents, reusable skills, shared
guardrails, and lifecycle hooks.

Two principles shape everything here:

1. **Portable, not project-bound.** The pipeline must run against *any*
   codebase. It never opens, scans, or infers the target application's
   source. Everything it needs to know about the app it reads from one
   human-maintained descriptor: [`.claude/config/app-profile.yml`](.claude/config/app-profile.yml).
   When a needed fact is absent from that file and from the story, the
   agent asks a question — it does not guess.
2. **Human stays in the loop.** Every stage that produces an artifact
   pauses for an explicit approval before the pipeline advances.

## How the pieces map to the capstone's 8 steps
| Capstone step | Owned by |
| --- | --- |
| 1 Requirements | `.claude/subagents/requirements-author.md` |
| 2 Architecture | `.claude/subagents/architecture-author.md` |
| 3 Design Review | `.claude/subagents/design-critic.md` |
| 4 Implementation Planning | `.claude/subagents/work-planner.md` |
| 5 Implementation | `.claude/agents/build-agent.md` |
| 6 Review | `.claude/agents/review-agent.md` |
| 7 Verify | `.claude/agents/verify-agent.md` |
| 8 PR | `.claude/agents/release-agent.md` |

Story intake (reading the user story) is handled by
`.claude/agents/intake-agent.md`, and the final documentation sync to
Confluence by `.claude/agents/publish-agent.md`. The whole run is
coordinated by `.claude/agents/conductor.md` and kicked off with the
`/run-pipeline` command.

## Agents vs sub-agents
- **`.claude/agents/`** — the stage agents the Agent tool launches
  directly: `conductor`, `intake-agent`, `doc-sync-agent`,
  `build-agent`, `review-agent`, `verify-agent`, `release-agent`,
  `publish-agent`.
- **`.claude/subagents/`** — the four documentation authors the Doc Sync
  agent drives one at a time: `requirements-author`,
  `architecture-author`, `design-critic`, `work-planner`. They are
  referenced by path, each writing exactly one document.

## Directory layout
- `.claude/agents/` — the launchable stage agents plus the conductor
- `.claude/subagents/` — the four documentation authors invoked by Doc Sync
- `.claude/skills/` — single-purpose, reusable actions (fetch, write,
  commit, PR, comment, publish, log evidence)
- `.claude/templates/` — the exact shape each generated document must take
- `.claude/rules/` — the shared guardrail set every agent obeys
- `.claude/hooks/` — the start/finish lifecycle steps every agent runs
- `.claude/config/` — the per-repo app descriptor and the pipeline settings
- `.claude/commands/` — the one-command entry point (`/run-pipeline`)
- `docs/<STORY_ID>/` — a dedicated folder per story, named after its
  story id (e.g. `docs/EPMCDMETST-42/`), holding every generated
  artifact for that story: `requirements.md`, `architecture.md`,
  `design-review.md`, `impl-plan.md`, then `code-review.md`,
  `verification.md`, `trace-log.md`, and `handoff.md`. Nothing is ever
  written loose in `docs/` — always inside the story's own folder.

## External systems
- **Jira** (project `EPMCDMETST`) and **Confluence** are reached only
  through the **Atlassian MCP server**.
- **GitHub** (branches, commits, pull requests, comments) is reached only
  through the **GitHub MCP server**.
- These servers hold their own credentials. Agent logic never handles
  Jira / Confluence / GitHub tokens.

## Writing code for the target app
- Honour the languages and frameworks listed in `app-profile.yml`; do not
  bring in a different stack unprompted.
- Give functions clear names and wrap them in real error handling.
- Keep each change inside the scope the approved plan defines.

## Secrets
- Credentials are never written into code or docs — they come from the
  environment or the relevant MCP server.
- `.env` is off-limits: never read into context, never written, never
  committed.

## Non-negotiables
- Ask before assuming.
- Wait for approval at every checkpoint.
- The only data entities that exist are those under
  `data_model.entities` in `app-profile.yml` — never invent more.
- Jira access is **read-only**, and only the intake agent may touch it.
  See `.claude/rules/guardrails.md` G1.
- Never commit, push, open a PR, or merge without explicit human approval.

## Where to look
- Run control: `.claude/agents/conductor.md`
- Entry command: `.claude/commands/run-pipeline.md`
- App facts: `.claude/config/app-profile.yml`
- Settings: `.claude/config/pipeline-settings.md`
- Guardrails: `.claude/rules/guardrails.md`
- Lifecycle hooks: `.claude/hooks/lifecycle-hooks.md`
