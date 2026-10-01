# Changelog

All notable changes to TaskLite are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Added
- Backend persistence for edited task titles: `PATCH /api/tasks/:id` validates a
  non-empty, ≤255-char title with Zod (stored trimmed), returns the updated task
  (200), and maps unknown/non-integer ids to 404 and invalid bodies to 400
  (EPMCDMETST-66640)
- `updateTaskTitleSchema` validator and `updateTaskTitle` controller handler
- Vitest + Supertest suite for the title-edit endpoint (AC1–AC3 plus non-integer
  id and over-length edges; 6 tests)
- SDLC: `docs/EPMCDMETST-66640/` artifact bundle (requirements, architecture,
  design review, impl plan, code review, verification, trace log, handoff)
- Inline edit mode entry for task titles (`TaskItem`, `TaskList`, `App`)
- `editingTaskId` state in `App` for mutual exclusion — only one task in edit mode at a time
- Edit button with accessible `aria-label` per task item
- Inline `<input>` prefilled with current title, auto-focused on edit entry
- Escape key handler to cancel edit mode without saving
- Vitest + React Testing Library test suite for `TaskItem` edit mode
- `vitest.config.ts` and `src/test-setup.ts` for frontend testing infrastructure
- Test dependencies: `vitest`, `@testing-library/react`, `@testing-library/user-event`, `jest-axe`, `jsdom`
- SDLC: requirements FR-009–FR-011, NFR-006–007 for Edit Task Title story
- SDLC: architecture section for frontend edit mode component design
- SDLC: design review CI-004 (exit mechanism) and HR-003 resolved as Option A
- SDLC: impl-plan TASK-018–TASK-022 for Edit Task Title story
- Agentic SDLC scaffold: agents, skills, commands, prompts, and hooks
- `CLAUDE.md` project instructions for Claude Code sessions
- `requirements.md` — approved requirements for Automated Documentation Sync
- `architecture.md` — approved system architecture
- `design-review.md` — design review findings and decisions
- `impl-plan.md` — dependency-ordered implementation plan
- `docs/user-story.md` — source user story
- `docs/technical-profile.md` — technical profile of the project
- `docs/decisions/ADR-001-doc-extraction-library.md` — decision record for ts-morph
- `scripts/validate-docs.sh` — documentation validation script
- `scripts/run-quality-checks.sh` — quality gate script
- `scripts/scan-secrets.sh` — secret scanning script

---

## [0.1.0] — 2026-09-30

### Added
- Initial TaskLite application
- Express backend with Prisma + PostgreSQL
- Task CRUD endpoints (`POST /tasks`, `GET /tasks`, `GET /tasks/:id`, `PATCH /tasks/:id`, `DELETE /tasks/:id`)
- Health check endpoint (`GET /health`)
- React + Vite frontend with task list, task form, and task item components
- Zod validation for task creation and update payloads
- Global error handler middleware
