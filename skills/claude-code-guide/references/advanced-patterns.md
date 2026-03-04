# Advanced Patterns Reference

## Table of Contents

- [Ralph Wiggum Loop](#ralph-wiggum-loop)
- [Worktrees for Parallel Development](#worktrees-for-parallel-development)
- [Phased Execution](#phased-execution)
- [Multi-Agent Workflows](#multi-agent-workflows)
- [Context Window Management](#context-window-management)
- [Headless and CI Mode](#headless-and-ci-mode)
- [Piping and Composition](#piping-and-composition)

## Ralph Wiggum Loop

An iterative development pattern where Claude Code works on a task in a
persistent loop, retrying and refining until completion. Named after the
Simpsons character — the agent keeps going regardless of setbacks.

### How It Works

1. Claude receives a task prompt
2. Claude works on the task (writes code, runs tests, etc.)
3. When Claude tries to stop, a **Stop hook** intercepts the exit
4. The hook feeds the same prompt back, forcing Claude to continue
5. Claude sees what it already did and iterates further
6. The loop continues until the task is truly complete (all tests pass,
   all requirements met) or a maximum iteration count is reached

### Implementation

The loop is powered by a Stop hook in `settings.json`:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/ralph-wiggum.sh"
          }
        ]
      }
    ]
  }
}
```

The hook script checks whether the task is truly done (e.g., tests pass,
linting clean) and either allows the stop (exit 0) or blocks it (exit 2)
with feedback about what still needs work.

### Key Principles

- **Don't aim for perfection on the first try.** Let the loop refine.
- **"Deterministically bad" is useful.** Predictable failures are
  informative and guide iteration.
- **Good prompts matter more than good models.** The loop amplifies
  prompt quality.
- The loop runs inside the current session — no external bash loops or
  process restarts needed.

### When to Use

- Large feature implementations with many files
- Tasks with clear success criteria (tests, linting, type checking)
- Refactoring where each pass can improve incrementally
- Bug fixes where the fix may reveal additional issues

### When NOT to Use

- Simple one-shot tasks
- Tasks without measurable completion criteria
- Tasks requiring human judgment at each step

## Worktrees for Parallel Development

Git worktrees let you work on multiple branches simultaneously in
isolated directory copies.

### Creating a Worktree

Use the `EnterWorktree` tool (only when the user explicitly asks for a
"worktree"):

```
EnterWorktree → creates .claude/worktrees/<name>/
             → new branch based on HEAD
             → session CWD switches to worktree
```

### Parallel Feature Development

Run multiple Claude Code sessions, each in a different worktree:

```
Terminal 1: worktree for feature-auth  → working on authentication
Terminal 2: worktree for feature-ui    → working on UI redesign
Terminal 3: main branch                → reviewing and merging
```

### Combining with Ralph Wiggum Loop

Each worktree can run its own Ralph Wiggum loop independently:

```
Terminal 1: /ralph-loop "implement auth" → iterating in worktree A
Terminal 2: /ralph-loop "implement UI"   → iterating in worktree B
```

### Cleanup

On session exit, you're prompted to keep or remove the worktree.
Worktrees with no changes are cleaned up automatically.

## Phased Execution

Break large tasks into discrete phases with clear boundaries.

### The Pattern

```
Phase 1: Analysis   → Read and understand the codebase
Phase 2: Plan       → Design the approach (use EnterPlanMode)
Phase 3: Execute    → Implement changes
Phase 4: Verify     → Run tests, validate, fix issues
```

### Using TodoWrite for Phase Tracking

```
TodoWrite([
  {content: "Analyze existing auth system", status: "completed", ...},
  {content: "Design new auth flow", status: "completed", ...},
  {content: "Implement JWT middleware", status: "in_progress", ...},
  {content: "Write integration tests", status: "pending", ...},
  {content: "Update API documentation", status: "pending", ...}
])
```

### Phase Gates

Use AskUserQuestion between phases to confirm the approach:

```
Phase 1: Research complete → "I found X, Y, Z. Should I proceed with approach A or B?"
Phase 2: Plan approved    → "Here's the implementation plan. Ready to proceed?"
Phase 3: Code written     → "Implementation complete. Tests passing. Ready for review?"
```

## Multi-Agent Workflows

### Fan-Out / Fan-In

Dispatch multiple subagents in parallel, then merge results:

```
Parent Agent
├── Task A: "Analyze module X"     ─┐
├── Task B: "Analyze module Y"      ├── all run in parallel
└── Task C: "Analyze module Z"     ─┘
         │
         ▼
Parent merges results and synthesizes final report
```

Use when: analyzing a codebase from multiple angles, running independent
migrations, testing multiple approaches.

### Pipeline

Sequential subagent chain where each builds on the previous:

```
Task 1: "Research the problem"
  └── result fed to →
Task 2: "Design the solution"
  └── result fed to →
Task 3: "Implement the design"
  └── result fed to →
Task 4: "Write tests and verify"
```

Use when: each step requires the previous step's output, the task
naturally decomposes into stages.

### Specialist Agents

Use custom agents (`.claude/agents/`) for recurring specialized roles:

```
.claude/agents/
├── code-reviewer.md      → reviews PRs for quality
├── test-writer.md        → generates comprehensive tests
├── doc-writer.md         → writes documentation
└── security-auditor.md   → checks for vulnerabilities
```

Each agent has its own system prompt, tool set, and expertise.

## Context Window Management

The context window is a shared resource. Everything competes for space:
conversation history, tool outputs, skill content, file contents.

### Strategies

1. **Use subagents for context-heavy work.** Reading 20 files? Dispatch
   a subagent — its context is isolated from yours.

2. **Keep SKILL.md lean.** Move detailed content to `references/` files
   that are loaded on demand.

3. **Use Grep before Read.** Find the specific content you need instead
   of reading entire files.

4. **Use offset/limit with Read.** For large files, read only the
   relevant section.

5. **Use `/compact` when needed.** Compresses conversation history to
   free up context space.

6. **Dispatch Explore agents for research.** They return only the
   relevant findings, not everything they read.

### Signs of Context Pressure

- Claude starts "forgetting" earlier conversation details
- Responses become less coherent or miss requirements
- Auto-compaction kicks in (you'll see a message)
- Tool outputs get truncated

## Headless and CI Mode

Run Claude Code non-interactively for automation and CI/CD.

### Single-Turn Mode

```bash
claude --print "Explain what this function does" < file.py
```

`--print` (`-p`) runs one turn and exits. No interactive session.

### Piping Input

```bash
echo "Fix the type error in src/main.ts" | claude --print
cat error.log | claude --print "What caused this error?"
git diff | claude --print "Review these changes"
```

### CI Integration

```bash
claude --print \
  --allowedTools "Read,Grep,Glob" \
  --max-turns 5 \
  "Check for security issues in src/"
```

Key flags for CI:
- `--print` — non-interactive mode
- `--allowedTools` — restrict tool access
- `--max-turns` — limit agent iterations
- `--output-format json` — structured output

### Environment Variables for CI

```bash
export ANTHROPIC_API_KEY="sk-..."
export CLAUDE_CODE_MAX_TURNS=10
```

## Piping and Composition

Claude Code follows Unix philosophy — it can be composed with other tools.

### Reading from Stdin

```bash
cat file.py | claude "refactor this to use async/await"
git log --oneline -20 | claude "summarize recent changes"
npm test 2>&1 | claude "fix the failing tests"
```

### Chaining Operations

```bash
# Generate code, then run tests
claude --print "write a fibonacci function" > fib.py && python -m pytest fib.py

# Review and fix
git diff | claude --print "review" > review.md
```

### In Shell Scripts

```bash
#!/bin/bash
# Automated code review pipeline
for file in $(git diff --name-only main); do
  echo "Reviewing $file..."
  claude --print --allowedTools "Read,Grep" \
    "Review $file for bugs and style issues"
done
```
