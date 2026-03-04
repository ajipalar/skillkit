---
name: chat-checkpoint
description: >-
  Write a structured session checkpoint to .chat-checkpoint.md for
  resuming work in a new chat. Use when the user says "checkpoint,"
  "save checkpoint," "save my progress," or "I need to stop soon."
  Also use proactively during long sessions when a natural breakpoint
  occurs — after completing a subtask, before switching focus areas,
  or before a risky operation. Writes a resumption file with task
  state, decisions, files modified, and next steps. Not a conversation
  summary — use conversation-summarizer for that.
---

# Chat Checkpoint

Write a structured status report to `.chat-checkpoint.md` in the
project root. The file enables a fresh session to continue the current
work without re-explaining context.

## When to Checkpoint

**User-triggered:** The user explicitly requests a checkpoint.

**Model-triggered (proactive):** Checkpoint at natural breakpoints
during long sessions:

- After completing a logical subtask
- Before switching to a different area of the codebase
- Before a risky or destructive operation
- When the session has accumulated significant context (20+ tool calls)
- When the user signals the session is ending ("I need to go,"
  "let's wrap up," "continue this later")

When checkpointing proactively, briefly inform the user:
"Writing a checkpoint to `.chat-checkpoint.md` before continuing."

Do NOT checkpoint if the session just started or no meaningful work
has been done. See "Edge Cases" below.

## Workflow

1. Gather session state
2. Assess current phase
3. Write the checkpoint file
4. Confirm to the user

### Step 1: Gather Session State

Collect from the current session:

- **Branch and working directory**: Run `git branch --show-current`
  and note the working directory.
- **Original task**: What the user initially asked for, condensed to
  1-3 sentences. If the task evolved, note both the original request
  and current understanding.
- **Git status**: Run `git status` and `git diff --stat` to capture
  current uncommitted changes.
- **Recent commits**: Run `git log --oneline -5` to capture commits
  made during this session.

### Step 2: Assess Current Phase

Classify each piece of work:

- **Done**: Completed and verified (tests pass, builds, or confirmed).
- **In Progress**: Started but not finished. Note exactly where work
  stopped and what remains.
- **Remaining**: Known work not yet started.

Organize by logical phases or subtasks, not by individual tool calls
or conversation turns.

### Step 3: Write the Checkpoint File

Write `.chat-checkpoint.md` to the project root. Overwrite any
existing file — this is a rolling snapshot, not a log.

Every section is required. If a section has no content, write "None."

```markdown
# Session Checkpoint

## Metadata
- **Date**: YYYY-MM-DD HH:MM
- **Branch**: <branch>
- **Working Directory**: <absolute path>
- **Checkpoint Reason**: <manual | subtask-complete | focus-shift | pre-risk | session-end>

## Task
<1-3 sentence description. If the task evolved, note original request
and current understanding separately.>

## Current State

### Done
- <Completed item — brief description>

### In Progress
- <Item — what started, where it stopped, what remains>

### Remaining
- <Item — what still needs to be done>

## Key Decisions
- <Decision and rationale. Include rejected alternatives if relevant.>

## Files Modified
| File | Action | Description |
|------|--------|-------------|
| path/to/file | created/edited/deleted | What changed |

## Errors and Resolutions
- **<Error>**: <How resolved. Include the fix if non-obvious.>

## Open Items
- <Blocker, unanswered question, or next step>

## Context for Resumption
<Anything a fresh session needs that doesn't fit above: env setup,
temp workarounds, commands to run, URLs consulted, gotchas.>
```

### Step 4: Confirm

After writing, inform the user:

- That the checkpoint was written and the file path
- A one-line summary of current state (e.g., "3 of 5 subtasks
  complete, paused mid-refactor of auth module")

## Quality Principles

**Optimize for resumability, not completeness.** Include only what a
fresh session needs to continue. Strip thinking-out-loud, false
starts, and dead-end exploration (unless the dead end is important
context — "tried X, doesn't work because Y").

**Be specific about stopping points.** Bad: "editing auth module."
Good: "Added JWT validation to `src/auth/middleware.ts`, still need
refresh token rotation in `rotateTokens` (line 45, currently stubbed)."

**Include runnable commands.** If resumption requires running commands
(install deps, start server, run migration), list them explicitly.

**Use project-relative paths.** Always use paths relative to the
project root so there is no ambiguity.

## Edge Cases

**No task yet (session just started):** Do not write a checkpoint.
Inform the user: "No checkpoint needed — no meaningful state yet."

**Task identified but no work done:** Write a minimal checkpoint
with only Task and Remaining populated. Note in Context for Resumption
that no work has been done.

**Task fully completed:** Write a final checkpoint. Mark everything
Done. Set In Progress and Remaining to "None." Note any follow-up
work in Context for Resumption.

**Multiple concurrent tasks:** Organize Current State by task using
subheadings: `### Task 1: <name>` with Done/In Progress/Remaining
under each.

**No git repository:** Omit Branch. Note "Not a git repository" for
git status fields. Populate all other sections normally.

**Existing .chat-checkpoint.md:** Overwrite it. The file is a rolling
snapshot. Previous context is either already incorporated in the
current session or no longer relevant.

## Recommended CLAUDE.md Snippet

Users who want proactive checkpointing should add this to their
project or global CLAUDE.md:

```markdown
## Session Checkpoints

During long sessions, proactively write checkpoints to
`.chat-checkpoint.md` at natural breakpoints (completing subtasks,
switching focus, before risky operations). Use the chat-checkpoint
skill. When resuming a session, check for `.chat-checkpoint.md`
and read it before asking the user to re-explain context.
```

This enables two complementary behaviors:

1. **Proactive writing**: Checkpoint during long sessions without
   being asked.
2. **Automatic reading**: On session start, check for and read an
   existing checkpoint to restore prior context.

## Gitignore

`.chat-checkpoint.md` is dot-prefixed (hidden on Unix). Users may
want to add it to `.gitignore` since it contains session-specific
state:

```
.chat-checkpoint.md
```

If the user wants to track checkpoints in version control (e.g., for
team handoff), they can skip this. Do not add the gitignore entry
automatically — inform the user and let them decide.
