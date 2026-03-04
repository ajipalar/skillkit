#!/usr/bin/env bash
set -euo pipefail

# ─── claude-code-guide: fetch documentation from trusted sources ─────────
#
# Fetches latest Claude Code documentation and stores it in cache/ for
# review. Reference files in references/ should be updated manually from
# cached content to ensure quality and accuracy.
#
# Usage:
#   fetch_docs.sh                    Fetch all sources
#   fetch_docs.sh --source <name>    Fetch a specific source
#   fetch_docs.sh --list             List available sources
#   fetch_docs.sh --cache-dir <dir>  Custom cache directory
#   fetch_docs.sh --help             Show this help
#
# Exit codes:
#   0  All fetches succeeded
#   1  Some fetches failed
#   2  Usage error or missing tools
# ─────────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
CACHE_DIR="${SKILL_DIR}/cache"

# ─── Trusted Source Manifest ─────────────────────────────────────────────
# Format: NAME|URL|DESCRIPTION
#
# Only official Anthropic sources, the MCP specification, and well-known
# trusted blogs/community resources. Each URL should return useful content
# when fetched with curl.

SOURCES=(
  "cc-overview|https://docs.anthropic.com/en/docs/claude-code/overview|Claude Code overview and capabilities"
  "cc-cli|https://docs.anthropic.com/en/docs/claude-code/cli-usage|CLI usage and flags"
  "cc-hooks|https://docs.anthropic.com/en/docs/claude-code/hooks|Hooks documentation"
  "cc-mcp|https://docs.anthropic.com/en/docs/claude-code/mcp|MCP configuration for Claude Code"
  "cc-settings|https://docs.anthropic.com/en/docs/claude-code/settings|Settings and configuration"
  "cc-permissions|https://docs.anthropic.com/en/docs/claude-code/permissions|Permissions reference"
  "cc-memory|https://docs.anthropic.com/en/docs/claude-code/memory|CLAUDE.md and memory files"
  "cc-sub-agents|https://docs.anthropic.com/en/docs/claude-code/sub-agents|Sub-agents documentation"
  "cc-skills|https://docs.anthropic.com/en/docs/claude-code/skills|Skills and slash commands"
  "cc-github|https://raw.githubusercontent.com/anthropics/claude-code/main/README.md|Claude Code GitHub README"
  "mcp-spec|https://modelcontextprotocol.io/introduction|MCP specification overview"
  "mcp-concepts|https://modelcontextprotocol.io/docs/concepts/architecture|MCP architecture concepts"
  "willison-cc|https://simonwillison.net/tags/claude-code/|Simon Willison on Claude Code"
  "eesel-hooks|https://www.eesel.ai/blog/hooks-in-claude-code|eesel.ai hooks guide"
  "eesel-settings|https://www.eesel.ai/blog/settings-json-claude-code|eesel.ai settings guide"
)

# ─── Helpers ─────────────────────────────────────────────────────────────

usage() {
  sed -n '/^# Usage:/,/^# Exit/p' "$0" | head -n -1 | sed 's/^# //'
}

list_sources() {
  printf "\n%-18s  %-55s  %s\n" "NAME" "URL" "DESCRIPTION"
  printf "%-18s  %-55s  %s\n" "----" "---" "-----------"
  for entry in "${SOURCES[@]}"; do
    IFS='|' read -r name url desc <<< "$entry"
    printf "%-18s  %-55s  %s\n" "$name" "$url" "$desc"
  done
  echo ""
}

check_tools() {
  if ! command -v curl &>/dev/null; then
    echo "Error: curl is required but not found." >&2
    exit 2
  fi
}

has_pandoc() {
  command -v pandoc &>/dev/null
}

has_lynx() {
  command -v lynx &>/dev/null
}

# Convert HTML to markdown using the best available tool
html_to_text() {
  if has_pandoc; then
    pandoc -f html -t markdown --wrap=none 2>/dev/null
  elif has_lynx; then
    lynx -stdin -dump -nolist -width=120 2>/dev/null
  else
    # Fallback: strip HTML tags with sed (crude but functional)
    sed -e 's/<[^>]*>//g' -e '/^[[:space:]]*$/d' 2>/dev/null
  fi
}

