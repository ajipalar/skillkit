# Communication and Soft Skills for AI Collaboration

The way you communicate with AI significantly impacts result quality. These patterns
come from documented practices of expert AI users including Simon Willison, Ethan
Mollick, Andrej Karpathy, Swyx, and real-world community experience.

## The Collaboration Mental Model

### You are the senior developer, AI is the junior

The AI is like an extremely well-read intern with a photographic memory who has
never shipped software. It knows patterns well but has poor judgment about which
to apply when. It will confidently do the wrong thing if not guided.

This model breaks down in important ways:
- Unlike an intern, AI doesn't learn from feedback across sessions
- Unlike an intern, AI has no continuity between sessions
- Unlike an intern, AI produces polished output that masks fundamental errors

### Co-intelligence, not tool use

Ethan Mollick's framing: AI is neither just a tool nor an autonomous agent — it's
a different kind of mind with complementary strengths. The human brings judgment,
stakes, taste, and accountability. The AI brings breadth, speed, patience, and
freedom from ego.

### Steering vs delegating

A framework from Geoffrey Litt:

**Steering**: You maintain moment-to-moment control. Review each output, provide
corrections, guide direction. Best for core logic, novel algorithms, anything
where correctness matters deeply.

**Delegating**: You specify an outcome and check the final result. Best for
boilerplate, tests, documentation, scaffolding, format conversions — code that
is easy to verify.

Rule of thumb: delegate when verification is easy, steer when verification is hard.

## Communication Patterns That Work

### Show, don't tell

Paste existing code and say "write something like this but for X." Concrete
examples outperform abstract descriptions. The AI is excellent at pattern-matching
from examples — often better than following abstract instructions.

### The explain-then-modify pattern

Ask AI to explain existing code first. Confirm it understands. Then ask for
modifications. This creates a shared mental model before changes happen.

### Paste the error, paste the context

When debugging, don't just say "it's broken." Include:
- Full error traceback
- The relevant code
- The test or command that triggers the failure
- What you expected to happen vs what actually happened

### The interview pattern

For larger features, have AI interview you first:

"I want to build [brief description]. Interview me about technical implementation,
UI/UX, edge cases, concerns, and tradeoffs. Don't ask obvious questions — dig into
the hard parts I might not have considered."

This surfaces requirements you haven't thought through. Once the spec is complete,
start a fresh session to implement it.

### The three options technique

When uncertain about approach: "Give me three different ways to implement this,
with tradeoffs for each." This leverages AI breadth while keeping human judgment
for the final decision.

### Ask AI to identify ambiguities

"Before you implement this, what questions would you ask to clarify the
requirements?" AI is good at surfacing issues you haven't considered.

## The Specificity Spectrum

| Style | When to use | Example |
|-------|------------|---------|
| **Vague/exploratory** | Prototyping, unfamiliar territory | "Build me a web scraper for this site" |
| **Structured request** | Production code, known patterns | "Create a function that takes X and returns Y, handling edge case Z" |
| **Constrained generation** | Critical code, specific requirements | "Using only stdlib, match this interface, O(n log n), passing these tests" |
| **Editing/refactoring** | Existing codebases | "Here is the code [paste]. Extract validation into a separate function. Keep the same public API." |

Under-specification leads to AI making assumptions you didn't intend. Over-specification
means you spend more time writing the spec than writing the code. The sweet spot:
specify WHAT and CONSTRAINTS tightly, leave HOW open.

## Course Correction

### The hard redirect

"Stop. That's not what I want. Let me re-explain from scratch." Don't be polite
about this — continuing down a wrong path wastes time and context.

### The partial accept

"The data model is right but the API layer is wrong. Keep the models, redo the API
using FastAPI instead of Flask." More efficient than starting over.

### The reference redirect

"Look at how [library X] handles this. Follow that pattern instead." Point AI at
existing implementations as templates.

### Checkpoint and verify

In long generation tasks, stop periodically: "Before continuing, let me review
what you have so far." Prevents building on flawed foundations.

## Giving Feedback Effectively

- Be specific about what's wrong — "the error handling on line 15 doesn't account
  for null input" not "this doesn't look right"
- Distinguish "wrong" from "not what I wanted" — wrong means a bug, not-what-I-wanted
  means style/approach mismatch. AI needs different info for each.
