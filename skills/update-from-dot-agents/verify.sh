#!/usr/bin/env bash
# Verifies hardlinks in .claude/ and .opencode/.
# Hardlinks show link count > 1 and no -> target.
# Run from the project root.

set -euo pipefail

for dir in .claude .opencode; do
    echo "=== $dir ==="
    find "$dir" -not -type d | while IFS= read -r f; do
        count=$(stat -f "%l" "$f")
        type=$([ -L "$f" ] && echo "SYMLINK" || echo "hardlink")
        echo "$type ($count): $f"
    done
done
