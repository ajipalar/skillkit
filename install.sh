#!/usr/bin/env bash
set -euo pipefail

# ─── skillkit installer ─────────────────────────────────────────────────────
# Installs skillkit skills into the appropriate directories for AI coding tools.
#
# Supported tools:
#   Claude Code  — ~/.claude/skills/ (global) or .claude/skills/ (project)
#   Codex CLI    — ~/.agents/skills/ (global) or .agents/skills/ (project)
#
# Usage:
#   ./install.sh                              # Interactive
#   ./install.sh --global --claude            # Non-interactive
#   ./install.sh --project --codex            # Project-local for Codex
#   ./install.sh --global --all               # All tools, global
#   ./install.sh --uninstall --global --claude
#   ./install.sh --force --global --all       # Overwrite existing
# ─────────────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/skills"

# Defaults
SCOPE=""
TOOLS=()
UNINSTALL=false
FORCE=false

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

Install skillkit skills for AI coding tools.

Options:
  --global          Install to user-level (available in all projects)
  --project         Install to current project directory
  --claude          Target Claude Code
  --codex           Target Codex CLI
  --all             Target all supported tools
  --uninstall       Remove previously installed skills
  --force           Overwrite existing skill directories
  -h, --help        Show this help message

Run without options for interactive mode.
EOF
}

# ─── Parse args ──────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case "$1" in
        --global)    SCOPE="global"; shift ;;
        --project)   SCOPE="project"; shift ;;
        --claude)    TOOLS+=("claude"); shift ;;
        --codex)     TOOLS+=("codex"); shift ;;
        --all)       TOOLS=("claude" "codex"); shift ;;
        --uninstall) UNINSTALL=true; shift ;;
        --force)     FORCE=true; shift ;;
        -h|--help)   usage; exit 0 ;;
        *)           err "Unknown option: $1"; usage; exit 1 ;;
    esac
done

# ─── Discover skills ────────────────────────────────────────────────────────
discover_skills() {
    local skills=()
    while IFS= read -r skill_md; do
        # Get path relative to SKILLS_DIR, e.g. skill-creator/SKILL.md
        local rel="${skill_md#"$SKILLS_DIR"/}"
        # Get the skill directory name, e.g. skill-creator
        local skill_rel_dir
        skill_rel_dir="$(dirname "$rel")"
        skills+=("$skill_rel_dir")
    done < <(find "$SKILLS_DIR" -name "SKILL.md" -type f 2>/dev/null | sort)
    echo "${skills[@]}"
}

# ─── Resolve target directory ────────────────────────────────────────────────
target_dir() {
    local tool="$1" scope="$2"
    case "$tool" in
        claude)
            if [[ "$scope" == "global" ]]; then
                echo "$HOME/.claude/skills"
            else
                echo ".claude/skills"
            fi
            ;;
        codex)
            if [[ "$scope" == "global" ]]; then
                echo "$HOME/.agents/skills"
            else
                echo ".agents/skills"
            fi
            ;;
    esac
}

tool_label() {
    case "$1" in
        claude) echo "Claude Code" ;;
        codex)  echo "Codex CLI" ;;
    esac
}

# ─── Install ─────────────────────────────────────────────────────────────────
install_skills() {
    local tool="$1" scope="$2"
    local dest
    dest="$(target_dir "$tool" "$scope")"
    local label
    label="$(tool_label "$tool")"
    local installed=0 skipped=0

    read -ra skill_list <<< "$(discover_skills)"

    if [[ ${#skill_list[@]} -eq 0 ]]; then
        warn "No skills found in $SKILLS_DIR"
        return
    fi

    info "Installing ${#skill_list[@]} skill(s) to ${BOLD}$dest${RESET} for ${BOLD}$label${RESET}"

    for skill_rel in "${skill_list[@]}"; do
        local src="$SKILLS_DIR/$skill_rel"
        local dst="$dest/$skill_rel"

        if [[ -d "$dst" ]] && [[ "$FORCE" != true ]]; then
            warn "Skipped $skill_rel (already exists, use --force to overwrite)"
            ((skipped++))
            continue
        fi

        mkdir -p "$(dirname "$dst")"
        if [[ -d "$dst" ]]; then
            rm -rf "$dst"
        fi
        cp -R "$src" "$dst"
        ok "Installed $skill_rel"
        ((installed++))
    done

    echo ""
    info "Done: ${GREEN}$installed installed${RESET}, ${YELLOW}$skipped skipped${RESET}"
}

# ─── Uninstall ───────────────────────────────────────────────────────────────
uninstall_skills() {
    local tool="$1" scope="$2"
    local dest
    dest="$(target_dir "$tool" "$scope")"
    local label
    label="$(tool_label "$tool")"
    local removed=0

    read -ra skill_list <<< "$(discover_skills)"

    if [[ ${#skill_list[@]} -eq 0 ]]; then
        warn "No skills found in $SKILLS_DIR"
        return
    fi

    info "Uninstalling skills from ${BOLD}$dest${RESET} for ${BOLD}$label${RESET}"

    for skill_rel in "${skill_list[@]}"; do
        local dst="$dest/$skill_rel"
        if [[ -d "$dst" ]]; then
            rm -rf "$dst"
            ok "Removed $skill_rel"
            ((removed++))
        fi
    done

    # Clean up empty category directories
    if [[ -d "$dest" ]]; then
        find "$dest" -type d -empty -delete 2>/dev/null || true
    fi

    echo ""
    info "Done: ${RED}$removed removed${RESET}"
}

# ─── Interactive prompts ─────────────────────────────────────────────────────
prompt_scope() {
    echo ""
    echo -e "${BOLD}Where should skills be installed?${RESET}"
    echo "  1) Global  — available in all projects"
    echo "  2) Project — current directory only"
    echo ""
    while true; do
        read -rp "Choice [1/2]: " choice
        case "$choice" in
            1) SCOPE="global"; return ;;
            2) SCOPE="project"; return ;;
            *) echo "Please enter 1 or 2." ;;
        esac
    done
}

prompt_tools() {
    echo ""
    echo -e "${BOLD}Which tool(s) to install for?${RESET}"
    echo "  1) Claude Code"
    echo "  2) Codex CLI"
    echo "  3) All of the above"
    echo ""
    while true; do
        read -rp "Choice [1/2/3]: " choice
        case "$choice" in
            1) TOOLS=("claude"); return ;;
            2) TOOLS=("codex"); return ;;
            3) TOOLS=("claude" "codex"); return ;;
            *) echo "Please enter 1, 2, or 3." ;;
        esac
    done
}

# ─── Main ────────────────────────────────────────────────────────────────────
main() {
    echo -e "${BOLD}skillkit installer${RESET}"
    echo ""

    # Show available skills
    read -ra skill_list <<< "$(discover_skills)"
    if [[ ${#skill_list[@]} -eq 0 ]]; then
        err "No skills found in $SKILLS_DIR"
        exit 1
    fi
    info "Found ${#skill_list[@]} skill(s): ${skill_list[*]}"

    # Interactive prompts if needed
    [[ -z "$SCOPE" ]] && prompt_scope
    [[ ${#TOOLS[@]} -eq 0 ]] && prompt_tools

    echo ""

    # Execute
    for tool in "${TOOLS[@]}"; do
        if [[ "$UNINSTALL" == true ]]; then
            uninstall_skills "$tool" "$SCOPE"
        else
            install_skills "$tool" "$SCOPE"
        fi
        echo ""
    done
}

main
