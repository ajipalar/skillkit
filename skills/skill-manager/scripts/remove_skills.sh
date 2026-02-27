#!/usr/bin/env bash
set -euo pipefail

# ─── skill-manager: remove skills ───────────────────────────────────────────
# Remove skills from the current project's skill directories.
#
# Usage:
#   remove_skills.sh --skills name1,name2 [--claude] [--codex]
#   remove_skills.sh --all [--claude] [--codex]
#   remove_skills.sh --list [--claude] [--codex]
# ─────────────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Defaults
SKILLS=()
ALL_SKILLS=false
TOOLS=()
LIST_ONLY=false

# ─── Colors ──────────────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
    BOLD='\033[1m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    RED='\033[0;31m'
    CYAN='\033[0;36m'
    RESET='\033[0m'
else
    BOLD='' GREEN='' YELLOW='' RED='' CYAN='' RESET=''
fi

info()  { echo -e "${CYAN}→${RESET} $*"; }
ok()    { echo -e "${GREEN}✓${RESET} $*"; }
warn()  { echo -e "${YELLOW}!${RESET} $*"; }
err()   { echo -e "${RED}✗${RESET} $*" >&2; }

# ─── Usage ───────────────────────────────────────────────────────────────────
usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Remove skills from the current project's skill directories.

Options:
  --skills <names>      Comma-separated list of skill names to remove
  --all                 Remove all project-level skills
  --claude              Target .claude/skills/ only
  --codex               Target .agents/skills/ only
  --list                List installed project skills, then exit
  -h, --help            Show this help message
EOF
}

# ─── Parse args ──────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case "$1" in
        --skills)  IFS=',' read -ra SKILLS <<< "$2"; shift 2 ;;
        --all)     ALL_SKILLS=true; shift ;;
        --claude)  TOOLS+=("claude"); shift ;;
        --codex)   TOOLS+=("codex"); shift ;;
        --list)    LIST_ONLY=true; shift ;;
        -h|--help) usage; exit 0 ;;
        *)         err "Unknown option: $1"; usage; exit 1 ;;
    esac
done

# ─── Resolve target directory ────────────────────────────────────────────────
target_dir() {
    local tool="$1"
    case "$tool" in
        claude) echo ".claude/skills" ;;
        codex)  echo ".agents/skills" ;;
    esac
}

tool_label() {
    case "$1" in
        claude) echo "Claude Code" ;;
        codex)  echo "Codex CLI" ;;
    esac
}

# ─── Auto-detect tools ──────────────────────────────────────────────────────
resolve_tools() {
    if [[ ${#TOOLS[@]} -gt 0 ]]; then
        return
    fi
    [[ -d ".claude/skills" ]] && TOOLS+=("claude")
    [[ -d ".agents/skills" ]] && TOOLS+=("codex")
    if [[ ${#TOOLS[@]} -eq 0 ]]; then
        err "No project skill directories found (.claude/skills/ or .agents/skills/)"
        exit 1
    fi
}

# ─── List installed skills ──────────────────────────────────────────────────
list_installed() {
    local dest="$1"
    if [[ ! -d "$dest" ]]; then
        return
    fi
    for skill_dir in "$dest"/*/; do
        [[ -d "$skill_dir" ]] || continue
        [[ -f "$skill_dir/SKILL.md" ]] || continue
        basename "$skill_dir"
    done | sort
}

# ─── Remove a single skill ──────────────────────────────────────────────────
remove_skill() {
    local skill_name="$1"
    local dest_dir="$2"
    local dst="$dest_dir/$skill_name"

    if [[ ! -d "$dst" ]]; then
        warn "Skill '$skill_name' not found in $dest_dir"
        return 1
    fi

    rm -rf "$dst"
    ok "Removed $skill_name from $dest_dir/"
}

# ─── Main ────────────────────────────────────────────────────────────────────
main() {
    resolve_tools

    # List mode
    if [[ "$LIST_ONLY" == true ]]; then
        for tool in "${TOOLS[@]}"; do
            local dest
            dest="$(target_dir "$tool")"
            local label
            label="$(tool_label "$tool")"

            info "Installed skills in ${BOLD}$dest${RESET} (${label}):"
            local found=false
            while IFS= read -r name; do
                [[ -z "$name" ]] && continue
                echo "  $name"
                found=true
            done < <(list_installed "$dest")
            if [[ "$found" == false ]]; then
                echo "  (none)"
            fi
            echo ""
        done
        exit 0
    fi

    # Validate inputs
    if [[ "$ALL_SKILLS" != true ]] && [[ ${#SKILLS[@]} -eq 0 ]]; then
        err "Specify --skills <name1,name2> or --all"
        exit 1
    fi

    local total_removed=0 total_notfound=0

    for tool in "${TOOLS[@]}"; do
        local dest
        dest="$(target_dir "$tool")"
        local label
        label="$(tool_label "$tool")"

        if [[ ! -d "$dest" ]]; then
            warn "No skills directory at $dest"
            continue
        fi

        # Collect skill names
        local skill_names=()
        if [[ "$ALL_SKILLS" == true ]]; then
            while IFS= read -r name; do
                [[ -z "$name" ]] && continue
                skill_names+=("$name")
            done < <(list_installed "$dest")
        else
            skill_names=("${SKILLS[@]}")
        fi

        if [[ ${#skill_names[@]} -eq 0 ]]; then
            info "No skills to remove from $dest"
            continue
        fi

        info "Removing ${#skill_names[@]} skill(s) from ${BOLD}$dest${RESET} (${label})"

        for skill_name in "${skill_names[@]}"; do
            if remove_skill "$skill_name" "$dest"; then
                ((total_removed++))
            else
                ((total_notfound++))
            fi
        done

        # Clean up empty directories
        if [[ -d "$dest" ]]; then
            find "$dest" -type d -empty -delete 2>/dev/null || true
        fi
        echo ""
    done

    info "Done: ${RED}$total_removed removed${RESET}, ${YELLOW}$total_notfound not found${RESET}"
}

main
