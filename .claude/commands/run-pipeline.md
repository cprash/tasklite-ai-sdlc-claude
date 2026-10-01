---
description: One-command start for the Automated Documentation Sync SDLC on an EPMCDMETST story. Hands control to the Pipeline Conductor.
argument-hint: "[EPMCDMETST-<number>] (or leave blank to browse the backlog)"
---

# Run the Pipeline

Kick off the full capstone lifecycle — Requirements → Architecture →
Design Review → Implementation Planning → Implementation → Review →
Verify → PR — for a single story, then sync a summary to Confluence.

## Before you start
Make sure `.claude/config/app-profile.yml` is filled in for this repo
(stack, data model, run commands, GitHub repo, Confluence space). The
pipeline reads every app fact from there and never scans your source.

## How to use
- Pass a story id like `EPMCDMETST-42`, **or** leave it blank to
  browse the backlog first.
- The story can also live in a Confluence page or a Word doc — point
  Intake at it.

## What runs
1. Launch the **Pipeline Conductor** (`.claude/agents/conductor.md`); it
   drives every stage.
2. **Intake** reads the story (Jira / Confluence / Word).
3. **Doc Sync** runs the four authors — requirements, architecture,
   design review, implementation plan — each with a chat approval,
   producing `docs/<STORY_ID>/`.
4. **Build → Review → Verify → Release → Publish** finish the job: code,
   seven-area review, test + doc verification, the pull request with a
   changelog, and the Confluence summary.

Nothing is committed, posted, or published without your explicit okay.

Launch the `conductor` agent now and give it this story: **$ARGUMENTS**
(if that is blank, start Intake in backlog-browse mode).
