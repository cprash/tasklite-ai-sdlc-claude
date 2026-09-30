# User Story — Automated Documentation Sync

**ID:** TASKLITE-42  
**Type:** Developer Experience  
**Status:** Approved  
**Sprint:** 2026-Q4-S1

---

## User Story

**As a** backend developer on the TaskLite team,  
**I want** the API documentation in `docs/api/` to be automatically generated and kept in sync with the TypeScript source code,  
**So that** documentation is always current without requiring manual updates, and CI can fail when documentation drifts from the code.

---

## Background

Currently, `docs/api/` is maintained manually. Developers frequently forget to update the documentation when they change function signatures, add new endpoints, or deprecate old ones. This has led to:

- Outdated parameter descriptions causing integration bugs
- New team members relying on stale docs
- Code review findings about documentation drift that take time to resolve

The team wants an automated tool that:
1. Watches for changes to TypeScript source files during development
2. Extracts JSDoc and OpenAPI annotations automatically
3. Writes up-to-date Markdown to `docs/api/`
4. Provides a CI check (`npm run docs:check`) that fails if docs are stale

---

## Acceptance Criteria

1. Running `npm run docs:sync` generates Markdown files in `docs/api/` for all modules in `backend/src/`
2. Running `npm run docs:watch` starts a watcher that re-syncs whenever a `.ts` file changes
3. Running `npm run docs:check` in CI exits with code 1 if any doc file is out of date
4. Generated files include a timestamp header so drift can be detected
5. Functions without JSDoc are listed as undocumented in a sync report, not silently omitted
6. No secrets or environment-variable values appear in generated documentation

---

## Out of Scope

- Syncing documentation to external systems (Confluence, GitHub Wiki) — future iteration
- Frontend React component documentation — future iteration
- Automated PR creation for documentation updates — future iteration
- Support for TSDoc syntax (only JSDoc is in scope)

---

## Notes

- The tool should be a dev dependency only — it must not affect the production bundle
- It should work cross-platform (macOS, Linux, Windows)
- The `docs/api/` directory is to be treated as generated output — no manual edits

---

## Stakeholders

| Role | Name | Notes |
|------|------|-------|
| Product Owner | Not Identified | — |
| Tech Lead | Not Identified | — |
| Backend Developer | Not Identified | Primary user |
| DevOps | Not Identified | CI integration |
