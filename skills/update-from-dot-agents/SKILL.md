---
name: update-from-dot-agents
description: Use when a project uses .agents/ as the canonical source for multi-framework agent config and .claude/ needs to be synced to reflect those changes.
---

# Update from .agents

Syncs `.agents/` content into `.claude/` so Claude Code and other agent frameworks (Gemini, Codex, etc.) share the same source files without duplication.

## Context

Some projects use `.agents/` as a single canonical source for agent configuration, then mirror it into framework-specific directories (`.claude/`, `.gemini/`, etc.) using hard links. This avoids maintaining duplicate copies while ensuring each framework can read the files natively (Claude Code cannot follow symlinks).

`AGENTS.md` is the framework-agnostic instruction file — it maps to `CLAUDE.md` for Claude Code.

## What gets synced

All files and directories under `.agents/` **except** items that are framework-specific or runtime-only. The default skip list covers common cases — adapt it for your project:

| Skipped | Reason |
|---|---|
| `GEMINI.md` | Gemini-specific config; Claude Code doesn't use it |
| `settings.json`, `settings.local.json` | Each framework manages its own settings |
| Any nested framework dirs (e.g. `.claude/`) | Prevents circular linking if present inside `.agents/` |
| Runtime directories (e.g. `worktrees/`) | Not configuration; generated at runtime |

Special rename: `.agents/AGENTS.md` → `.claude/CLAUDE.md`

## Steps

Run the following bash script from the project root. Update `skip_list` to match your project's structure:

```bash
set -euo pipefail

AGENTS=".agents"
CLAUDE=".claude"

should_skip() {
    local rel="$1"
    # Adapt this list to your project — remove entries that don't apply,
    # add any runtime or framework-specific paths you want to exclude.
    local skip_list=("GEMINI.md" "settings.json" "settings.local.json")
    for skip in "${skip_list[@]}"; do
        if [[ "$rel" == "$skip" || "$rel" == "$skip/"* ]]; then
            return 0
        fi
    done
    return 1
}

# 1. Mirror directory structure
find "$AGENTS" -mindepth 1 -type d | while IFS= read -r dir; do
    rel="${dir#$AGENTS/}"
    should_skip "$rel" && continue
    mkdir -p "$CLAUDE/$rel"
    echo "  dir: $CLAUDE/$rel"
done

# 2. Special case: AGENTS.md -> CLAUDE.md (hard link with rename)
rm -f "$CLAUDE/CLAUDE.md"
ln "$AGENTS/AGENTS.md" "$CLAUDE/CLAUDE.md"
echo "hardlinked: $AGENTS/AGENTS.md -> $CLAUDE/CLAUDE.md"

# 3. Hard-link all other files
find "$AGENTS" -type f | sort | while IFS= read -r src; do
    rel="${src#$AGENTS/}"
    [[ "$rel" == "AGENTS.md" ]] && continue
    should_skip "$rel" && continue

    dst="$CLAUDE/$rel"
    dst_dir="$(dirname "$dst")"

    mkdir -p "$dst_dir"
    rm -f "$dst"
    ln "$src" "$dst"
    echo "hardlinked: $src -> $dst"
done

echo "Done."
```

## After running

Verify hard links by checking inode matches between source and destination:
```bash
find .agents -type f | sort | while IFS= read -r src; do
    rel="${src#.agents/}"
    [[ "$rel" == "AGENTS.md" ]] && dst=".claude/CLAUDE.md" || dst=".claude/$rel"
    [ -f "$dst" ] || continue
    src_inode=$(stat -f%i "$src" 2>/dev/null || stat -c%i "$src")
    dst_inode=$(stat -f%i "$dst" 2>/dev/null || stat -c%i "$dst")
    match=$([[ "$src_inode" == "$dst_inode" ]] && echo "✓" || echo "✗ MISMATCH")
    echo "$match $src <-> $dst"
done
```

**Important:** Hard links share the same file on disk — edits to either path update both. Re-run this script after adding new files to `.agents/`.
