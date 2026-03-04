# Skills and Slash Commands Reference

## Table of Contents

- [Overview](#overview)
- [SKILL.md Format](#skillmd-format)
- [Skill Directories](#skill-directories)
- [Skill Triggering and Discovery](#skill-triggering-and-discovery)
- [Slash Commands](#slash-commands)
- [Custom Commands](#custom-commands)
- [Skills vs Commands](#skills-vs-commands)
- [Creating Skills](#creating-skills)

## Overview

Skills are reusable capability modules that extend what Claude Code can do.
Each skill is defined by a `SKILL.md` file with YAML frontmatter and markdown
instructions. Skills can also include scripts, reference documentation, and
asset files.

## SKILL.md Format

Every skill requires a `SKILL.md` file in this format:

```yaml
---
name: my-skill
description: >-
  Clear description of what the skill does and when to use it.
  This is the primary triggering mechanism — the agent reads only
  the frontmatter to decide if a skill applies. Include trigger
  keywords, file types, and specific use cases here.
---

# Instructions

Step-by-step procedures, examples, and guidelines for using
this skill.
```

### Required Frontmatter Fields

| Field | Description |
|-------|-------------|
| `name` | Skill identifier. Becomes the `/slash-command` name. |
| `description` | 50-1024 characters. The agent reads this to decide whether to load the skill. Must contain all trigger context. |

### Body Conventions

- Use imperative/infinitive voice ("Run tests," not "You should run tests")
- Keep under 500 lines (shares context window with everything else)
- Move detailed content to `references/` files
- Include explicit routing to reference files when applicable
- Use markdown tables, code blocks, and structured formatting

### Skill Directory Structure

```
my-skill/
├── SKILL.md              (required — main skill definition)
├── scripts/              (optional — executable scripts)
│   ├── validate.sh
│   └── process.py
├── references/           (optional — detailed documentation)
│   ├── patterns.md
│   └── examples.md
└── assets/               (optional — templates, output files)
    └── template.html
```

**Progressive disclosure:** The agent loads content in layers:
1. **Frontmatter** (~100 words) — always available, used for triggering
2. **SKILL.md body** (< 500 lines) — loaded when skill triggers
3. **References** (unlimited) — loaded on demand from body instructions

## Skill Directories

Skills can be installed at two scopes:

| Scope | Path | Applies To |
|-------|------|------------|
| User global | `~/.claude/skills/<name>/SKILL.md` | All projects |
| Project | `.claude/skills/<name>/SKILL.md` | Current project only |

Project skills take precedence if there's a name conflict.

## Skill Triggering and Discovery

### Automatic Triggering

At session start, Claude scans skill directories and reads frontmatter
from each `SKILL.md`. When a user's request matches a skill's description,
Claude automatically loads the full skill body.

**Critical:** The `description` field is the only thing Claude reads
for triggering decisions. All trigger context — keywords, file types,
use cases, what NOT to trigger on — must be in the description.

### Manual Invocation

Users can explicitly invoke a skill with `/<skill-name>`:

```
/my-skill
/my-skill some arguments here
```

When invoked via slash command, the skill body is loaded regardless of
description matching.

### Triggering Best Practices

- Include both positive triggers ("use when...") and negative triggers
  ("do NOT use when...")
- List specific keywords the user might say
- Mention file types or extensions if relevant
- Keep description between 50-1024 characters

## Slash Commands

Slash commands are the user-facing invocation mechanism for skills.
The command name comes from the `name` field in SKILL.md frontmatter.

```
/commit          → loads skill named "commit"
/review-pr 123   → loads skill named "review-pr" with args "123"
```

### Built-in Commands

Some commands are built into Claude Code and cannot be overridden:

| Command | Function |
|---------|----------|
| `/help` | Show help |
| `/clear` | Clear conversation |
| `/compact` | Compress conversation context |
| `/cost` | Show token usage |
| `/doctor` | Check installation health |
| `/init` | Initialize CLAUDE.md |
| `/memory` | Edit CLAUDE.md |
| `/model` | Switch model |
| `/permissions` | View/modify permissions |
| `/status` | Show session status |
| `/fast` | Toggle fast mode |

## Custom Commands

Custom commands are simpler than skills — just a markdown file with
no frontmatter:

### File Location

```
.claude/commands/<name>.md
```

### Format

Plain markdown. Can include a `$ARGUMENTS` placeholder for user input:

```markdown
Review the pull request #$ARGUMENTS and provide feedback on:
1. Code quality
2. Test coverage
3. Potential bugs
```

Invoked with: `/name 42` → `$ARGUMENTS` becomes `42`.

### When to Use Custom Commands vs Skills

| Feature | Custom Command | Skill |
|---------|---------------|-------|
| Frontmatter | No | Yes (required) |
| Auto-triggering | No | Yes |
| Supporting files | No | Yes (scripts, references, assets) |
| Complexity | Simple prompts | Rich workflows |

## Skills vs Commands

In Claude Code v2.1.3, slash commands were merged into the skills system.
The distinction is now primarily about complexity:

- **Simple command:** A `.claude/commands/name.md` file with a prompt template
- **Full skill:** A `skills/name/SKILL.md` with frontmatter, instructions,
  and optional supporting files

Both are invokable via `/name`. Skills additionally support automatic
triggering based on the description field.

## Creating Skills

### Quick Start

1. Create the skill directory: `skills/<name>/`
2. Write `SKILL.md` with frontmatter and instructions
3. Optionally add `scripts/`, `references/`, `assets/`
4. Install to a project: copy or symlink to `.claude/skills/<name>/`

### Validation

Use `quick_validate.py` from the skill-creator skill to check structure:

```bash
python scripts/quick_validate.py /path/to/my-skill/
```

Checks: frontmatter presence, required fields, description length,
naming conventions, broken references.

### Distribution

Skills can be shared as:
- Git repositories (clone and install)
- `.skill` files (zip archives created by `package_skill.py`)
- Direct copies into `.claude/skills/`