# Fetch a single source and save to cache
fetch_source() {
  local name="$1"
  local url="$2"
  local desc="$3"
  local output="${CACHE_DIR}/${name}.md"
  local timestamp
  timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

  printf "  Fetching %-18s ... " "$name"

  # Fetch with a reasonable timeout and user agent
  local http_code
  local tmp_file
  tmp_file="$(mktemp)"

  http_code=$(curl -sL -w "%{http_code}" \
    --max-time 30 \
    --user-agent "claude-code-guide-fetch/1.0" \
    -o "$tmp_file" \
    "$url" 2>/dev/null) || true

  if [[ "$http_code" -ge 200 && "$http_code" -lt 400 ]]; then
    # Determine content type and convert if needed
    local content_type
    content_type=$(file -b --mime-type "$tmp_file" 2>/dev/null || echo "unknown")

    {
      echo "<!-- Source: ${name} -->"
      echo "<!-- URL: ${url} -->"
      echo "<!-- Fetched: ${timestamp} -->"
      echo "<!-- Description: ${desc} -->"
      echo ""

      if [[ "$url" == *.md ]] || [[ "$content_type" == "text/plain" && "$url" == *README* ]]; then
        # Already markdown
        cat "$tmp_file"
      elif [[ "$content_type" == text/html* ]] || head -c 200 "$tmp_file" | grep -qi '<html'; then
        # HTML — convert to text
        cat "$tmp_file" | html_to_text
      else
        # Unknown format — store as-is
        cat "$tmp_file"
      fi
    } > "$output"

    local lines
    lines=$(wc -l < "$output" | tr -d ' ')
    printf "OK (%s lines, HTTP %s)\n" "$lines" "$http_code"
    rm -f "$tmp_file"
    return 0
  else
    printf "FAILED (HTTP %s)\n" "$http_code"
    rm -f "$tmp_file"
    return 1
  fi
}

# ─── Main ────────────────────────────────────────────────────────────────

main() {
  local target_source=""
  local show_list=false

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --source)
        if [[ -z "${2:-}" ]]; then
          echo "Error: --source requires a name argument" >&2
          exit 2
        fi
        target_source="$2"
        shift 2
        ;;
      --list)
        show_list=true
        shift
        ;;
      --cache-dir)
        if [[ -z "${2:-}" ]]; then
          echo "Error: --cache-dir requires a path argument" >&2
          exit 2
        fi
        CACHE_DIR="$2"
        shift 2
        ;;
      --help|-h)
        usage
        exit 0
        ;;
      *)
        echo "Error: unknown argument '$1'" >&2
        usage >&2
        exit 2
        ;;
    esac
  done

  # Handle --list
  if $show_list; then
    echo "Available sources:"
    list_sources
    echo "Cache directory: ${CACHE_DIR}"
    if has_pandoc; then
      echo "HTML converter: pandoc (best quality)"
    elif has_lynx; then
      echo "HTML converter: lynx (good quality)"
    else
      echo "HTML converter: sed fallback (basic — install pandoc for better results)"
    fi
    exit 0
  fi

  check_tools
  mkdir -p "$CACHE_DIR"

  echo "claude-code-guide: fetching documentation"
  echo "Cache directory: ${CACHE_DIR}"
  echo ""

  local total=0
  local succeeded=0
  local failed=0

  for entry in "${SOURCES[@]}"; do
    IFS='|' read -r name url desc <<< "$entry"

    # If --source specified, skip non-matching entries
    if [[ -n "$target_source" && "$name" != "$target_source" ]]; then
      continue
    fi

    total=$((total + 1))
    if fetch_source "$name" "$url" "$desc"; then
      succeeded=$((succeeded + 1))
    else
      failed=$((failed + 1))
    fi
  done

  # Handle --source with no match
  if [[ -n "$target_source" && "$total" -eq 0 ]]; then
    echo "Error: source '${target_source}' not found in manifest." >&2
    echo "Use --list to see available sources." >&2
    exit 2
  fi

  echo ""
  echo "Results: ${succeeded}/${total} succeeded, ${failed} failed"
  echo "Cache: ${CACHE_DIR}/"

  if [[ "$failed" -gt 0 ]]; then
    exit 1
  fi
  exit 0
}

main "$@"
