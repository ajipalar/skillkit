#!/usr/bin/env bash
# Syncs .agents/ content into .claude/ and .opencode/ using hardlinks.
# .agents/ is the source of truth: files removed from .agents/ are also
# removed from destination directories (unless in the skip list).
# Run from the project root.

set -euo pipefail

AGENTS=".agents"
CLAUDE=".claude"
OPENCODE=".opencode"

CLAUDE_SKIP=("GEMINI.md" "settings.json" "settings.local.json" ".claude" "worktrees")
OPENCODE_SKIP=("GEMINI.md" "settings.json" "settings.local.json" ".claude" "worktrees" "skills")

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

# Remove files from DST that no longer exist in AGENTS (and aren't skip-listed).
# is_claude=1 means CLAUDE.md maps to AGENTS.md (special rename).
prune_stale() {
    local DST="$1"
    local IS_CLAUDE="$2"
    shift 2
    local SKIP=("$@")

    find "$DST" -type f | sort | while IFS= read -r dst_file; do
        rel="${dst_file#$DST/}"

        # Never prune skip-listed paths
        should_skip "$rel" "${SKIP[@]}" && continue

        # Determine the corresponding source file
        if [[ "$IS_CLAUDE" == "1" && "$rel" == "CLAUDE.md" ]]; then
            src="$AGENTS/AGENTS.md"
        else
            src="$AGENTS/$rel"
        fi

        if [[ ! -f "$src" ]]; then
            echo "removed: $dst_file (no longer in .agents/)"
            rm -f "$dst_file"
        fi
    done

    # Remove empty directories (deepest first, but not the DST root)
    find "$DST" -mindepth 1 -type d -empty | sort -r | while IFS= read -r dir; do
        echo "rmdir:   $dir"
        rmdir "$dir"
    done
}

# --- .claude/ ---
echo "=== Syncing to $CLAUDE ==="

# Mirror directory structure
find "$AGENTS" -mindepth 1 -type d | while IFS= read -r dir; do
    rel="${dir#$AGENTS/}"
    should_skip "$rel" "${CLAUDE_SKIP[@]}" && continue
    mkdir -p "$CLAUDE/$rel"
done

# Special case: AGENTS.md -> CLAUDE.md
rm -f "$CLAUDE/CLAUDE.md"
ln "$AGENTS/AGENTS.md" "$CLAUDE/CLAUDE.md"
echo "linked: $CLAUDE/CLAUDE.md (from AGENTS.md)"

# Sync everything else
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

# Remove stale files
prune_stale "$CLAUDE" "1" "${CLAUDE_SKIP[@]}"

# --- .opencode/ ---
echo ""
echo "=== Syncing to $OPENCODE ==="

mkdir -p "$OPENCODE"

# Mirror directory structure
find "$AGENTS" -mindepth 1 -type d | while IFS= read -r dir; do
    rel="${dir#$AGENTS/}"
    should_skip "$rel" "${OPENCODE_SKIP[@]}" && continue
    mkdir -p "$OPENCODE/$rel"
done

# Hardlink all files
find "$AGENTS" -type f | sort | while IFS= read -r src; do
    rel="${src#$AGENTS/}"
    should_skip "$rel" "${OPENCODE_SKIP[@]}" && continue
    dst="$OPENCODE/$rel"
    mkdir -p "$(dirname "$dst")"
    rm -f "$dst"
    ln "$src" "$dst"
    echo "linked: $dst"
done

# Remove stale files
prune_stale "$OPENCODE" "0" "${OPENCODE_SKIP[@]}"

echo ""
echo "Done."
