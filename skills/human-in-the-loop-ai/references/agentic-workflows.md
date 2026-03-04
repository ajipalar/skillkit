# Agentic Workflows and Automation

How to scale AI usage beyond a single conversation: multi-agent patterns, automation,
background execution, and CI/CD integration.

## The Agentic Shift

Agentic engineering (Simon Willison's term) refers to building software using coding
agents that can both generate and execute code. The defining shift: from
prompt → response to prompt → autonomous work → result.

This changes the developer's role from "person writing code" to "person defining
tasks, reviewing results, and making architectural decisions." The key insight from
Willison: "Writing code is cheap now" — the cost of initial working code has dropped
to near zero, which means the valuable skills shift to specification, verification,
and architectural judgment.

## Multi-Agent Patterns

### Fan-out/Fan-in

Break a task into independent subtasks, spawn an agent for each, collect and
synthesize results. Best for: large refactors, migrations, parallel file processing.

Example workflow:
1. Main agent lists all files needing migration
2. Script loops through files, spawning `claude -p "Migrate $file"` for each
3. Each agent works independently with scoped permissions
4. Main agent or human reviews aggregated results

### Pipeline

Agent A produces output → Agent B takes A's output as input → chain continues.
Best for: tasks with sequential dependencies, staged transformations.

### Writer/Reviewer

Two separate agents (or sessions) with different roles:
- **Session A** (Writer): implements the feature
- **Session B** (Reviewer): reviews the implementation with fresh eyes

A fresh context improves review quality because the reviewer isn't biased toward
code it just wrote. You can do this with tests too: one agent writes tests, another
writes code to pass them.

### Specialist delegation

Main agent acts as orchestrator, delegating to specialist subagents:
- One for testing
- One for documentation
- One for security review
- One for implementation

Each specialist has its own context window, preventing cross-contamination.

## Subagents in Practice

Subagents run in separate context windows and report back summaries. This is one
of the most powerful patterns because context is your fundamental constraint.

### When to use subagents

- Research and exploration — let a subagent read many files without cluttering
  your main context
- Verification — "use a subagent to review this code for edge cases"
- Parallel independent tasks — multiple subagents working simultaneously
- Tasks that read many files or need specialized focus

### Subagent design principles

- Subagents see CLAUDE.md content and inherit the full toolset
- Give subagents clear, scoped tasks with specific deliverables
- Keep subagent results as summaries — the main agent doesn't need to see
  everything the subagent processed
- Use subagents to protect your main context from information overload

### The subagent anti-pattern

Custom subagents that hide context from the main agent and force rigid, predetermined
workflows. Better approach: keep all key context in CLAUDE.md, let the main agent
use built-in Task() to spawn clones when needed. This gives context-saving benefits
without gatekeeping information.

## Non-Interactive and Scripted Execution

`claude -p "prompt"` runs Claude Code without a session, enabling integration into
scripts, CI pipelines, and automation.

### Use cases

- One-off queries: `claude -p "Explain what this project does"`
- Structured output: `claude -p "List all API endpoints" --output-format json`
- Pipeline integration: `claude -p "..." --output-format json | your_command`
- Batch processing: loop through a file list, spawning claude for each

### Scoping permissions for automation

Use `--allowedTools` to restrict what Claude can do when running unattended:
```bash
claude -p "Migrate $file" --allowedTools "Edit,Bash(git commit *)"
```

This is important for batch operations where you want focused, predictable behavior.

## Background Agents

Background agents work on tasks asynchronously while you continue other work.
Key patterns:

- Start a complex task and continue working on something else
- Run full test suites in the background
- Handle long-running builds or deployments
- Get notifications when tasks complete

## Hooks: Deterministic Automation

Hooks run scripts at specific points in Claude's workflow. Unlike CLAUDE.md
instructions (which are advisory), hooks are deterministic and guarantee execution.

### Hook types

- **PreToolUse** — runs before a specific tool (e.g., validate before git commit)
- **PostToolUse** — runs after a tool completes (e.g., lint after file edit)
- **Notification** — triggers on specific events

### Effective hook patterns

**Block-at-submit**: check validation files before allowing commits, forcing
test-and-fix loops. "Let the agent finish its plan, then check the final result"
rather than blocking mid-write (which confuses the agent).

**Auto-format**: PostToolUse hook on Write/Edit that runs formatter.

**Security scanning**: PreToolUse hooks that check for secrets before commits.

### Hooks vs CLAUDE.md rules

Use hooks for things that must happen every time with zero exceptions. Use CLAUDE.md
for guidelines that allow judgment and flexibility.

If Claude keeps violating a CLAUDE.md rule, make it a hook instead.

## Skills: Reusable Workflows

Skills encode domain knowledge and workflows that would otherwise need to be
re-explained each session.

### Skill design principles

- Use progressive disclosure: metadata always loaded, body on trigger, references
  on demand
- Keep SKILL.md under 5000 words
- Put "when to use" information in the YAML description, not the body
- Match instruction specificity to task fragility
- Include verification steps in workflows

### Invocable vs auto-triggered skills

- **Auto-triggered**: AI loads them when it detects relevance from the description
- **Invocable** (`disable-model-invocation: true`): only triggered by explicit
  `/skill-name` command. Use for workflows with side effects.

## Test-Driven AI Development

Simon Willison identifies Red/Green TDD as one of the key agentic engineering
patterns. The approach:

1. Write tests that define the desired behavior (the "red" state)
2. Hand the failing tests to the AI with instructions to make them pass
3. AI implements until tests are green
4. Human reviews the implementation

Why this works especially well with AI:
- Tests serve simultaneously as specification, verification, and safety net
- AI can iterate autonomously against a concrete success criterion
- The human maintains control through the test design
- Code and tests don't share blind spots (tests were written by human/separately)

## CI/CD Integration

### Claude Code GitHub Action

Use cases:
- Trigger PRs from Slack, Jira, or monitoring alerts
- Automated code review
- PR creation from issues
- Data-driven flywheel: bugs → better CLAUDE.md → improved agent behavior

### PR Review Pattern

1. Agent reads PR diff and related code
2. Flags potential issues, security concerns, performance problems
3. Comments on specific lines with suggestions
4. Human makes final review decisions

### The Feedback Loop

Track where AI makes mistakes and encode the lessons:
1. Bug discovered in AI-generated code
2. Identify the root cause (missing context, wrong pattern, etc.)
3. Update CLAUDE.md, skills, or hooks to prevent recurrence
4. The system gets better over time

## MCP: Extending AI's Reach

Model Context Protocol (MCP) servers connect AI to external services and tools.

### Design principles for MCP servers

Serve as secure data gateways with minimal high-level tools rather than bloated
API mirrors. Good MCP: `download_raw_data()`, `execute_code()`. Bad MCP: 50
thin wrappers around individual API endpoints.

### MCP vs CLI tools

If a well-designed CLI tool exists (like `gh` for GitHub), prefer it over an MCP
server. AI is good at learning CLI tools via `--help`. MCP is best for tools that
require authentication, state management, or data transformation that a CLI
can't handle.

### MCP context cost

Each MCP server's tool descriptions consume context window space. Enable servers
selectively for specific tasks. Too many active MCP servers = too much overhead.

## Parallel Work Patterns

### Git worktrees

Worktrees allow working on multiple branches simultaneously without switching.
Each worktree gets its own working directory with a separate branch.

Use cases:
- Feature work while keeping main clean
- Testing changes in isolation
- Running parallel development streams
- Running a writer session and a reviewer session on different worktrees

### Multiple terminal sessions

Run multiple Claude Code instances in parallel:
- Different tasks in different terminals
- One session for implementation, one for research
- Use named sessions (`/rename`) for organization

## Sources

- Simon Willison: "Agentic Engineering Patterns" (simonwillison.net, Feb 2026)
- Shrivu Shankar: "How I Use Every Claude Code Feature" (blog.sshh.io)
- Claude Code Best Practices (code.claude.com/docs/en/best-practices)
- Claude Code documentation on skills, hooks, subagents, and MCP
