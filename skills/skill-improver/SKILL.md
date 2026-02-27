---
name: skill-improver
description: >-
  Evaluate and improve existing skills using systematic quality criteria.
  Use when a user asks to "improve a skill," "review a skill," "evaluate
  a skill," "update a skill," "optimize a skill," or "expand a skill"
  in a specific way. Also triggers on requests like "make this skill
  better," "this skill needs work," "audit this skill," or "check skill
  quality." Does not create new skills from scratch (use skill-creator
  for that).
---

# Skill Improver

Evaluate and improve existing skills through systematic quality analysis.

## Workflow

1. Identify the target skill and user intent
2. Run automated structural analysis
3. Evaluate against quality criteria
4. Determine improvement path
5. Propose improvements
6. Implement approved changes

## Step 1: Identify the Target Skill

Determine which skill to improve and what the user wants.

- **Named skill**: Locate the skill by name in the skills directory.
- **Contextual reference**: If the user says "improve this skill" during
  or after using a skill, identify from context.
- **Ambiguous**: Ask the user to specify which skill.

Read the full SKILL.md and scan the skill's directory structure
(scripts/, references/, assets/).

Classify the user's intent:

- **Autonomous review**: "improve this skill", "review this skill" —
  evaluate against all criteria.
- **Directed improvement**: "expand this skill to handle X", "make this
  more concise" — focus on the specific request while also checking
  foundational criteria (Tier 1).

## Step 2: Run Automated Analysis

Run the structural analysis script:

```bash
scripts/analyze_skill.py <path-to-skill-directory>
```

Review the output. This provides quantitative data (line counts,
frontmatter validity, link integrity, extraneous files) before
qualitative evaluation.

## Step 3: Evaluate Against Quality Criteria

Read [references/evaluation-criteria.md](references/evaluation-criteria.md)
for the full evaluation rubric.

Evaluate each criterion in tier order. Assign a verdict to each:

- **PASS**: Meets the standard. No changes needed.
- **NEEDS IMPROVEMENT**: Functional but could be better.
- **FAIL**: Critical problem that undermines effectiveness.

For each non-passing verdict, record:

- The criterion name and tier
- Specific evidence (quote the relevant section, cite lines)
- What the improved state should look like

### Evaluation Order

Evaluate Tier 1 first. Tier 1 failures are blockers — present them
before Tier 2 or 3 improvements.

**Tier 1: Foundational** — Correctness, Trigger Quality
**Tier 2: Effectiveness** — Impact, Clarity, Token Efficiency, Degree of Freedom
**Tier 3: Polish** — Structure, Maintainability

## Step 4: Determine Improvement Path

**All criteria PASS + no user-directed changes?**
→ Report that the skill meets quality standards. Do not make changes
  for the sake of making changes. This is a valid outcome.

**Criteria-based improvements found?**
→ Create a ranked improvement plan. Tier 1 first, then Tier 2, then
  Tier 3. Within a tier, prioritize by impact on effectiveness.

**User-directed improvement requested?**
→ Evaluate whether the requested change is appropriate:
  - Does it fit the skill's scope?
  - Would it push SKILL.md over 500 lines? If so, plan progressive
    disclosure (extract to reference files).
  - Does it conflict with any quality criteria?
→ Incorporate the directed change into the improvement plan alongside
  any criterion-based improvements. Tier 1 issues still take priority.

## Step 5: Propose Improvements

Present a summary to the user before making changes:

1. **Analysis overview**: Key findings from the automated analysis.
2. **Criterion verdicts**: Each criterion with its verdict
   (PASS / NEEDS IMPROVEMENT / FAIL).
3. **Proposed changes**: For each improvement, explain:
   - Current state
   - Proposed change
   - Which criterion it addresses

Wait for user approval. The user may accept all, accept some, reject,
or provide additional direction.

## Step 6: Implement Approved Changes

1. Edit SKILL.md and any affected files.
2. If SKILL.md exceeds 500 lines after changes, extract detailed
   content into references/ files with navigation links.
3. Re-run `scripts/analyze_skill.py` to verify structural validity.
4. Present a summary of what changed.

### Change Principles

- **Preserve voice**: Match the skill's existing tone and conventions.
  Do not rewrite sections not flagged for improvement.
- **Minimal changes**: Make the smallest change that addresses the
  criterion. Do not refactor working sections unnecessarily.
- **Maintain references**: When moving content to reference files, add
  clear "when to read" guidance in SKILL.md.
- **Test scripts**: If modifying scripts, run them to verify correctness.
- **Imperative form**: Use imperative/infinitive voice throughout.

## Common Improvement Patterns

### Token Efficiency

- Extract inlined reference material (>20 lines) into references/ files
- Remove duplicated information between SKILL.md and reference files
- Replace verbose explanations with concise examples
- Remove general knowledge the agent already has
- Consolidate redundant sections

### Trigger Quality

- Add missing trigger scenarios to the description
- Add "when NOT to use" context to prevent false triggers
- Include specific file types, user phrasings, or task contexts
- Move any "when to use" content from the body into the description

### Clarity

- Add explicit branching logic at decision points
- Define expected inputs and outputs for each step
- Replace ambiguous language ("consider", "might want to") with
  direct instructions ("check", "verify", "if X then Y")
- Add examples for non-obvious steps

### Structure

- Extract repeatedly-rewritten code into scripts/
- Move large reference blocks into references/ files
- Remove extraneous files (README.md, CHANGELOG.md, etc.)
- Add navigation links from SKILL.md to reference files