- Use diff-thinking — "Change X to Y" is clearer than "fix the thing"
- Positive feedback matters — "The data model is good, keep that" gives stable
  ground to work from

## Calibrating Trust

Trust is the single most important soft skill to develop.

### Trust calibration heuristics

1. **Trust is domain-dependent.** Very reliable for common patterns (CRUD, standard
   React components). Trust drops sharply for novel algorithms, security-sensitive
   code, concurrency, code with poorly-documented APIs.

2. **Trust the structure, verify the details.** AI is generally good at overall
   architecture and terrible at edge cases.

3. **Trust decreases with context window length.** As conversations get longer,
   consistency degrades. Fresh conversations for fresh problems.

4. **Trust output the AI can explain.** If the explanation is coherent and references
   real tradeoffs, trust increases. If it's hand-wavy or references nonexistent
   features, trust decreases.

5. **The first draft principle.** Treat everything AI produces as a first draft,
   never a final product. This single reframe prevents most problems.

### Verification levels

| Level | When | Method |
|-------|------|--------|
| **Run it** | Boilerplate, scaffolding | Execute and confirm output |
| **Read it** | Business logic, data transforms | Line-by-line review of core logic |
| **Test it** | Critical paths, edge cases | Write specific test cases |
| **Prove it** | Security, financial calculations | Formal reasoning or independent reimplementation |
| **Don't trust it** | Novel algorithms, crypto, concurrency | Rewrite from scratch, use AI output as inspiration only |

## The Psychology of AI Interaction

### Flow states

When collaboration works well, it produces a distinctive flow: rapid iteration,
human providing direction faster than they could implement, AI generating faster
than the human could write. Cycle time drops from hours to minutes.

Flow conditions: clear problem definition, well-scoped task, familiar domain,
well-suited model.

Flow killers: repeated misunderstandings, context amnesia, uncertainty about
correctness.

### Managing frustration

- **The "one more try" trap**: when you've been iterating without success for many
  rounds, it's usually better to start fresh, try a different approach, or do it
  yourself.

- **Frustration usually means wrong mode**: if steering isn't working, try
  delegating. If delegating isn't working, try steering. If neither works, the
  task may not be well-suited to AI right now.

- **Don't anthropomorphize**: the AI isn't being stubborn. When it repeatedly gets
  something wrong, the issue is usually that your prompt activates the wrong
  patterns. Reframe the request.

- **The 5-minute rule**: if you've spent more than 5 minutes getting AI to do
  something you could do in 10 minutes by hand, just do it by hand.

### Avoiding learned helplessness

This is real and widely documented:

- **Periodically write code yourself.** Maintain at least one project where you
  write everything. Keeps skills sharp and judgment calibrated.
- **Use AI to learn, not just to produce.** Ask "why does this work?" not just
  "make this work."
- **Notice when you stop understanding.** The moment you're copying output without
  comprehension is the moment to slow down.
- **The "3am test"**: if this code broke at 3am, could you debug it without AI?
  If not, you need to understand it better before shipping.

## Cognitive Patterns of Effective Users

### Problem decomposition

The biggest differentiator between effective and ineffective users is how they
break down problems.

**Layered delegation approach:**
1. Decompose the problem yourself into components
2. Assess each component: can AI do this well, or should I?
3. For AI-appropriate components, further decompose into session-sized tasks
4. Assemble the pieces yourself, with AI help for integration

**Small tools philosophy** (Simon Willison): build small, single-purpose tools
rather than monolithic applications. Each tool is a single-conversation-sized task.
The human provides the architecture that connects them.

### Maintaining understanding while delegating

- Read all AI-generated code, even if you didn't write it
- Ask AI to explain its approach before generating code
- Maintain a mental model of the architecture — if you can't draw it on a
  whiteboard, you've delegated too much
- Periodic comprehension checks: can I debug this without AI?

## Sources and Further Reading

- Ethan Mollick: "Co-Intelligence" (2024) and oneusefulthing.org
- Simon Willison: simonwillison.net (extensive practical AI workflow documentation)
- Geoffrey Litt: geoffreylitt.com (malleable software, end-user programming)
- Swyx: latent.space (AI-enhanced development, the AI engineer role)
- Addy Osmani: "AI-Assisted Software Engineering" (2024)
- Kent Beck: newsletter on AI and software design principles
