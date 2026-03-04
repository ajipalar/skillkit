# Context Engineering

Context engineering is the practice of curating what goes into a limited context
window to maximize the likelihood of good outcomes. It is the evolution of prompt
engineering — where prompt engineering focuses on crafting individual requests,
context engineering focuses on the entire information environment the AI operates in.

The guiding principle: find the smallest set of high-signal tokens that maximize
the likelihood of the desired outcome.

## Why Context Matters More Than Prompts

LLMs experience "context rot" — performance degrades as token volume increases.
Each token depletes the model's limited attention budget. A 200k context window
does not mean 200k tokens of equally-weighted information. Tokens near the beginning
and end receive more attention. Important information in the middle gets lost.

This means context engineering is fundamentally about triage: what deserves to be
in the window, what should be loaded on demand, and what should stay out entirely.

## The Four Context Operations

1. **Writing** — Creating external memory (files, notes, to-do lists) that persists
   across sessions and can be pulled back in when needed.

2. **Selecting** — Retrieving only relevant information rather than loading everything.
   Just-in-time loading: maintain lightweight identifiers and dynamically load via
   tools rather than pre-loading all data.

3. **Compressing** — Summarizing conversation history to preserve critical decisions
   while discarding redundant outputs. When compacting, give instructions about what
   to preserve (e.g., "focus on the API changes," "keep the full list of modified
   files").

4. **Isolating** — Running focused subtasks in separate context windows (subagents)
   that return condensed summaries. This prevents research and exploration from
   consuming your implementation context.

## CLAUDE.md and Persistent Context

CLAUDE.md files are the primary mechanism for persistent context in Claude Code.
They're loaded at the start of every conversation.

### What belongs in CLAUDE.md

Include only things that apply broadly and that Claude can't infer from code:
- Bash commands Claude can't guess (build commands, test runners)
- Code style rules that differ from language defaults
- Testing instructions and preferred frameworks
- Repository etiquette (branch naming, PR conventions)
- Architectural decisions specific to the project
- Developer environment quirks (required env vars, non-obvious setup)
- Common gotchas and non-obvious behaviors

### What does NOT belong in CLAUDE.md

- Anything Claude can figure out by reading code
- Standard language conventions Claude already knows
- Detailed API documentation (link to it instead)
- Information that changes frequently
- Long explanations or tutorials
- File-by-file descriptions of the codebase
- Self-evident practices like "write clean code"

### The pruning test

For each line in CLAUDE.md, ask: "Would removing this cause Claude to make mistakes?"
If not, cut it. Bloated CLAUDE.md files cause important rules to get lost in noise.

If Claude keeps doing something you don't want despite a rule against it, the file
is probably too long. If Claude asks questions answered in CLAUDE.md, the phrasing
is likely ambiguous.

### CLAUDE.md hierarchy

Use layered configuration for different scopes:
- **Global** (`~/.claude/CLAUDE.md`) — personal preferences across all projects
- **Project root** (`./CLAUDE.md`) — shared with team, checked into git
- **Local** (`./CLAUDE.local.md`) — personal project overrides, gitignored
- **Directory-level** — loaded on demand when working in that directory
- **Child directories** — pulled in when Claude works with files in those dirs

### Emphasis for adherence

You can tune instructions with emphasis ("IMPORTANT," "YOU MUST") to improve
adherence. This works because it changes the token distribution the model attends
to. Use sparingly — if everything is important, nothing is.

## Session Management Patterns

### When to clear context

- Between unrelated tasks (always)
- After accumulated corrections have polluted the session
- When the AI seems "confused" or contradicts earlier output
- When you've realized your initial framing was wrong
- After a long exploration phase, before implementation

### When to continue

- Making incremental improvements to existing output
- The conversation has built up useful context (structure, constraints, decisions)
- You're in productive flow with the AI
- The AI correctly understands your domain and conventions

### Compaction strategies

- `/compact` with instructions: `/compact Focus on the API changes`
- Selective summarization: summarize from a specific checkpoint forward
- Document-and-clear: have AI dump progress to markdown, clear, restart fresh
- CLAUDE.md compaction instructions: "When compacting, always preserve the full
  list of modified files and any test commands"

### The handoff document pattern

For complex multi-session work:
1. Before ending a session, ask AI to write a progress document
2. Include: what was done, what remains, key decisions made, current state
3. Start the next session by pointing AI at this document
4. This transfers context without relying on conversation history

## Context Budgeting

Expert users think of context like a budget:
- System prompt + CLAUDE.md: ~20k tokens (fixed cost)
- Skill metadata: ~100 words per skill (fixed cost)
- Remaining: ~180k tokens for actual work

This means every line in CLAUDE.md and every skill description competes with your
working context. Trim aggressively.

### Progressive disclosure for skills and references

The three-level loading pattern:
1. **Level 1 — Metadata** (name + description): always in context, ~100 words
2. **Level 2 — Body** (instructions): loaded when triggered, target <5000 words
3. **Level 3 — References** (detailed docs): loaded on demand, unlimited size

This pattern applies beyond skills — any information the AI might need should be
organized in tiers of relevance rather than dumped into context all at once.

## Making Codebases AI-Friendly

Repository structure decisions that help AI work more effectively:

- **Strong typing** — Types serve as documentation AI can read and verify against
- **Clear naming conventions** — AI can navigate better when names are descriptive
- **Co-located tests** — AI finds and runs relevant tests faster
- **README files in key directories** — Provide architectural context AI can load
- **Consistent patterns** — AI performs best when the codebase follows predictable
  conventions rather than mixing multiple approaches
- **Small, focused files** — Easier for AI to load and understand individually

## Sources and Further Reading

- Anthropic Engineering: "Effective Context Engineering for AI Agents"
  (anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- Claude Code Best Practices (code.claude.com/docs/en/best-practices)
- Shrivu Shankar: "How I Use Every Claude Code Feature" (blog.sshh.io)
- Gartner (July 2025): "Context engineering is in, and prompt engineering is out"
