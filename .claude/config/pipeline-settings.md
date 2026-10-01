# Pipeline Settings

Shared, non-secret knobs for the pipeline. Everything here is safe to
commit. Anything that changes per application lives in
[`app-profile.yml`](app-profile.yml); anything secret belongs to the
Atlassian / GitHub MCP servers.

## Connectivity
- Jira (read-only) and Confluence → **Atlassian MCP server**
- GitHub branches, commits, PRs, comments → **GitHub MCP server**
- The pipeline never reads provider tokens directly.

## Story identity
- Jira project: `EPMCDMETST` (confirm against `jira.project_key`)
- Story pattern: `EPMCDMETST-<number>` — written as `{{STORY_ID}}`
- A story can be sourced from Jira, a Confluence page, or a Word
  document (capstone Step 1). Whichever the source, the same fields are
  captured: title, description, acceptance criteria, estimate, status,
  owner.
- Minimum clarifying questions before requirements are finalised: 3

## One folder per story
Every story gets its **own** folder, named exactly after its story id:
`docs/{{STORY_ID}}/` — for example `docs/EPMCDMETST-42/`. Artifacts
are never written loose in `docs/`; they always live inside that story's
folder, so two stories in flight never collide. The folder is created
the first time the story needs it (by the requirements-author) and never
shared across stories.

## The four synced documents (per story)
Produced during Doc Sync, in order, each by its own author sub-agent,
all inside `docs/{{STORY_ID}}/`:
| File (inside `docs/{{STORY_ID}}/`) | Author | Capstone step |
| --- | --- | --- |
| `requirements.md` | requirements-author | 1 |
| `architecture.md` | architecture-author | 2 |
| `design-review.md` | design-critic | 3 |
| `impl-plan.md` | work-planner | 4 |

Two more artifacts join them later in the same folder:
`code-review.md` (Review stage) and `verification.md` (Verify stage),
alongside the auto-kept `trace-log.md` and `handoff.md`. A finished
story folder therefore looks like:

```
docs/EPMCDMETST-42/
├── requirements.md
├── architecture.md
├── design-review.md
├── impl-plan.md
├── code-review.md
├── verification.md
├── trace-log.md
└── handoff.md
```

## Branch + commit style
- Branch: `feature/{{STORY_ID}}-<slug>` (slug ≤ 5 lowercase, hyphenated
  words), always cut from `github.base_branch`.
  e.g. `feature/EPMCDMETST-42-due-dates`
- Commit subject: `{{STORY_ID}}: <imperative summary>` (≤ 72 chars).
  e.g. `EPMCDMETST-42: add due date to task model`

## When things get committed
The documentation authors leave their files uncommitted. The Build
stage (Step 5) cuts the feature branch and makes the first commit —
the whole `docs/{{STORY_ID}}/` bundle plus the code — so docs and code
land together. Nothing is pushed to `github.base_branch` directly.

## The pull request (Step 8, the final stage before publish)
The PR is opened by the Release agent, *after* review and verification
— not early. Required PR body sections (all mandatory):
1. **Summary** — 2–3 sentences: what was built and why
2. **Changes Made** — every file added/changed, with the reason
3. **Test Evidence** — the verification run output or a link
4. **Known Limitations** — anything out of scope or marked "Not Found"
5. **Reviewer Checklist** — a tick-list the human completes before approving

## Review checklist (Step 6)
The Review agent scores the implementation against these seven areas,
taken straight from the capstone:
| Area | Question |
| --- | --- |
| Correctness | Does each piece behave as `requirements.md` specifies? |
| Security | Are secrets kept out of output? Is input validated? |
| Error Handling | Are failures, missing data, and empty states handled? |
| Test Coverage | Do tests hit the happy path *and* the not-found / missing-field edges? |
| Code Clarity | Are names self-explanatory and the logic easy to follow? |
| DRY | Is there duplication worth refactoring into one place? |
| Dependency Safety | Any known-vulnerable package versions flagged? |

## Verify (Step 7)
Verification covers two things, not one:
- **Code** — generate and run unit + integration tests against the
  running app at `local_run.url`.
- **Documents** — a content-quality pass over the synced docs (are they
  complete, internally consistent, free of `[pending]` leftovers?).

## Confluence summary (documentation sync target)
- Space: `confluence.space_key`
- Title: `{{STORY_ID}} — <story title> — Summary`
- Sections, in order: Story Overview · Architecture & Design · Code
  Changes · Review Outcome · Verification Results · PR Reference
- Create if absent, update if present. Mark truly missing data
  `[pending]`, never fabricated.

## Stage controls
- Soft time budget per stage: 10 minutes (excludes human waits)
- MCP/API retry attempts: 1
- Must always run: Intake, Requirements, Implementation, Verify
- Skippable only with spoken human consent (and logged as skipped):
  Architecture, Design Review, Implementation Planning

## Artifacts + audit
Everything for a story lives under `docs/{{STORY_ID}}/`. Each agent
appends a row to `docs/{{STORY_ID}}/trace-log.md` and refreshes
`docs/{{STORY_ID}}/handoff.md` through the finish hook — see
[`lifecycle-hooks.md`](../hooks/lifecycle-hooks.md).
