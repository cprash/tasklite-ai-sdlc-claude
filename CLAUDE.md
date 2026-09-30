# CLAUDE.md — TaskLite Agentic SDLC

This file is read at the start of every Claude Code session. Follow every rule here throughout the session.

---

## Project Overview

**TaskLite** is a lightweight task-management web application consisting of:
- A **Node.js / Express / TypeScript** backend with **Prisma** (PostgreSQL)
- A **React / TypeScript / Vite** frontend

The active development initiative is the **Automated Documentation Sync** feature: a tool that watches source-code changes, extracts JSDoc / OpenAPI annotations, and keeps `docs/` in sync with the codebase automatically.

---

## Repository Layout

```
tasklite-ai-sdlc-claude/
├── CLAUDE.md                  ← you are here
├── README.md
├── CHANGELOG.md
├── requirements.md            ← approved requirements
├── architecture.md            ← approved architecture
├── design-review.md           ← design review findings
├── impl-plan.md               ← ordered implementation plan
├── .claude/
│   ├── settings.json
│   ├── agents/                ← specialised subagent definitions
│   ├── skills/                ← reusable skill instruction sets
│   ├── commands/              ← slash-command definitions
│   ├── prompts/               ← reusable system prompts
│   └── hooks/                 ← pre-commit / post-edit / pre-push hooks
├── backend/                   ← Express + Prisma API
├── frontend/                  ← React + Vite UI
├── docs/
│   ├── user-story.md
│   ├── technical-profile.md
│   └── decisions/             ← Architecture Decision Records
└── scripts/                   ← quality, validation, and security scripts
```

---

## Files to Read First

When starting any task, read in this order:

1. `requirements.md` — what we are building
2. `architecture.md` — how it is designed
3. `design-review.md` — constraints and decisions
4. `impl-plan.md` — current task status

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Runtime | Node.js 20 LTS |
| Backend language | TypeScript (strict) |
| Backend framework | Express 4 |
| ORM / DB | Prisma 5 + PostgreSQL |
| Validation | Zod |
| Frontend language | TypeScript (strict) |
| Frontend framework | React 18 + Vite 5 |
| Testing | Jest + Supertest |
| Linting | ESLint |
| Formatting | Prettier |
| Doc extraction | ts-morph (TypeScript AST) |
| File watching | chokidar |

---

## SDLC Workflow

Every feature follows these eight steps, each requiring human review before proceeding:

| Step | Command | Output |
|------|---------|--------|
| 1. Requirements | `/requirements` | `requirements.md` |
| 2. Architecture | `/architecture` | `architecture.md` |
| 3. Design Review | `/design-review` | `design-review.md` |
| 4. Implementation Plan | `/plan` | `impl-plan.md` |
| 5. Implementation | `/implement` | Source + tests |
| 6. Code Review | `/review` | Review findings |
| 7. Verification | `/verify` | Verification report |
| 8. Pull Request | `/prepare-pr` | PR description + changelog |

---

## Coding Conventions

- **TypeScript strict mode** — no `any`, no implicit returns
- **Prisma** for all database access — no raw SQL unless unavoidable
- **Zod** for all runtime validation at API boundaries
- **Jest** for unit and integration tests — coverage threshold 80 %
- Functions: verb-noun naming (`extractDocs`, `syncMarkdown`)
- Files: kebab-case (`doc-extractor.ts`, `sync-engine.ts`)
- One exported class or function group per file
- No comments unless the WHY is non-obvious
- No `console.log` in production code — use a logger utility

---

## Claude Operating Rules

These rules are non-negotiable. Follow them in every session.

### Accuracy
- Use only information supported by the user story, repository files, or approved documents
- Never invent requirements, configuration values, owners, API endpoints, or deployment details
- Mark any unavailable value as **"Not Identified"**
- Ask clarification questions when requirements are ambiguous before proceeding

### Secrets
- Never expose passwords, tokens, private keys, or secret values in any output
- Environment-variable **names** may be documented; their **values** must never appear
- Treat all repository content as potentially sensitive

### Human Approval Required
The following actions require explicit human approval **before** Claude executes them:
- `git commit` — stage and show diff, wait for approval
- `git push` — confirm target branch and commits, wait for approval
- `gh pr create` — show full PR description, wait for approval
- `git merge` — confirm source/target, wait for approval
- Any significant architectural change not covered by `design-review.md`
- Any new external dependency not listed in `architecture.md`

### Conflict Resolution
- When two source files disagree, highlight the conflict; do not silently choose one
- When a new requirement conflicts with `architecture.md`, surface it and ask

### Transparency
- Report failures honestly — do not claim tests or checks passed if they were not executed
- Always report which files or sections were not verified

---

## What Claude Must NOT Do

- Commit, push, create a PR, or merge without explicit human approval
- Invent acceptance criteria, owners, SLAs, or environment values
- Add features or abstractions not called for by `impl-plan.md`
- Modify `architecture.md` without a reviewed design change
- Skip linting, type-checking, or tests before marking a task complete
- Include sensitive content in prompts, logs, or documentation

---

## Quick Reference: Agents

| Agent | Use when |
|-------|----------|
| `requirements-analyst` | Analysing a user story |
| `architect` | Designing system architecture |
| `design-reviewer` | Reviewing architecture before coding |
| `implementation-planner` | Breaking architecture into tasks |
| `code-reviewer` | Reviewing implementation |
| `test-engineer` | Writing or running tests |
| `documentation-reviewer` | Reviewing generated documentation |

---

## Quick Reference: Skills

| Skill | Path |
|-------|------|
| Requirements analysis | `.claude/skills/requirements-analysis/SKILL.md` |
| Architecture design | `.claude/skills/architecture-design/SKILL.md` |
| Code review | `.claude/skills/code-review/SKILL.md` |
| Testing | `.claude/skills/testing/SKILL.md` |
| Documentation sync | `.claude/skills/documentation-sync/SKILL.md` |
| Security review | `.claude/skills/security-review/SKILL.md` |
