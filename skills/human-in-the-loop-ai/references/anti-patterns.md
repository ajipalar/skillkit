# Anti-Patterns and Failure Modes

What doesn't work when using AI for building. These are documented failure modes
from real-world experience, community discussions, and research. Understanding
them is as important as knowing the positive patterns.

## The Big Five Session Anti-Patterns

### 1. The Kitchen Sink Session

You start with one task, ask something unrelated, go back to the first task. Context
fills with irrelevant information and AI performance degrades on everything.

Fix: clear context between unrelated tasks. Each task gets its own session.

### 2. The Correction Spiral

AI does something wrong. You correct it. It's still wrong. You correct again.
Context is polluted with failed approaches and the AI keeps returning to them.

Fix: after two failed corrections, clear and restart with a better initial prompt
that incorporates what you learned. A clean session with a better prompt almost
always outperforms a long session with accumulated corrections.

### 3. The Over-Specified CLAUDE.md

Your instruction file is too long and Claude ignores half of it because important
rules get lost in noise.

Fix: ruthlessly prune. If Claude already does something correctly without the
instruction, delete it. If a rule is critical, make it a hook instead.

### 4. The Trust-Then-Verify Gap

AI produces a plausible-looking implementation that doesn't handle edge cases.
You accept it because it looks right.

Fix: always provide verification (tests, scripts, screenshots). If you can't
verify it, don't ship it.

### 5. The Infinite Exploration

You ask Claude to "investigate" something without scoping it. It reads hundreds
of files, filling the context with information you'll never use.

Fix: scope investigations narrowly or use subagents so exploration doesn't consume
your main context.

## Vibe Coding: When It Works and When It Doesn't

Andrej Karpathy coined "vibe coding" to describe accepting AI output based on
whether it "feels right" without deep understanding. Key insight: this is fine
for throwaway prototypes but dangerous as a primary development mode.

### When vibe coding is acceptable

- Throwaway prototypes and explorations
- Personal tools you'll only use briefly
- Learning experiments where the process matters more than the result
- Proof of concepts to test feasibility

### When vibe coding is dangerous

- Production code serving users
- Anything security-sensitive
- Code others will maintain
- Systems where failure has real consequences
- Code that will be built upon extensively

### The vibe coding failure cascade

1. You accept AI-generated code without understanding it
2. Each accepted change makes the next change harder to evaluate
3. The codebase becomes incomprehensible to everyone, including you
4. Adding a single feature now requires re-understanding the entire system
5. The estimated cost to refactor exceeds the cost to rewrite from scratch

Documented cases: developers spending 6 weeks adding a single feature to a system
they vibe-coded in 2 weeks, because they couldn't understand the architecture AI
had created.

## Technical Failure Modes

### Hallucinated APIs and libraries

AI confidently suggests functions, libraries, and patterns that don't exist. This
is arguably the most dangerous technical failure mode because:
- Non-existent library functions become runtime errors discovered late
- Version confusion produces deprecated or future-version patterns
- Invented patterns look internally consistent but don't match real frameworks
- Package name hallucination is a demonstrated supply chain attack vector

Countermeasure: verify all unfamiliar APIs, libraries, and patterns before using
them. Check that packages actually exist before installing.

### Security vulnerabilities

Research finding (Stanford, 2023): developers using AI assistants produce
significantly less secure code AND are more confident in its security.

Common AI-generated security issues:
- SQL injection via string concatenation instead of parameterized queries
- Missing input validation — handles happy path, ignores malicious input
- Hardcoded secrets and placeholder credentials left in code
- Insecure defaults: permissive CORS, disabled CSRF, overly broad permissions
- Broken authentication: plain-text passwords, weak JWT signing

Countermeasure: assume AI-generated code is insecure by default. Review for OWASP
Top 10. Consider running SAST tools on AI-generated code.

### Performance anti-patterns

AI tends to generate:
- **N+1 queries** — fetching a list then querying each record's relations separately
- **Unnecessary re-renders** in React (new objects in render, unstable references)
- **Loading everything into memory** — reading entire files, fetching all records
  before filtering
- **Naive algorithms** — O(n^2) or O(n^3) when O(n log n) is straightforward
- **Over-fetching** — `SELECT *` or full objects when only a few fields are needed

Countermeasure: performance review of AI-generated data access patterns, especially
database queries and React component rendering.

### The "almost right" problem

66% of developers cite "AI solutions that are almost right, but not quite" as their
biggest frustration. 45% say debugging AI-generated code is more time-consuming
than debugging their own code.

Why: AI-generated code is syntactically clean and well-formatted, which makes it
look correct even when it has subtle logic errors. It passes casual review because
reviewers pattern-match on surface quality rather than deep correctness.

Countermeasure: read AI-generated code with the same scrutiny you'd apply to a PR
from someone new to the team.

