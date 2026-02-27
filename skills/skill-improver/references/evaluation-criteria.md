# Evaluation Criteria

Evaluate skills against these criteria in tier order. Each criterion
has a description, PASS indicators, and common anti-patterns.

Use PASS / NEEDS IMPROVEMENT / FAIL verdicts. Do not use numeric scores.

## Tier 1: Foundational

A skill that fails Tier 1 has critical problems. Fix these before
addressing Tier 2 or 3.

### 1. Correctness

Instructions contain no factual errors, outdated information, or
broken references.

**PASS indicators:**
- All referenced files and paths exist
- Scripts execute without errors
- Code examples are syntactically correct
- Instructions produce the described outcome when followed
- No contradictions between SKILL.md and reference files

**Anti-patterns:**
- Referencing files that do not exist in the skill directory
- Scripts with import errors or missing dependencies
- Outdated API endpoints or deprecated function calls
- Code examples with syntax errors
- Contradictory instructions across files

### 2. Trigger Quality

The `description` field accurately captures all scenarios where the
skill should activate.

**PASS indicators:**
- Description covers all intended use cases
- Includes specific trigger phrases, file types, or contexts
- No "when to use" information buried in the body
- Description is 50-1024 characters
- Does not trigger on requests outside the skill's scope

**Anti-patterns:**
- Vague description ("A skill for helping with documents")
- Missing trigger scenarios (handles PDFs but description only says "docs")
- "When to Use" section in the body (agent never sees it before triggering)
- Overly broad description that triggers on unrelated requests
- Description that duplicates the name without adding context

## Tier 2: Effectiveness

Determines how well the skill works once triggered.

### 3. Impact

The skill provides genuinely non-obvious knowledge that changes agent
behavior beyond baseline capabilities.

**PASS indicators:**
- Contains procedural knowledge the agent lacks without the skill
- Provides domain-specific details (schemas, APIs, business rules)
- Includes tooling (scripts, templates) that saves significant effort
- Addresses tasks where agents commonly produce suboptimal output

**Anti-patterns:**
- Restating general knowledge the agent already has
- Instructions the agent would follow naturally ("Write clean code")
- Basic tutorials for well-known technologies
- Instructions that add tokens without changing behavior

### 4. Clarity

Instructions are unambiguous. The agent never has to guess what to do.

**PASS indicators:**
- Each step has a clear action verb
- Decision points have explicit conditions and branches
- Expected inputs and outputs are stated or implied
- Technical terms are used consistently
- No contradictory instructions

**Anti-patterns:**
- Vague language: "consider", "you might want to", "as appropriate"
  when specificity is needed
- Missing branching logic at decision points
- Steps that assume context not provided
- Inconsistent terminology for the same concept
- Steps without clear completion criteria

### 5. Token Efficiency

The skill is concise and uses context window space wisely.

**PASS indicators:**
- SKILL.md under 500 lines
- No duplicated information between SKILL.md and reference files
- Progressive disclosure used: detailed content in reference files
- Every paragraph justifies its token cost
- Concise examples preferred over verbose explanations
- General knowledge not restated

**Anti-patterns:**
- SKILL.md over 500 lines with inlined reference material
- Same information in both SKILL.md and a reference file
- Long explanations where a short example suffices
- General knowledge restated ("JSON is a data format...")
- Unused reference files never linked from SKILL.md

### 6. Degree of Freedom

Specificity matches the task's fragility and variability.

**PASS indicators:**
- Fragile operations use specific scripts or exact steps
- Open-ended tasks use flexible guidance
- Does not over-constrain where multiple approaches are valid
- Does not under-constrain where precision is critical
- Configuration points identified where appropriate

**Anti-patterns:**
- Rigid step-by-step for creative or context-dependent tasks
- Vague guidance for operations requiring exact sequences
- Missing scripts for tasks repeatedly hand-coded
- Over-parameterization: too many config points that rarely change
- Hardcoded values that should be configurable

## Tier 3: Polish

Improves quality but not critical.

### 7. Structure

The skill uses the file system effectively.

**PASS indicators:**
- Repeatedly-rewritten code extracted into `scripts/`
- Large reference material (>20 lines) in `references/` files
- Assets for output in `assets/`
- No extraneous files (README.md, CHANGELOG.md, etc.)
- Reference files linked from SKILL.md with "when to read" guidance
- Reference files over 100 lines have a table of contents
- No deeply nested references (one level from SKILL.md)

**Anti-patterns:**
- All content inlined in a single large SKILL.md
- Reference files that exist but are never linked from SKILL.md
- Scripts described in SKILL.md but do not exist
- Extraneous documentation files
- Deeply nested reference chains (A references B references C)

### 8. Maintainability

The skill is organized for easy future updates.

**PASS indicators:**
- Related concerns grouped in logical sections
- Naming consistent across files and sections
- No hidden dependencies or fragile assumptions
- Configuration values easy to locate and update
- Well-defined scope that does not sprawl

**Anti-patterns:**
- Same concept scattered across multiple sections
- Inconsistent naming between SKILL.md and scripts/references
- Hardcoded paths or values buried deep in instructions
- Scope creep: skill tries to do too many unrelated things
- Circular dependencies between sections
