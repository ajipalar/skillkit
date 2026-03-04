---
name: claude-code-guide
description: >-
  Reference guide for Claude Code CLI features, configuration, and advanced
  usage patterns. Use when anyone asks how Claude Code works, what it can do,
  or how to configure it. Covers: built-in tools (Read, Write, Edit, Glob,
  Grep, Bash, Task, TodoWrite, WebFetch, WebSearch), hooks (PreToolUse,
  PostToolUse, Stop, Notification), agents and subagents (Task tool, custom
  agents, parallel execution), skills (SKILL.md format, slash commands),
  MCP servers (mcp.json, stdio/SSE), settings and permissions (settings.json,
  CLAUDE.md, allowedTools, denyTools), and advanced patterns (Ralph Wiggum
  loop, worktrees, phased execution, multi-agent workflows, headless/CI mode).
  Triggers on: "how do hooks work," "what tools does Claude have," "set up
  MCP," "how do subagents work," "create a skill," "Ralph Wiggum loop,"
  "configure permissions," or any question about Claude Code architecture,
  tools, or extensibility. NOT for prompt engineering, human-AI interaction
  patterns, or Claude API/SDK usage.
---

# Claude Code Guide

Reference for Claude Code CLI features, tools, configuration, and advanced
patterns. Covers the CLI tool itself — not the Claude API/SDK for application
development, and not general human-AI interaction guidance.

## Scope

**Covers:**
- Built-in tools and when to use each
- Hooks (lifecycle events, configuration, matchers)
- Agents and subagents (Task tool, parallel execution, custom agents)
- Skills and slash commands (SKILL.md format, discovery, directories)
- Model Context Protocol (MCP servers, configuration, transports)
- Settings, permissions, and CLAUDE.md files
- Advanced patterns (Ralph Wiggum loop, worktrees, phased execution)

**Does NOT cover:**
- General prompt engineering or conversation techniques
- Claude API/SDK usage from application code
- Human-AI interaction patterns and anti-patterns
- AI safety, ethics, or alignment topics

## Workflow

1. Identify the user's question or topic
2. Route to the appropriate reference file
3. Read the reference file
4. Provide the answer using reference content plus your own knowledge

### Step 1: Identify the Topic

| Topic | Trigger Keywords |
|-------|-----------------|
| Tools | Read, Write, Edit, Glob, Grep, Bash, Task, TodoWrite, WebFetch, WebSearch, "built-in tools," "what tools," "which tool should I use" |
| Hooks | hook, PreToolUse, PostToolUse, Notification, Stop, "lifecycle event," "before tool runs," "after tool runs," matcher, "event handler" |
| Agents | subagent, Task tool, "parallel execution," "dispatch agent," "custom agent," "multi-agent," "background agent," "isolated context" |
| Skills | SKILL.md, slash command, "skill format," "skill directory," frontmatter, "create a skill," skill discovery, "/command" |
| MCP | MCP, "model context protocol," "MCP server," "tool server," "mcp.json," stdio, SSE, "external tools" |
| Settings | settings.json, permissions, CLAUDE.md, ".claude directory," allowedTools, denyTools, "permission mode," "configure Claude" |
| Advanced | "Ralph Wiggum," worktree, "phased execution," "multi-pass," "context window," "agentic loop," headless, CI mode, "non-interactive" |

If the question spans multiple topics, read the most relevant reference
first, then supplement from others as needed.

### Step 2: Route to Reference

- **Tools** → Read `references/tools.md`
- **Hooks** → Read `references/hooks.md`
- **Agents** → Read `references/agents-and-subagents.md`
- **Skills** → Read `references/skills-and-commands.md`
- **MCP** → Read `references/mcp.md`
- **Settings** → Read `references/settings-and-permissions.md`
- **Advanced** → Read `references/advanced-patterns.md`

### Steps 3-4: Read and Respond

