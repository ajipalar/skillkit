#!/usr/bin/env bash
set -euo pipefail

# ─── skill-manager: add skills ──────────────────────────────────────────────
# Add skills from a source repository to the current project.
#
# Usage:
#   add_skills.sh --source <path> --skills name1,name2 [--claude] [--codex]
#   add_skills.sh --source <path> --all [--claude] [--codex]
#   add_skills.sh --discover [--search-path <path>]
#   add_skills.sh --list --source <path>
# ─────────────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Defaults
SOURCE=""
SKILLS=()
ALL_SKILLS=false
TOOLS=()
FORCE=false
DISCOVER=false
LIST_ONLY=false
SEARCH_PATH=""

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

Add skills from a source repository to the current project.

Options:
  --source <path>       Path to source repository (directory containing skills/)
  --skills <names>      Comma-separated list of skill names to add
  --all                 Add all skills from the source
  --claude              Target .claude/skills/ only
  --codex               Target .agents/skills/ only
  --force               Overwrite existing skills
  --discover            Find and print skill sources, then exit
  --list                List skills in the source, then exit
  --search-path <path>  Override discovery search path (default: parent of cwd)
  -h, --help            Show this help message
EOF
}

# ─── Parse args ──────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case "$1" in
        --source)      SOURCE="$2"; shift 2 ;;
        --skills)      IFS=',' read -ra SKILLS <<< "$2"; shift 2 ;;
        --all)         ALL_SKILLS=true; shift ;;
        --claude)      TOOLS+=("claude"); shift ;;
        --codex)       TOOLS+=("codex"); shift ;;
        --force)       FORCE=true; shift ;;
        --discover)    DISCOVER=true; shift ;;
        --list)        LIST_ONLY=true; shift ;;
        --search-path) SEARCH_PATH="$2"; shift 2 ;;
        -h|--help)     usage; exit 0 ;;
        *)             err "Unknown option: $1"; usage; exit 1 ;;
    esac
done

# ─── Discover skill sources ─────────────────────────────────────────────────
discover_sources() {
    local search_dir="${SEARCH_PATH:-$(dirname "$(pwd)")}"
    local sources=()

    # Search sibling directories of the current project
    for dir in "$search_dir"/*/; do
        [[ -d "$dir" ]] || continue
        local skills_subdir="${dir}skills"
        if [[ -d "$skills_subdir" ]]; then
            local count
            count=$(find "$skills_subdir" -maxdepth 2 -name "SKILL.md" -type f 2>/dev/null | wc -l | tr -d ' ')
            if [[ "$count" -gt 0 ]]; then
                sources+=("$(cd "$dir" && pwd)")
            fi
        fi
    done

    # Also check current directory
    if [[ -d "./skills" ]]; then
        local count
        count=$(find "./skills" -maxdepth 2 -name "SKILL.md" -type f 2>/dev/null | wc -l | tr -d ' ')
        if [[ "$count" -gt 0 ]]; then
            local cwd
            cwd="$(pwd)"
            # Avoid duplicates
            local already=false
            for s in "${sources[@]+"${sources[@]}"}"; do
                [[ "$s" == "$cwd" ]] && already=true
            done
            if [[ "$already" == false ]]; then
                sources+=("$cwd")
            fi
        fi
    fi

    if [[ ${#sources[@]} -eq 0 ]]; then
        return
    fi
    printf '%s\n' "${sources[@]}"
}

# ─── List skills in a source ────────────────────────────────────────────────
list_skills_in_source() {
    local source_path="$1"
    local skills_dir="$source_path/skills"

    if [[ ! -d "$skills_dir" ]]; then
        err "No skills/ directory found in $source_path"
        return 1
    fi

    while IFS= read -r skill_md; do
        local skill_dir
        skill_dir="$(dirname "$skill_md")"
        local skill_name
        skill_name="$(basename "$skill_dir")"

        # Extract description from frontmatter
        local desc=""
        desc=$(sed -n '/^---$/,/^---$/{/^---$/d; /^description:/,/^[a-z]/{ /^description:/{ s/^description:[[:space:]]*>-[[:space:]]*//; s/^description:[[:space:]]*//; p; }; /^  /p; }; }' "$skill_md" | head -3 | tr '\n' ' ' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | head -c 100)

        echo "${skill_name}|${desc}"
    done < <(find "$skills_dir" -maxdepth 2 -name "SKILL.md" -type f 2>/dev/null | sort)
}

