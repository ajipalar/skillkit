# Settings and Permissions Reference

## Table of Contents

- [Settings Files](#settings-files)
- [CLAUDE.md Files](#claudemd-files)
- [Rules Directory](#rules-directory)
- [.claude Directory Structure](#claude-directory-structure)
- [Permission System](#permission-system)
- [Permission Patterns](#permission-patterns)
- [Environment Variables](#environment-variables)
- [Model Selection](#model-selection)

## Settings Files

### Locations and Precedence

| Priority | File | Scope |
|----------|------|-------|
| 1 (highest) | Enterprise/managed policies | Organization-wide |
| 2 | `.claude/settings.local.json` | Personal project (gitignored) |
| 3 | `.claude/settings.json` | Project (committed to repo) |
| 4 (lowest) | `~/.claude/settings.json` | User global |

Settings merge across scopes. More specific scopes override less specific
ones for the same key.

### settings.json Structure

```json
{
  "permissions": {
    "allow": [],
    "deny": []
  },
  "hooks": {},
  "env": {}
}
```

### Common Settings

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Glob",
      "Grep",
      "Bash(npm test)",
      "Bash(npm run lint)",
      "Bash(npm run build)"
    ],
    "deny": [
      "Bash(curl *)",
      "Read(.env)",
      "Read(secrets/**)"
    ]
  }
}
```

## CLAUDE.md Files

CLAUDE.md files provide project-specific instructions that Claude loads
automatically. They are the primary way to customize Claude's behavior
for a project.

### Loading Order

| Order | File | Notes |
|-------|------|-------|
| 1 | `~/.claude/CLAUDE.md` | Global, always loaded for all projects |
| 2 | `CLAUDE.md` | Repo root, loaded automatically |
| 3 | `CLAUDE.local.md` | Repo root, gitignored, personal overrides |
| 4 | `.claude/CLAUDE.md` | Project config directory |

All files at levels 1-4 are loaded at session start.

### Directory-Level CLAUDE.md

```
src/
├── CLAUDE.md         ← loaded only when Claude works in src/
├── components/
│   └── CLAUDE.md     ← loaded only when Claude works in src/components/
```

Subdirectory CLAUDE.md files are loaded **on demand** when Claude reads
or edits files in that subtree. Useful for monorepos with different
conventions per package.

### What to Put in CLAUDE.md

- Build, test, and lint commands
- Coding conventions and style rules
- Project architecture overview
- File organization patterns
- Common workflows
- Tool preferences (e.g., "always use bun instead of npm")

### What NOT to Put in CLAUDE.md

- Secrets, API keys, or credentials
- Large amounts of boilerplate
- Content that changes frequently
- Instructions that only apply to one conversation

## Rules Directory

All markdown files in `.claude/rules/` are automatically loaded at
session start, like additional CLAUDE.md files:

```
.claude/rules/
├── code-style.md
├── testing.md
├── security.md
└── frontend/
    ├── react.md
    └── styles.md
```

Rules files are loaded regardless of which directory Claude works in.
Use for project-wide standards. Nested subdirectories are supported.

## .claude Directory Structure

```
.claude/
├── CLAUDE.md               Project instructions
├── settings.json           Project settings (committed)
├── settings.local.json     Personal settings (gitignored)
├── mcp.json                MCP server configuration
├── skills/                 Project-level skills
│   └── <skill-name>/
│       └── SKILL.md
├── agents/                 Custom subagent definitions
│   └── <agent-name>.md
├── commands/               Custom slash commands
│   └── <command-name>.md
├── rules/                  Auto-loaded rule files
│   └── *.md
└── worktrees/              Temporary git worktrees
```

## Permission System

### Permission Arrays

| Array | Behavior | User Experience |
|-------|----------|-----------------|
| `allow` | Tool runs without prompting | Seamless |
| `deny` | Tool blocked entirely | Error message shown |
| (neither) | User prompted for approval | Interactive confirmation |

### Evaluation Order

1. **Deny rules checked first** — if any deny rule matches, the tool is blocked
2. **Allow rules checked next** — if any allow rule matches, the tool runs
3. **Default** — user is prompted for approval

First match wins within each category.

### Adding Permissions Interactively

When Claude asks for permission, you can:
- **Allow once** — permit this specific invocation
- **Allow always** — add to the project's allow list
- **Deny** — block this invocation

"Allow always" writes the permission to `.claude/settings.local.json`.

## Permission Patterns

### Basic Patterns

```json
"allow": [
  "Read",              // Allow all Read operations
  "Write",             // Allow all Write operations
  "Edit",              // Allow all Edit operations
  "Bash"               // Allow all Bash commands (use cautiously)
]
```

### Bash Command Patterns

```json
"allow": [
  "Bash(npm test)",           // Exact command
  "Bash(npm run *)",          // Wildcard: any npm run script
  "Bash(git status)",         // Specific git command
  "Bash(python -m pytest *)"  // Pytest with any args
],
"deny": [
  "Bash(rm -rf *)",           // Block recursive delete
  "Bash(curl *)",             // Block curl commands
  "Bash(git push *)"          // Block pushing (require confirmation)
]
```

### File Path Patterns

```json
"deny": [
  "Read(.env)",               // Block reading .env
  "Read(.env.*)",             // Block all .env variants
  "Read(secrets/**)",         // Block secrets directory
  "Write(*.lock)"             // Block editing lock files
]
```

### MCP Tool Patterns

```json
"allow": [
  "mcp__filesystem__read_file",      // Specific MCP tool
  "mcp__filesystem__*",              // All tools from server
  "mcp__*__list_*"                   // list_ tools from any server
]
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `ANTHROPIC_API_KEY` | API key for direct Anthropic access |
| `CLAUDE_CODE_MAX_TURNS` | Max agentic turns in non-interactive mode |
| `ANTHROPIC_MODEL` | Override default model |
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `DISABLE_PROMPT_CACHING` | Disable prompt caching |
| `MCP_TIMEOUT` | MCP server connection timeout (ms) |

## Model Selection

### Available Models

| Model | ID | Use Case |
|-------|-----|----------|
| Opus 4.6 | `claude-opus-4-6` | Most capable, complex tasks |
| Sonnet 4.6 | `claude-sonnet-4-6` | Balanced speed/capability |
| Haiku 4.5 | `claude-haiku-4-5-20251001` | Fast, simple tasks |

### Switching Models

- Interactive: `/model` command
- Environment: `ANTHROPIC_MODEL=claude-sonnet-4-6`
- Per-subagent: `model` parameter in Task tool
- Fast mode: `/fast` toggles faster output (same model)