Read the identified reference file(s), then synthesize a focused answer.
Prefer concrete examples and code snippets over abstract explanations.
Supplement reference content with your own training knowledge when the
reference doesn't fully address the question.

## Quick Reference

These tables cover the most frequently asked questions. For details
beyond what's here, route to the appropriate reference file.

### Tool Selection

| Need | Tool | Notes |
|------|------|-------|
| Read a file | Read | Supports offset/limit, images, PDFs, notebooks |
| Search file contents | Grep | Built on ripgrep; use pattern + glob/type filters |
| Find files by name | Glob | Supports `**/*.ext` patterns |
| Edit existing file | Edit | Exact old_string/new_string replacement |
| Create/overwrite file | Write | Overwrites entire file |
| Run a shell command | Bash | 2min default timeout, max 10min |
| Delegate complex work | Task | Isolated subagent with own context |
| Track progress | TodoWrite | pending → in_progress → completed |
| Fetch web content | WebFetch | URL + prompt, returns processed markdown |
| Search the web | WebSearch | Returns search results with links |

### File and Directory Hierarchy

```
~/.claude/                    (user-global scope)
├── CLAUDE.md                 (global instructions, always loaded)
├── settings.json             (global settings and permissions)
├── skills/                   (global skills)
├── agents/                   (global custom agents)
└── mcp.json                  (global MCP server config)

<project>/
├── CLAUDE.md                 (project instructions, auto-loaded)
├── CLAUDE.local.md           (personal overrides, gitignored)
├── .claude/
│   ├── CLAUDE.md             (additional project instructions)
│   ├── settings.json         (project settings)
│   ├── settings.local.json   (personal project settings)
│   ├── skills/               (project skills)
│   ├── agents/               (project custom agents)
│   ├── commands/             (project slash commands)
│   ├── rules/                (auto-loaded markdown rule files)
│   └── mcp.json              (project MCP server config)
└── src/
    └── CLAUDE.md             (directory-level, loaded contextually)
```

### Hook Events

| Event | When | Common Use |
|-------|------|------------|
| PreToolUse | Before a tool executes | Validate, block, or modify tool input |
| PostToolUse | After a tool completes | Log, notify, post-process results |
| Notification | Agent sends a notification | External alerts (Slack, desktop) |
| Stop | Agent finishes responding | Cleanup, final validation |
| SubagentStop | A subagent completes | Result validation |

### Permission Levels

| Array | Behavior |
|-------|----------|
| `allow` | Tool runs without prompting |
| `ask` | User prompted for confirmation |
| `deny` | Tool blocked entirely |

Evaluation order: deny → ask → allow (first match wins).

Pattern syntax: `"ToolName"`, `"Bash(npm test)"`, `"Bash(npm run *)"`,
`"mcp__server__*"`.

### MCP Configuration

| Scope | File |
|-------|------|
| Project | `.claude/mcp.json` |
| User global | `~/.claude/mcp.json` |

Transports: `stdio` (subprocess, most common) or `sse` (HTTP service).

## Updating Reference Content

Fetch the latest documentation from trusted sources:

```bash
# Fetch all sources
scripts/fetch_docs.sh

# Fetch a specific source
scripts/fetch_docs.sh --source anthropic-docs

# List available sources
scripts/fetch_docs.sh --list
```

Fetched content is stored in `cache/` for review. Reference files in
`references/` should be updated manually from cached content to ensure
quality and accuracy.

### Trusted Sources

| Source | URL | Content |
|--------|-----|---------|
| Anthropic Docs | docs.anthropic.com/en/docs/claude-code | Official reference |
| Claude Code GitHub | github.com/anthropics/claude-code | Source, examples |
| MCP Spec | modelcontextprotocol.io | Protocol specification |
| Simon Willison | simonwillison.net/tags/claude-code/ | Advanced patterns |
| eesel.ai | eesel.ai/blog | In-depth guides |
| Builder.io | builder.io/blog/claude-code | Practical workflows |
