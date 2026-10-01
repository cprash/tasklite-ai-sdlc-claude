---
name: workspace-writer
description: Writes or updates a file in the repository, safely — local filesystem only, never .env, never outside the repo root. Used by any agent that puts a file on disk.
---

# Skill — workspace-writer

**What it does:** writes or updates a file in the repository, safely.

**Who uses it:** the documentation authors, the Build agent, the Review,
Verify, and Publish agents — anything that puts a file on disk.

## How it connects
Local filesystem only. No network, no credentials.

## Inputs
- `path` — relative to the repo root
- `body` — the file content
- `allow_overwrite` — default `true`

## Before it runs
- Reject a `path` that begins with `/` or contains `..`.
- Refuse to write `.env`, ever.
- Reject empty `body`.

## Steps
1. Run the checks above.
2. Resolve the full path under the repo root.
3. Create any missing parent folders.
4. If the file exists and `allow_overwrite` is false, skip and say so.
5. Write the content.
6. Report the path and byte count.

## What comes back
`{ path, bytes, result: created|updated }`

## When it goes wrong
- Denied by the OS → "Can't write to {{path}} (permission denied)."
- Path escapes the repo → "Refusing to write outside the repo root."
- Target is `.env` → "`.env` is off-limits; use `.env.example`."
- Empty body → "Nothing to write."