## Process Anti-Patterns

### No clear goal before starting

"Let's see what the AI comes up with" — starting without a plan and letting AI
suggestions drive the direction. This produces code that solves a problem you
didn't have, or solves the right problem in an incompatible way.

Related: goal drift — starting with "build a login page" then pivoting mid-conversation
to "add OAuth" then "also add 2FA" without establishing full requirements.

### Trying to do too much in one session

The marathon session: building an entire feature in a single long conversation.
Context quality degrades, contradictions accumulate, you lose track of code state.

Heuristic: if you can't describe what you're doing in one sentence, the session
scope is too large.

### Not reviewing AI output

Rubber-stamping — accepting AI output after a glance. This is the single most cited
anti-pattern in experienced developer discussions.

The dynamic: if the AI's first three suggestions were correct, you become less
critical of the fourth and fifth. This is when errors slip through.

### Over-engineering prompted by AI

AI tends to suggest "improvements" beyond what was asked: logging, metrics, error
handling, configuration, abstraction layers. Each individually reasonable,
collectively creating unnecessary complexity.

AI suggests design patterns (Strategy, Observer, Factory) even when a simple
if-statement would suffice. It creates interfaces, abstract base classes, and
plugin systems for code with only one implementation.

### Not maintaining your own mental model

The "AI knows" trap: deferring to AI's understanding of the codebase rather than
maintaining your own. When the AI is wrong about how a subsystem works, you can't
catch the error because you also don't know.

### Abandoning version control discipline

Common pattern: making many AI-assisted changes without committing, then losing the
ability to isolate which change introduced a bug. Or committing an entire session's
work as a single mega-commit.

The recommended practice: commit after every successful AI-assisted change that
works. Use branches for experiments. This is more important with AI than without.

## The Fix-Break-Fix Loop

One of the most commonly reported frustrations:

1. Ask AI to fix a bug
2. The fix introduces a new bug
3. Ask AI to fix that
4. It reverts part of the first fix, reintroducing the original bug
5. Each "fix" adds more code rather than simplifying
6. After several rounds, a 10-line function is 80 lines with workarounds

The sunk cost fallacy: spending hours in this loop because you feel invested in the
approach, when starting over would have been faster.

The heuristic: if AI hasn't fixed the issue in two attempts, stop. Restate the
problem from scratch, provide more context, or solve it yourself.

## The "99% Done, 100% Stuck" Problem

1. AI gets you to 90% of a feature very quickly
2. The remaining 10% involves edge cases, integration, or platform-specific behavior
3. AI can't solve these because they require deep context it doesn't have
4. You're stuck with a 90%-complete implementation you don't fully understand
5. Sometimes the last 10% reveals the first 90% was built on wrong assumptions

Lesson: the speed of the first 90% is not actually a speedup if it makes the last
10% harder. Invest in understanding the full scope before starting.

## AI-Generated Tests: The Shared Blind Spot

When AI generates both code and tests for that code in the same conversation:
- The tests pass because they test the implementation's assumptions
- The tests share the AI's blind spots — they don't test what the AI didn't think of
- The code has bugs that the tests are specifically designed not to catch

Countermeasure: tests should ideally be written from requirements by a human, or
by a completely separate AI session working only from the specification. Never let
the same AI session write both the code and the sole tests for that code.

## Organizational Anti-Patterns

### Inconsistent patterns across team members

Different developers prompting differently produce different patterns in the same
codebase. One developer's AI-generated code uses dependency injection, another's
uses global imports. Neither is wrong alone, but together they create incoherence.

### Loss of junior developer learning

Juniors who rely heavily on AI bypass the productive struggle that builds deep
understanding. The gap between "can produce working code" and "understands how
the system works" widens.

Counterpoint: AI can accelerate learning if used as a tutor ("explain why this
works") rather than a coder ("write this for me"). This requires discipline.

### Tool and vendor dependency

Teams that integrate AI so deeply that productivity craters during outages. Also:
workflows, prompting strategies, and expectations become tool-specific, creating
cognitive lock-in.

## The Statistics

- AI-generated code creates 1.7x more issues than human-written code
- 45% of AI-generated code contains security flaws
- Developer trust in AI accuracy dropped from 70% to 60% between 2024 and 2025
- Only 15% of developers have adopted "vibe coding" professionally
- 66% of developers say "almost right but not quite" is their biggest AI frustration

## Sources

- CodeRabbit: "State of AI vs Human Code Generation Report" (2025)
- Stanford study on AI-assisted developer security (2023)
- dev.to/lingodotdev: "AI Coding Anti-Patterns: 6 Things to Avoid"
- Alter Square: "AI Coding Tools in 2026" (real-world client project data)
- GroweXX: "The AI Code Security Crisis of 2026"
- Community discussions on HackerNews, Reddit r/ExperiencedDevs, r/programming
