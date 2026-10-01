---
name: Lifecycle Hooks
description: The begin/finish steps every agent and sub-agent performs around its work. Referenced by number from each agent's Hooks section. These are followed as explicit steps — there is no background runner.
---

# Lifecycle Hooks

Two hooks wrap every stage: one before it starts, one after it
finishes. Agents point here rather than restating them. They are
**instructions the agent follows**, not an automated process — nothing
in `settings.json` runs them; the agent performs them as explicit steps.

## Hook: before-work

Run this before touching anything in the stage's own step list.

1. Re-read the stage's own `Inputs` / `Trigger`.
2. Confirm `.claude/config/app-profile.yml` exists and the fields this
   stage relies on are populated. If a needed field is blank, stop and
   ask the human to fill it — do not improvise a value.
3. For every input file the stage names, check it is present on disk.
4. If a required input is missing, halt before step 1 of the stage: tell
   the human which file is absent, which stage was meant to create it,
   and offer to run that stage first or abort.
5. If the stage has no file inputs (e.g. Intake in browse mode, or a
   hand-off that arrives in chat), skip the disk check.

## Hook: after-work

Fires **once per top-level agent run** — once per `.claude/agents/*.md`
that the Agent tool launched, not once per internal step. An agent
spanning several internal steps (Doc Sync's four authors, Review's two
passes) collects one log line per step **in memory**, then writes them
**in a single `workspace-writer` call** just before handing control
back.

1. Work out the story id (`EPMCDMETST-<number>`).
2. If `docs/{{STORY_ID}}/trace-log.md` does not exist, start it with:
   ```markdown
   # Trace Log — {{STORY_ID}}

   | When | Stage | Produced | Checkpoint |
   |---|---|---|---|
   ```
3. Append every accumulated row in one write. Each row is a real
   one-line markdown table row, opening and closing with `|`:
   `| <ISO time> | <stage name> | <file path or action> | <APPROVED / REJECTED / N/A> |`
4. Never rewrite rows other stages already added.
5. In the same write, overwrite `docs/{{STORY_ID}}/handoff.md` with the
   snapshot below. Unlike the append-only trace log, the handoff file is
   replaced each time so it always shows "where we are right now".

The result: a readable audit trail per story plus a resume point, with
only one file write per agent.

## The handoff snapshot (for resuming after a crash)

If a session dies mid-run — token limit, dropped connection, window
closed — none of the "how to continue" should be trapped in that dead
session. Every finished, approved stage leaves a self-contained block
the human pastes into a fresh session to carry on.

Overwrite `docs/{{STORY_ID}}/handoff.md` with:

```markdown
# Handoff — {{STORY_ID}}

> Paste this into a new Claude Code session and launch the agent named
> under "Do next".

## Story
{{STORY_ID}}: <story title>

## Last finished
<stage name> — <ISO time> — Checkpoint: <APPROVED / N/A>

## Produced so far
- <file path or PR link>   (one line per finished stage, full list)

## Do next
Launch: <next agent's file name>
Give it: <exactly what that agent lists under Inputs/Trigger>
```

A stage that fails partway (before reaching after-work) leaves the
previous handoff untouched, so the before-work hook of the next attempt
always finds a valid resume point for everything that already passed a
checkpoint.

## Non-logging cases
- Intake in browse mode (no story chosen yet): skip both hooks until a
  story id is locked in.
- A stage with no human checkpoint still logs in after-work, just with
  Checkpoint `N/A`.
