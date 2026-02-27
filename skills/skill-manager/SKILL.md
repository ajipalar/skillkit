---
name: skill-manager
description: >-
  Manage project-level skills by adding or removing them from the
  project's .claude/skills/ or .agents/skills/ directory. Use when
  a user asks to "add a skill," "install a skill," "remove a skill,"
  "uninstall a skill," "list available skills," "manage skills,"
  "what skills can I add," or "set up skills for this project."
  Also triggers when the user names specific skills to add (e.g.,
  "add skill-creator to this project"), asks to remove a skill
  (e.g., "remove conversation-summarizer"), or clarifies project
  scope in a way that implies certain skills would be useful (e.g.,
  "this is a biotech project" or "I need research skills").
  Operates only at project scope — never modifies global
  ~/.claude/skills/ or ~/.agents/skills/ directories. Discovers
  skill sources by searching for nearby directories that contain a
  skills/ subfolder with SKILL.md files (e.g., skillkit, skillsmith).
---

# Skill Manager

Manage project-level skills: discover available skill sources,
add skills to the current project, and remove installed skills.

## Scope

This skill operates ONLY at the project level:

- `.claude/skills/` for Claude Code
- `.agents/skills/` for Codex CLI

NEVER modify global directories (`~/.claude/skills/` or
`~/.agents/skills/`). If the user asks to manage global skills,
explain this scope limitation and suggest using the repository's
`install.sh` script directly.

## Workflow

1. Determine the user's intent (add, remove, or list)
2. Discover skill sources (for add/list)
3. Present available or installed skills
4. Execute the action with scripts
5. Confirm the result

## Step 1: Determine Intent

Classify the user's request:

- **Add skills** — proceed to Step 2.
- **Remove skills** — skip to Step 4 (Remove).
- **List available skills** — proceed to Step 2, present results,
  then ask what the user wants to do.
- **Project scope clarification** — the user describes their project
  or domain. Proceed to Step 2, then recommend relevant skills.
- **Ambiguous** — ask the user whether they want to add, remove,
  or list skills.

If the user names specific skills (e.g., "add skill-creator"),
proceed directly without listing all available options.

## Step 2: Discover Skill Sources

Find directories that contain a `skills/` subfolder with SKILL.md
files. Use the discovery script:

```bash
scripts/add_skills.sh --discover
```

To search a specific path instead of the default (parent of cwd):

```bash
scripts/add_skills.sh --discover --search-path /path/to/search
```

**What qualifies as a skill source:**
A directory containing a `skills/` subfolder, where that subfolder
has at least one subdirectory with a SKILL.md file.

**Where the script searches by default:**
1. Sibling directories of the current project (parent directory)
2. The current project itself

**Example layout:**

```
~/Projects/
├── skillkit/skills/          ← source
│   ├── skill-creator/SKILL.md
│   └── conversation-summarizer/SKILL.md
├── skillsmith/skills/        ← source
│   └── code-reviewer/SKILL.md
└── my-project/               ← current project
    └── .claude/skills/       ← target
```

If no sources are found, inform the user. Suggest providing a
path to a skill repository or cloning one.

## Step 3: Present Available Skills

List skills in a discovered source:

```bash
scripts/add_skills.sh --list --source /path/to/source-repo
```

This prints each skill's name and description. Present results
grouped by source.

If the user already specified which skills to add, skip the
listing and proceed to Step 4.

When the user clarifies project scope without naming skills,
review available skills and recommend ones relevant to their
domain. Ask which they want to add.

## Step 4: Execute Action

### Adding Skills

```bash
scripts/add_skills.sh --source <path> --skills name1,name2 [--claude] [--codex]
```

Add all skills from a source:

```bash
scripts/add_skills.sh --source <path> --all [--claude] [--codex]
```

**Flags:**

| Flag | Description |
|------|-------------|
| `--source <path>` | Path to the source repo (directory containing `skills/`) |
| `--skills <names>` | Comma-separated skill names |
| `--all` | Add all skills from the source |
| `--claude` | Target `.claude/skills/` only |
| `--codex` | Target `.agents/skills/` only |
| `--force` | Overwrite if skill already exists |

Default: targets both tools if their config directories exist,
otherwise defaults to Claude Code.

**Before running:** Confirm the action with the user if they
haven't already specified exact skills. State which skills
will be added and where.

### Removing Skills

```bash
scripts/remove_skills.sh --skills name1,name2 [--claude] [--codex]
```

Remove all project skills:

```bash
scripts/remove_skills.sh --all [--claude] [--codex]
```

List installed project skills:

```bash
scripts/remove_skills.sh --list [--claude] [--codex]
```

**Before running:** Always confirm removal with the user.
List which skills will be removed.

## Step 5: Confirm Result

After the script runs, report:

- Which skills were added or removed
- Which target directories were affected
- Any warnings (skill already existed, skill not found, etc.)

## Edge Cases

- **No skill sources found** — inform the user. Suggest providing
  a path or cloning a skill repository.
- **Skill already installed** — the script warns and skips unless
  `--force` is used. Ask the user if they want to overwrite.
- **Skill not found for removal** — the script reports which
  skills were not found and removes the rest.
- **Project config directory missing** — the add script creates
  `.claude/skills/` or `.agents/skills/` automatically.
- **User asks for global install** — explain that this skill
  manages project-level skills only. Point to the repository's
  `install.sh` for global installs.
