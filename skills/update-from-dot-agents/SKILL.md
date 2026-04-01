---
name: update-from-dot-agents
description: Sync .agents/ content to .claude/ and .opencode/ by mirroring directory structure and hardlinking files (AGENTS.md → CLAUDE.md for Claude, AGENTS.md → AGENTS.md for OpenCode). .agents/ is the source of truth — files removed from .agents/ are deleted from destination dirs. Run after adding, updating, or removing files in .agents/.
---

# Update from .agents

Syncs `.agents/` content into `.claude/` and `.opencode/` so Claude Code, OpenCode, and other agent frameworks share the same source files without duplication.

**`.agents/` is the source of truth.** Files removed from `.agents/` are deleted from destination directories (unless they're in the skip list). Files that only exist in `.claude/` or `.opencode/` and aren't skip-listed will be pruned.

Uses **hardlinks** (not symlinks) — hardlinks are regular files sharing the same inode, so each framework reads them natively. Edits to either copy are instantly reflected everywhere.

## What gets synced

All files and directories under `.agents/` **except** framework-specific files that each tool manages itself.

### `.claude/` skip list
- `GEMINI.md` — Gemini-specific config
- `settings.json`, `settings.local.json` — Claude Code manages its own settings
- `.claude/` — nested agent config subdirectory inside `.agents/`
- `worktrees/` — runtime worktree data

Special rename: `.agents/AGENTS.md` → `.claude/CLAUDE.md`

### `.opencode/` skip list
- `GEMINI.md` — Gemini-specific config
- `settings.json`, `settings.local.json` — OpenCode manages its own settings
- `.claude/` — Claude-specific nested config
- `worktrees/` — runtime worktree data
- `skills/` — skill format is Claude Code-specific; OpenCode uses a different tool/prompt format

No rename: `.agents/AGENTS.md` → `.opencode/AGENTS.md` (OpenCode reads `AGENTS.md` natively)

## Steps

Run from the project root:

```bash
bash .claude/skills/update-from-dot-agents/sync.sh
```

Source: `.agents/skills/update-from-dot-agents/sync.sh`

## After running

Verify hardlinks:

```bash
bash .claude/skills/update-from-dot-agents/verify.sh
```

Source: `.agents/skills/update-from-dot-agents/verify.sh`

Any `SYMLINK` entries are stale and should be replaced by re-running the sync script.

## OpenCode notes

- OpenCode reads `AGENTS.md` natively, so no rename is needed (unlike `.claude/CLAUDE.md`)
- OpenCode has its own `config.json` in `.opencode/` — the sync script never touches it since `settings.json` is in the skip list and `config.json` doesn't exist in `.agents/`
- Skills are excluded from `.opencode/` because OpenCode uses a different tool/system-prompt injection format; shared context files (codebase map, combat, cards, etc.) do sync since they're plain markdown
