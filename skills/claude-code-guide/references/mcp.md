# Model Context Protocol (MCP) Reference

## Table of Contents

- [Overview](#overview)
- [Configuration Files](#configuration-files)
- [Server Definition](#server-definition)
- [Transport Types](#transport-types)
- [Tool Naming](#tool-naming)
- [Permissions for MCP Tools](#permissions-for-mcp-tools)
- [MCP Tool Search](#mcp-tool-search)
- [Common MCP Servers](#common-mcp-servers)
- [Debugging MCP Connections](#debugging-mcp-connections)

## Overview

MCP (Model Context Protocol) is an open standard that lets Claude Code
connect to external tool servers. Each MCP server exposes tools that
Claude can call alongside built-in tools. MCP servers run locally on
your machine as subprocesses or connect as remote HTTP services.

## Configuration Files

| Scope | File |
|-------|------|
| Project | `.claude/mcp.json` |
| User global | `~/.claude/mcp.json` |

### mcp.json Format

```json
{
  "mcpServers": {
    "server-name": {
      "command": "executable",
      "args": ["arg1", "arg2"],
      "env": {
        "KEY": "value"
      },
      "cwd": "/optional/working/dir"
    }
  }
}
```

Project and global configs are merged. If a server name appears in both,
the project config takes precedence.

## Server Definition

### Required Fields

| Field | Description |
|-------|-------------|
| `command` | Executable to run (e.g., `"node"`, `"python"`, `"npx"`) |

### Optional Fields

| Field | Description |
|-------|-------------|
| `args` | Array of command-line arguments |
| `env` | Environment variables (merged with process env) |
| `cwd` | Working directory for the server process |

### Example: Node.js MCP Server

```json
{
  "mcpServers": {
    "my-tools": {
      "command": "node",
      "args": ["/path/to/server.js"],
      "env": {
        "API_KEY": "sk-..."
      }
    }
  }
}
```

### Example: npx-based Server

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-filesystem", "/allowed/path"]
    }
  }
}
```

## Transport Types

### stdio (Default)

The server runs as a subprocess. Communication happens via stdin/stdout
using JSON-RPC messages. This is the most common transport.

```json
{
  "mcpServers": {
    "my-server": {
      "command": "python",
      "args": ["server.py"]
    }
  }
}
```

### SSE (Server-Sent Events)

The server runs as an HTTP service. Claude connects via a URL. Used for
remote or shared servers.

```json
{
  "mcpServers": {
    "remote-server": {
      "url": "https://example.com/mcp/sse"
    }
  }
}
```

### Streamable HTTP

A newer transport where the server exposes an HTTP endpoint. Similar
to SSE but uses standard HTTP request/response with optional streaming.

```json
{
  "mcpServers": {
    "http-server": {
      "url": "https://example.com/mcp"
    }
  }
}
```

## Tool Naming

MCP tools follow the naming convention:

```
mcp__<server-name>__<tool-name>
```

For example, a server named `"filesystem"` exposing a tool called
`"read_file"` would be called as:

```
mcp__filesystem__read_file
```

This naming is used in:
- Permission rules (`allowedTools`, `denyTools`)
- Hook matchers
- Tool references in agent definitions

## Permissions for MCP Tools

Control access to MCP tools in `settings.json`:

```json
{
  "permissions": {
    "allow": [
      "mcp__filesystem__read_file",
      "mcp__filesystem__list_dir"
    ],
    "deny": [
      "mcp__filesystem__delete_file"
    ]
  }
}
```

### Wildcard Patterns

```json
{
  "permissions": {
    "allow": [
      "mcp__filesystem__*"
    ]
  }
}
```

This allows all tools from the `filesystem` server.

## MCP Tool Search

When too many MCP tools are configured, Claude Code automatically enables
**MCP Tool Search** to avoid filling the context window with tool
descriptions.

### How It Works

- Triggered when MCP tool descriptions would consume >10% of the context
- Instead of preloading all tools, Claude searches for relevant tools
  dynamically based on the current task
- Tools are loaded on-demand as needed

### Implications

- Having many MCP servers is fine — tool search handles the overhead
- Tool descriptions should be clear and specific for good search matching
- You may see "Searching for tools..." messages during operation

## Common MCP Servers

| Server | Purpose |
|--------|---------|
| `@anthropic/mcp-server-filesystem` | File system access with path restrictions |
| `@anthropic/mcp-server-github` | GitHub API operations |
| `@anthropic/mcp-server-postgres` | PostgreSQL database queries |
| `@anthropic/mcp-server-puppeteer` | Browser automation |
| `@anthropic/mcp-server-memory` | Persistent key-value memory |
| `@anthropic/mcp-server-git` | Git repository operations |

Community servers are available for Slack, Notion, Linear, Google Drive,
and many other services. See the MCP server registry for a full list.

## Debugging MCP Connections

### Check Server Status

```bash
claude mcp list
```

Shows configured servers and their connection status.

### View Server Logs

MCP server stderr output appears in Claude Code's logs. Check for:
- Connection errors
- Authentication failures
- Missing dependencies

### Test a Server Manually

```bash
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | \
  node /path/to/server.js
```

### Common Issues

| Problem | Likely Cause | Fix |
|---------|-------------|-----|
| Server not found | Wrong command path | Check `command` and `args` |
| Connection timeout | Server crashes on start | Run server manually to see errors |
| Tools not appearing | Server returns empty tool list | Verify server implements `tools/list` |
| Permission denied | Tool not in allowedTools | Add to permissions in settings.json |
| Too many tools | Context window pressure | MCP Tool Search activates automatically |
