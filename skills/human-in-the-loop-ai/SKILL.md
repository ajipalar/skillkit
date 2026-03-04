---
name: human-in-the-loop-ai
description: >-
  Expert guidance for effectively using human-in-the-loop AI systems to build
  things and accomplish tasks. Covers the full spectrum of AI-assisted work:
  software engineering, writing, research, data analysis, web development,
  creative projects, and more. Use when someone wants to: (1) learn how to use
  AI tools more effectively for building and creating, (2) understand expert
  patterns and workflows for AI-assisted development, (3) avoid common
  anti-patterns and failure modes when working with AI, (4) improve their
  prompt engineering and communication with AI systems, (5) learn context
  engineering and session management techniques, (6) understand how to
  decompose problems for AI collaboration, (7) calibrate trust and verification
  strategies for AI output, (8) learn about agentic workflows, multi-agent
  patterns, and automation, (9) understand the AI coding tools landscape and
  transferable patterns, (10) develop the soft skills of human-AI collaboration
  including knowing when to steer vs delegate. Draws from documented practices
  of expert AI builders, Anthropic's official guidance, and community-tested
  patterns. Applicable to Claude Code, Cursor, Copilot, and general AI-assisted
  workflows. Triggers on: AI workflow, AI best practices, using AI effectively,
  AI coding tips, human-in-the-loop, agentic engineering, context engineering,
  prompt engineering for coding, AI anti-patterns, vibe coding, AI pair
  programming, AI collaboration, working with AI, AI productivity, AI tools
  comparison, Claude Code tips, how to use AI, AI soft skills, AI for
  non-engineers, AI-assisted development, context window management, AI trust
  calibration, AI session management, AI task decomposition.
---

# Human-in-the-Loop AI: Expert Patterns for Building with AI

Guidance for getting excellent results from AI systems across software engineering,
writing, research, and creative work. Grounded in documented practices from expert
AI builders, Anthropic's engineering team, and real-world community experience.

## Core Philosophy

The shift is from "person who writes code/text" to "person who makes decisions about
code/text." AI changes *what you do*, not *whether you're needed*. The human brings
judgment, taste, real-world context, and accountability. The AI brings breadth,
speed, patience, and tirelessness.

Working with AI well is a skill unto itself. It involves knowing when to be specific
and when to be open-ended, when to plan and when to explore, when to trust and when
to verify, when to continue and when to start fresh.

## The Seven Principles

These principles are the foundation. They apply regardless of tool, domain, or
experience level.

### 1. Give AI a Way to Verify Its Own Work

This is the single highest-leverage thing you can do. AI performs dramatically better
when it can check itself — run tests, compare screenshots, validate outputs.

Without verification criteria, you become the only feedback loop and every mistake
requires your attention. With verification, AI can self-correct through multiple
iterations autonomously.

Strategies:
- Write tests first, let AI implement to pass them
- Provide example inputs and expected outputs
- For UI work, provide screenshots or mockups and ask AI to compare
- Add linting, type checking, and build steps as verification gates
- State what "done" looks like explicitly

### 2. Explore First, Then Plan, Then Code

Jumping straight into implementation produces code that solves the wrong problem.
Separate research and planning from execution.

The four-phase workflow:
1. **Explore** — Read files, understand the existing system, ask questions
2. **Plan** — Propose an approach, identify files to change, anticipate tradeoffs
3. **Implement** — Write code with verification at each step
4. **Commit** — Clean commit with descriptive message, open PR if appropriate

Skip planning only when the scope is clear and the fix is small. Planning is most
valuable when you're uncertain about the approach, the change touches multiple files,
or you're unfamiliar with the code.

### 3. Provide Specific Context

The more precise your instructions, the fewer corrections you'll need. Reference
specific files, mention constraints, point to example patterns.

The context hierarchy (include in this order):
1. The goal — what you're trying to accomplish
2. Constraints — what you can't change, must comply with
3. Examples — what good output looks like
4. Existing code — what already exists
5. Nice-to-haves — preferences that can be overridden

The specificity sweet spot: specify the WHAT and the CONSTRAINTS tightly. Leave the
HOW open unless you have strong preferences.

### 4. Manage Context as a Finite Resource

The context window is the most important resource to manage. Performance degrades as
it fills. Stale context actively hurts results.

Key practices:
- Clear context between unrelated tasks
- Use subagents/separate sessions for research to keep the main context clean
- Scope investigations narrowly
- Compact when sessions get long, with instructions about what to preserve
- Start fresh when accumulated corrections pollute the context

The metaphor: "AI context is like milk — best served fresh and condensed."

### 5. Course-Correct Early and Often

The best results come from tight feedback loops. Correct AI as soon as you notice it
going off track rather than waiting for it to finish.

Key techniques:
- Stop mid-action when the direction is wrong
- After two failed corrections, clear and restart with a better initial prompt
- Use partial accepts: "The data model is right but the API layer is wrong"
- Use reference redirects: "Follow the pattern in [existing file] instead"

The two-strike rule: if AI hasn't fixed the issue in two attempts, stop. Restate
the problem from scratch, provide more context, or solve it yourself.

### 6. You Are the Architect

AI implements. You design. Make architectural decisions deliberately. The AI is like
an extremely well-read intern with a photographic memory who has never shipped
software to production — it knows patterns well but has poor judgment about which
patterns to apply when.

What this means in practice:
- Don't let architecture emerge from a sequence of AI conversations
- Write down architectural decisions and enforce them
- Review AI output the same way you'd review a junior developer's PR
- Maintain your own mental model of the system at all times

### 7. Delegate When Verification Is Easy, Steer When It's Hard

This is the meta-skill: knowing which mode to be in.

**Delegate** (specify outcome, check final result): boilerplate, tests,
documentation, scaffolding, format conversions, code you can easily verify by
running it.

**Steer** (maintain moment-to-moment control): core business logic, novel algorithms,
security-sensitive code, database schemas, anything where consequences emerge over
time and verification is hard.

## Routing

When the user's question is about a specific domain, load the relevant reference:

**Context engineering, CLAUDE.md, session management, or context window strategies?**
→ Read `references/context-engineering.md`

**Communication patterns, prompt techniques, or soft skills for AI interaction?**
→ Read `references/communication-and-soft-skills.md`

**Anti-patterns, failure modes, or what doesn't work?**
→ Read `references/anti-patterns.md`

**Agentic workflows, automation, multi-agent patterns, or scaling AI usage?**
→ Read `references/agentic-workflows.md`

**AI tools landscape, comparing tools, or transferable patterns across tools?**
→ Read `references/tools-landscape.md`

**Non-engineer usage, writing, research, creative work, or domain-specific advice?**
→ Read `references/beyond-engineering.md`

If the question spans multiple domains or is general/exploratory, load the most
relevant 2-3 references rather than all of them.
