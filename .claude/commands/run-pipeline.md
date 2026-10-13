---
description: One-command start for the Automated Documentation Sync SDLC on an EPMCDMETST story. Hands control to the Pipeline Conductor.
argument-hint: "[EPMCDMETST-<number>] (or leave blank to browse the backlog)"
---

Launch the `conductor` agent (`.claude/agents/conductor.md`) and give it this story: **$ARGUMENTS**

If that is blank, start Intake in backlog-browse mode. The story may also be a Confluence page or Word doc.
