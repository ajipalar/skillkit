---
name: update-from-dot-agents
description: Use when syncing .agents/ content to agent framework dirs (.claude/, .opencode/, etc.) by mirroring directory structure and hardlinking files. Run after adding or updating files in .agents/ to keep all agent framework dirs in sync.
---

# Update from .agents

Syncs `.agents/` content into agent framework directories (e.g. `.claude/`, `.opencode/`) so multiple agent frameworks share the same source files without duplication.

Uses **hardlinks** (not symlinks) — hardlinks are regular files sharing the same inode, so each framework reads them natively. Edits to either copy are instantly reflected everywhere.

## What gets synced

All files and directories under `.agents/` **except** framework-specific files that each tool manages itself.

### Per-framework skip lists

Each target framework defines its own skip list. Common exclusions:

- Framework-specific config files it manages itself (e.g. `settings.json`, `settings.local.json`)
- Other frameworks' instruction files (e.g. `GEMINI.md` if syncing to `.claude/`)
- Nested agent config subdirectories inside `.agents/` (e.g. `.claude/`)
- Runtime data directories (e.g. `worktrees/`)
- Features not supported by the target (e.g. `skills/` if the framework uses a different tool format)

### Renames

Some frameworks require a different filename for the main instructions file:

- `.agents/AGENTS.md` → `.claude/CLAUDE.md` (Claude Code reads `CLAUDE.md`)
- `.agents/AGENTS.md` → `<other>/AGENTS.md` (frameworks that read `AGENTS.md` natively need no rename)

## Steps

Customize the skip lists and targets for your project, then run from the project root:

```bash
set -euo pipefail

AGENTS=".agents"

# Returns 0 (skip) if rel path is in the given skip list
should_skip() {
    local rel="$1"
    shift
    local skip_list=("$@")
    for skip in "${skip_list[@]}"; do
        if [[ "$rel" == "$skip" || "$rel" == "$skip/"* ]]; then
            return 0
        fi
    done
    return 1
}

# --- Configure targets and skip lists here ---
CLAUDE=".claude"
CLAUDE_SKIP=("GEMINI.md" "settings.json" "settings.local.json" ".claude" "worktrees")

# Add more targets as needed, e.g.:
# OPENCODE=".opencode"
# OPENCODE_SKIP=("GEMINI.md" "settings.json" "settings.local.json" ".claude" "worktrees" "skills")

# Generic sync function (no rename)
sync_to() {
    local DST="$1"
    shift
    local SKIP=("$@")

    mkdir -p "$DST"

    # Mirror directory structure
    find "$AGENTS" -mindepth 1 -type d | while IFS= read -r dir; do
        rel="${dir#$AGENTS/}"
        should_skip "$rel" "${SKIP[@]}" && continue
        mkdir -p "$DST/$rel"
    done

    # Hardlink all files
    find "$AGENTS" -type f | sort | while IFS= read -r src; do
        rel="${src#$AGENTS/}"
        should_skip "$rel" "${SKIP[@]}" && continue
        dst="$DST/$rel"
        mkdir -p "$(dirname "$dst")"
        rm -f "$dst"
        ln "$src" "$dst"
        echo "linked: $dst"
    done
}

# --- .claude/ (with AGENTS.md → CLAUDE.md rename) ---
echo "=== Syncing to $CLAUDE ==="
rm -f "$CLAUDE/CLAUDE.md"
ln "$AGENTS/AGENTS.md" "$CLAUDE/CLAUDE.md"
echo "linked: $CLAUDE/CLAUDE.md (from AGENTS.md)"
find "$AGENTS" -type f | sort | while IFS= read -r src; do
    rel="${src#$AGENTS/}"
    [[ "$rel" == "AGENTS.md" ]] && continue
    should_skip "$rel" "${CLAUDE_SKIP[@]}" && continue
    dst="$CLAUDE/$rel"
    mkdir -p "$(dirname "$dst")"
    rm -f "$dst"
    ln "$src" "$dst"
    echo "linked: $dst"
done
find "$AGENTS" -mindepth 1 -type d | while IFS= read -r dir; do
    rel="${dir#$AGENTS/}"
    should_skip "$rel" "${CLAUDE_SKIP[@]}" && continue
    mkdir -p "$CLAUDE/$rel"
done

# --- Add additional targets here ---
# echo ""
# echo "=== Syncing to $OPENCODE ==="
# sync_to "$OPENCODE" "${OPENCODE_SKIP[@]}"

echo ""
echo "Done."
```

## After running

Verify hardlinks with (hardlinks show link count > 1, not a `->` target):

```bash
# List all framework dirs you sync to
for dir in .claude; do   # add others as needed
    echo "=== $dir ==="
    find "$dir" -not -type d | while IFS= read -r f; do
        count=$(stat -f "%l" "$f")
        type=$([ -L "$f" ] && echo "SYMLINK" || echo "hardlink")
        echo "$type ($count): $f"
    done
done
```

Any `SYMLINK` entries are stale and should be replaced by re-running the sync script.

## Adding a new framework target

1. Define a skip list for the framework (exclude files it manages itself, runtime dirs, unsupported features)
2. Determine if `AGENTS.md` needs a rename (check what filename the framework reads)
3. If no rename needed: call `sync_to "$TARGET" "${TARGET_SKIP[@]}"`
4. If rename needed: use the `.claude/` block above as a template, adjusting the destination filename
