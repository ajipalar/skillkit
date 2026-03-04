# Hooks Reference

## Table of Contents

- [Overview](#overview)
- [Hook Events](#hook-events)
- [Hook Types](#hook-types)
- [Matchers](#matchers)
- [Configuration](#configuration)
- [Exit Code Behavior](#exit-code-behavior)
- [Examples](#examples)
- [Best Practices](#best-practices)

## Overview

Hooks are user-defined event handlers that fire at specific points during
a Claude Code session. They let you run external commands, validate actions,
send notifications, or block operations before they execute.

Hooks are configured in `settings.json` (either global or project-level).

## Hook Events

### PreToolUse

Fires **before** a tool call executes.

- **Input (stdin):** JSON with `tool_name` and `tool_input`
- **Can block:** Yes (exit code 2)
- **Can modify input:** Yes (stdout JSON with modified `tool_input`)
- **Use cases:** Validate file paths, block dangerous commands, enforce
  naming conventions, add default parameters

### PostToolUse

Fires **after** a tool call completes successfully.

- **Input (stdin):** JSON with `tool_name`, `tool_input`, and `tool_output`
- **Can modify:** No (result is already committed)
- **Use cases:** Logging, notifications, auto-formatting after writes,
  triggering CI, updating dashboards

### Notification

Fires when Claude sends a notification to the user.

- **Input (stdin):** JSON with notification content
- **Use cases:** Desktop notifications, Slack messages, email alerts,
  sound effects for long-running tasks

### Stop

Fires when the agent finishes its response turn.

- **Input (stdin):** JSON with session context
- **Can block:** Yes (forces the agent to continue)
- **Use cases:** Final validation, cleanup, the Ralph Wiggum loop
  (see advanced-patterns.md), session logging

### SubagentStop

Fires when a subagent (launched via Task tool) completes.

- **Input (stdin):** JSON with subagent result
- **Use cases:** Result validation, aggregation, progress tracking

### UserPromptSubmit

Fires when the user submits a prompt.

- **Input (stdin):** JSON with the user's message
- **Can modify:** Yes (transform the prompt before processing)
- **Use cases:** Prompt preprocessing, logging, input validation

### SessionStart

Fires when a new Claude Code session begins.

- **Input (stdin):** JSON with session info
- **Use cases:** Environment setup, dependency checks, welcome messages

## Hook Types

### Command Hooks (type: "command")

Run a shell command. The most common hook type.

```json
{
  "type": "command",
  "command": "/path/to/script.sh"
}
```

- Receives event data as JSON on stdin
- Communicates back via exit codes and stdout
- Script can be any executable (bash, python, node, etc.)

### MCP Tool Hooks (type: "mcp")

Invoke an MCP server tool as a hook.

```json
{
  "type": "mcp",
  "server": "my-server",
  "tool": "validate_change"
}
```

Useful when hook logic requires capabilities provided by an MCP server.

## Matchers

Matchers filter which events trigger a hook. A hook only fires when
its matcher matches the event context.

### Tool Name Matching

For PreToolUse and PostToolUse, match on the tool name:

```json
{
  "matcher": "Write"
}
```

### Regex Patterns

Matchers are interpreted as regex:

```json
{
  "matcher": "Edit|Write"
}
```

This fires for both Edit and Write tool calls.

### No Matcher

Omitting the matcher means the hook fires for **all** events of its type.

## Configuration

Hooks are defined in `settings.json` under the `"hooks"` key:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/validate-command.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/auto-format.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/on-stop.sh"
          }
        ]
      }
    ]
  }
}
```

### Settings File Locations

| Scope | File |
|-------|------|
| User global | `~/.claude/settings.json` |
| Project | `.claude/settings.json` |
| Project local | `.claude/settings.local.json` |

## Exit Code Behavior

| Exit Code | Meaning |
|-----------|---------|
| 0 | Success — proceed normally. If stdout contains JSON, it may modify the action. |
| 2 | Block — the tool call is prevented (PreToolUse only). The agent sees the block message. |
| Non-zero (other) | Error — logged but does not block execution. |

### Modifying Tool Input (PreToolUse)

Return JSON on stdout with the modified `tool_input` to change what
the tool receives:

```bash
#!/bin/bash
# Read input
INPUT=$(cat)
# Modify and output
echo "$INPUT" | jq '.tool_input.command = "safe_" + .tool_input.command'
exit 0
```

## Examples

### Block Dangerous Bash Commands

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'INPUT=$(cat); CMD=$(echo $INPUT | jq -r .tool_input.command); if echo \"$CMD\" | grep -qE \"rm -rf|DROP TABLE|format\"; then echo \"Blocked dangerous command: $CMD\" >&2; exit 2; fi'"
          }
        ]
      }
    ]
  }
}
```

### Auto-Format After File Writes

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'INPUT=$(cat); FILE=$(echo $INPUT | jq -r .tool_input.file_path); if [[ \"$FILE\" == *.py ]]; then black \"$FILE\" 2>/dev/null; fi'"
          }
        ]
      }
    ]
  }
}
```

### Desktop Notification on Completion

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'osascript -e \"display notification \\\"Claude Code finished\\\" with title \\\"Done\\\"\"'"
          }
        ]
      }
    ]
  }
}
```

## Best Practices

- Keep hook scripts fast — they block the agent's execution
- Use exit code 2 only in PreToolUse to block; other events ignore it
- Log errors to stderr, return data on stdout
- Test hooks manually before deploying: `echo '{"tool_name":"Bash","tool_input":{"command":"ls"}}' | /path/to/hook.sh`
- Use project-level hooks (`.claude/settings.json`) for project-specific validations
- Use global hooks (`~/.claude/settings.json`) for personal workflow automations