# ─── Collect all skill names from source ─────────────────────────────────────
collect_all_skills() {
    local source_path="$1"
    local skills_dir="$source_path/skills"
    local names=()

    while IFS= read -r skill_md; do
        local skill_dir
        skill_dir="$(dirname "$skill_md")"
        names+=("$(basename "$skill_dir")")
    done < <(find "$skills_dir" -maxdepth 2 -name "SKILL.md" -type f 2>/dev/null | sort)

    printf '%s\n' "${names[@]}"
}

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
    [[ -d ".claude" ]] && TOOLS+=("claude")
    [[ -d ".agents" ]] && TOOLS+=("codex")
    # Default to claude if nothing detected
    if [[ ${#TOOLS[@]} -eq 0 ]]; then
        TOOLS=("claude")
    fi
}

# ─── Add a single skill ─────────────────────────────────────────────────────
add_skill() {
    local skill_name="$1"
    local source_skills_dir="$2"
    local dest_dir="$3"

    local src="$source_skills_dir/$skill_name"
    local dst="$dest_dir/$skill_name"

    if [[ ! -d "$src" ]]; then
        err "Skill '$skill_name' not found in $source_skills_dir"
        return 1
    fi

    if [[ ! -f "$src/SKILL.md" ]]; then
        err "Skill '$skill_name' has no SKILL.md"
        return 1
    fi

    if [[ -d "$dst" ]] && [[ "$FORCE" != true ]]; then
        warn "Skipped $skill_name (already exists, use --force to overwrite)"
        return 0
    fi

    mkdir -p "$(dirname "$dst")"
    [[ -d "$dst" ]] && rm -rf "$dst"
    cp -R "$src" "$dst"
    ok "Added $skill_name → $dest_dir/"
}

# ─── Main ────────────────────────────────────────────────────────────────────
main() {
    # Discover mode
    if [[ "$DISCOVER" == true ]]; then
        info "Searching for skill sources..."
        local sources
        sources="$(discover_sources)"
        if [[ -z "$sources" ]]; then
            warn "No skill sources found"
            echo ""
            info "Searched: ${SEARCH_PATH:-$(dirname "$(pwd)")}"
            info "A skill source is a directory containing skills/*/SKILL.md"
            exit 0
        fi
        echo ""
        while IFS= read -r src; do
            local name
            name="$(basename "$src")"
            local count
            count=$(find "$src/skills" -maxdepth 2 -name "SKILL.md" -type f 2>/dev/null | wc -l | tr -d ' ')
            echo -e "  ${BOLD}$name${RESET} ($src) — $count skill(s)"
        done <<< "$sources"
        echo ""
        exit 0
    fi

    # List mode
    if [[ "$LIST_ONLY" == true ]]; then
        if [[ -z "$SOURCE" ]]; then
            err "Specify --source <path> to list skills"
            exit 1
        fi
        info "Skills in ${BOLD}$(basename "$SOURCE")${RESET} ($SOURCE):"
        echo ""
        while IFS='|' read -r name desc; do
            echo -e "  ${BOLD}$name${RESET}"
            [[ -n "$desc" ]] && echo "    $desc"
        done < <(list_skills_in_source "$SOURCE")
        echo ""
        exit 0
    fi

    # Add mode — validate inputs
    if [[ -z "$SOURCE" ]]; then
        err "Specify --source <path> (the directory containing skills/)"
        echo ""
        info "Use --discover to find available skill sources"
        exit 1
    fi

    if [[ ! -d "$SOURCE/skills" ]]; then
        err "No skills/ directory found in $SOURCE"
        exit 1
    fi

    resolve_tools

    # Collect skills to add
    local skill_names=()
    if [[ "$ALL_SKILLS" == true ]]; then
        while IFS= read -r name; do
            skill_names+=("$name")
        done < <(collect_all_skills "$SOURCE")
    elif [[ ${#SKILLS[@]} -gt 0 ]]; then
        skill_names=("${SKILLS[@]}")
    else
        err "Specify --skills <name1,name2> or --all"
        exit 1
    fi

    if [[ ${#skill_names[@]} -eq 0 ]]; then
        warn "No skills found in $SOURCE"
        exit 0
    fi

    # Install to each target
    local total_added=0 total_skipped=0

    for tool in "${TOOLS[@]}"; do
        local dest
        dest="$(target_dir "$tool")"
        local label
        label="$(tool_label "$tool")"

        info "Adding ${#skill_names[@]} skill(s) to ${BOLD}$dest${RESET} (${label})"

        for skill_name in "${skill_names[@]}"; do
            if add_skill "$skill_name" "$SOURCE/skills" "$dest"; then
                ((total_added++))
            else
                ((total_skipped++))
            fi
        done
        echo ""
    done

    info "Done: ${GREEN}$total_added added${RESET}, ${YELLOW}$total_skipped skipped${RESET}"
}

main
