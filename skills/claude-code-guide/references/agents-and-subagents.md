# Agents and Subagents Reference

## Table of Contents

- [The Task Tool](#the-task-tool)
- [Built-in Subagent Types](#built-in-subagent-types)
- [Custom Agents](#custom-agents)
- [When to Use Subagents](#when-to-use-subagents)
- [Parallel Execution](#parallel-execution)
- [Context Isolation](#context-isolation)
- [Background Agents](#background-agents)
- [Worktree Isolation](#worktree-isolation)
- [Best Practices](#best-practices)

## The Task Tool

The Task tool is the primary mechanism for launching subagents. Each
subagent runs in its own isolated context window with a specific role.

### Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `description` | Yes | Short (3-5 word) summary, shown in progress UI |
| `prompt` | Yes | Full task instructions |
| `subagent_type` | Yes | Which agent type to use |
| `run_in_background` | No | Run asynchronously (default: false) |
| `isolation` | No | Set to `"worktree"` for git-isolated execution |
| `model` | No | Override model (e.g., `"haiku"` for simple tasks) |
| `max_turns` | No | Limit number of agentic turns |
| `resume` | No | Agent ID to resume a previous agent |

### Result

When a subagent completes, its final message is returned to the parent.
The parent can use this result to inform next steps, merge outputs, or
decide on further actions.

## Built-in Subagent Types

| Type | Tools Available | Best For |
|------|----------------|----------|
| `Bash` | Bash only | Git operations, command execution |
| `general-purpose` | All tools | Complex multi-step tasks |
| `Explore` | Read-only tools | Codebase exploration, research |
| `Plan` | Read-only tools | Designing implementation plans |

### Explore Agent

Fast, read-only agent for codebase investigation. Cannot modify files.
Specify thoroughness in your prompt: "quick," "medium," or "very thorough."

### Plan Agent

Designs implementation strategies. Returns step-by-step plans, identifies
critical files, and considers trade-offs. Cannot modify files.

## Custom Agents

Define custom agents as markdown files with YAML frontmatter.

### File Locations

| Scope | Path |
|-------|------|
| User global | `~/.claude/agents/<name>.md` |
| Project | `.claude/agents/<name>.md` |

### Agent File Format

```markdown
---
name: my-agent
description: >-
  Brief description of what this agent does. Claude uses this
  to decide when to invoke the agent.
tools:
  - Read
  - Grep
  - Glob
  - Bash
model: sonnet
---

# System Prompt

You are a specialized agent that does X.

## Instructions

1. First, do A
2. Then, do B
3. Finally, report C
```

### Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Agent identifier |
| `description` | Yes | Used for auto-triggering decisions |
| `tools` | No | List of allowed tools (defaults to all) |
| `model` | No | Model override |

### Important Rules

- Do NOT include `Task` in a custom agent's tools list — agents should
  not spawn further subagents unless specifically designed for orchestration
- The `description` field determines when Claude auto-selects this agent
- Keep system prompts focused and specific

## When to Use Subagents

**Use subagents when:**
- The sub-task is complex enough to benefit from a fresh context window
- Multiple independent work streams can run in parallel
- The parent context is getting full and a clean slate would help
- You need a different persona or instruction set for part of the work
- The task involves extensive file reading that would bloat the parent context

**Don't use subagents when:**
- The task is simple (one or two tool calls)
- You need results immediately for the next step (sequential dependency)
- The task requires full conversation history
- A direct tool call would suffice

## Parallel Execution

Multiple Task calls in the same response execute concurrently:

```
(In a single response, call Task three times)
→ Agent A: Update component styles
→ Agent B: Write unit tests
→ Agent C: Update documentation

All three run simultaneously. Parent waits for all to complete.
```

### Guidelines for Parallel Dispatch

- Only parallelize truly independent tasks
- Each subagent prompt must be self-contained (no cross-agent dependencies)
- Include all necessary context in each prompt (file paths, requirements)
- Parent processes all results when they all complete

## Context Isolation

Subagents start with a clean context window. They do NOT inherit:
- Conversation history from the parent
- Files the parent has read
- Previous tool results
- Todo lists

**Implication:** The prompt must be comprehensive and self-contained.
Include:
- Full context about what needs to be done
- Relevant file paths
- Code snippets if the subagent needs them
- Clear success criteria
- Any constraints or conventions to follow

## Background Agents

Set `run_in_background: true` to run agents asynchronously:

- The parent continues working without waiting
- An `output_file` path is returned for later inspection
- Use `TaskOutput` to check results when needed
- Use `TaskStop` to terminate a running background agent

Best for: long-running tasks, monitoring, parallel exploration when
you don't need results immediately.

## Worktree Isolation

Set `isolation: "worktree"` to run the agent in a temporary git worktree:

- Agent gets a full copy of the repository on a new branch
- Changes are isolated from the main working tree
- Worktree is cleaned up automatically if no changes are made
- If changes are made, the worktree path and branch are returned

Best for: exploratory changes, risky modifications, generating
alternatives without affecting the current branch.

## Best Practices

1. **Write complete prompts.** Subagents have no parent context — every
   prompt must stand on its own.

2. **Use the right agent type.** Explore for research, Plan for design,
   general-purpose for implementation, Bash for commands.

3. **Prefer haiku for simple tasks.** Set `model: "haiku"` to reduce
   cost and latency on straightforward tasks.

4. **Limit parallel agents.** More isn't always better — each agent
   consumes resources. Aim for meaningful parallelism.

5. **Don't duplicate work.** If you dispatch a subagent to research
   something, don't also do the same research in the parent.

6. **Resume when possible.** Use the `resume` parameter with a previous
   agent ID to continue work without repeating context.
