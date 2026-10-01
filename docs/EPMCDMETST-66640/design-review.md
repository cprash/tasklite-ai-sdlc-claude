# Design Review — EPMCDMETST-66640: Persist edited task title

## What was reviewed
- docs/EPMCDMETST-66640/requirements.md
- docs/EPMCDMETST-66640/architecture.md

## Findings
| Severity | Lens | What's wrong | Suggested fix |
|---|---|---|---|
| MED | Error Handling | `:id` parsing is described as "a non-integer id resolves to 404", but the design doesn't say *how*. Passing a non-integer straight to a Prisma `Int` lookup can throw and surface as an unhandled **500**, not the intended 404. | Guard first: parse `:id` to an integer; if it is not a valid integer, return **404** (unknown id) before any DB call. State this explicitly in architecture.md. |
| MED | Error Handling | The find-then-update happy path is defined, but the failure mapping for the data layer is not. A row deleted between find and update (Prisma `P2025`), or any other DB error, has no defined response. | Define the mapping: unknown/missing row → **404**; unexpected DB/Prisma error → **500** with a generic message (no internals leaked). Prefer a single `update` guarded by catching `P2025` → 404, or a find-then-update inside one handler. |
| MED | Correctness | Trim semantics are ambiguous: Zod trims to *check* non-empty, but the design doesn't say whether the **stored** title is the trimmed value or the raw input (e.g. `"  Hi  "`). | Decide and record: persist the **trimmed** value, so acceptance criterion 1 ("the persisted task title is updated") is unambiguous. |
| LOW | Security | No maximum `title` length — unbounded strings are accepted, a minor abuse/row-size concern. Already `[pending]` in requirements. | Add a Zod `.max(<n>)` once product confirms the bound; until then apply a sensible interim cap (e.g. 255) and note it as provisional. |
| — | Scope | **No issue.** Change touches only `title` on the `tasks` entity; no new entity, no schema migration, no out-of-scope fields. Confirms G4/G7. | None. |
| — | Scalability | **No issue.** Lookup and update are by the `tasks` integer PK (indexed); single-row write. No growth concern at this scale. | None. |

## Decisions we agreed on
- **Persistence** is Prisma over SQLite (`schema.prisma` is `provider = "sqlite"`; `app-profile.yml` corrected during Build). The story's "SQLite" was right; Prisma keeps the update logic engine-independent.
- **No auth** in this story. — matches approved requirements; endpoint is open by design.
- **No schema migration.** — `title`/`updatedAt` already exist on `tasks`; writing existing columns only.
- The four findings above are **design clarifications to settle now**, not new scope. — cheaper to pin down before code than in review.

## Changes the architecture needs
Targeted edits to `docs/EPMCDMETST-66640/architecture.md` (owned by the
Architecture Author — not edited here):
1. In **How data moves**, replace the implicit id handling with an explicit
   first step: parse `:id` to integer; non-integer → **404** before any DB call.
2. Add an **error-mapping** line: `P2025`/missing row → 404; unexpected DB
   error → 500 (generic message, no internals).
3. In **How data moves** / **Contracts**, state that the **persisted** value
   is the **trimmed** title.
4. In **Risks**, upgrade the max-length note to a concrete interim cap
   (e.g. Zod `.max(255)`), marked provisional pending product confirmation.

## Verdict
**NEEDS CHANGES → RESOLVED.** Initial verdict was NEEDS CHANGES: the design
was sound and in scope but needed four small, specific additions (id parsing,
error mapping, trim rule, interim length cap). The Architecture Author applied
all four to `architecture.md` and the human re-approved the revision, so the
design is now cleared to build.
