# skillkit

A model-agnostic, open-source collection of skills for AI agents and agentic workflows.

## What is a Skill?

A **skill** is a structured instruction file (`SKILL.md`) that gives an AI agent the best practices, context, and procedures it needs to complete a specific type of task. Skills act as onboarding guides for agents — teaching them how to perform specialized work in a repeatable way.

Each skill follows a simple convention:

```yaml
---
name: my-skill
description: What this skill does and when to use it.
---

# Instructions

Step-by-step procedures, examples, and guidelines go here.
```

The YAML frontmatter provides metadata (`name` and `description` are required). The markdown body contains the actual instructions the agent follows. Skills can also bundle scripts, reference documents, and asset files alongside the `SKILL.md`.

This format is inspired by [Anthropic's Agent Skills standard](https://agentskills.io) but is intentionally designed to work across any AI model or agent framework.

## Design Principles

- **Model-agnostic.** Skills must not rely on model-specific features or quirks. A well-written skill should work with Claude, GPT, Gemini, or any future model. Agnostic skills are more robust, more reusable, and future-proof.
- **Format-agnostic.** The project adopts the `SKILL.md` convention with YAML frontmatter — a simple format that any tool can parse. No hard dependencies on any platform's tooling.
- **Community-oriented.** Open source and designed to attract contributors across domains. Skills should be focused, well-documented, and principled.
- **Blog-integrated.** The maintainer writes about AI in computational biology. Skills that support research, writing, and web interfacing are first-class citizens. The blog and the project are a flywheel — each improves the other.

## Repository Structure

```
skillkit/
├── skills/
│   ├── skill-creator/     # Meta-skill: how to create effective skills
│   └── <your-skill>/      # Each skill is a flat directory under skills/
├── install.sh             # Installer for Claude Code, Codex CLI, etc.
├── template/              # Blank SKILL.md template for new skills
├── LICENSE                # MIT
├── THIRD_PARTY_NOTICES.md # Attribution for third-party content
└── README.md
```

Skills live directly under `skills/<skill-name>/` — no category nesting. This flat structure matches what Claude Code and Codex CLI expect when scanning for skills.

## Included Skills

### skill-creator

A meta-skill for building, evaluating, and iterating on other skills. Includes initialization scripts, validation tools, and reference documentation on output patterns and workflows.

## Installation

Clone the repository and run the installer:

```bash
git clone https://github.com/your-username/skillkit.git
cd skillkit
./install.sh
```

The interactive installer will ask where to install (global or project-local) and which tool(s) to target.

### Non-interactive usage

```bash
# Install globally for Claude Code
./install.sh --global --claude

# Install globally for Codex CLI
./install.sh --global --codex

# Install globally for all supported tools
./install.sh --global --all

# Install into the current project only
./install.sh --project --claude

# Overwrite existing installations
./install.sh --force --global --all

# Uninstall
./install.sh --uninstall --global --claude
```

### Supported tools

| Tool | Global path | Project path |
|------|-------------|--------------|
| [Claude Code](https://claude.com/claude-code) | `~/.claude/skills/` | `.claude/skills/` |
| [Codex CLI](https://github.com/openai/codex) | `~/.agents/skills/` | `.agents/skills/` |

Both tools use the same [SKILL.md format](https://agentskills.io), so each skill only needs to be written once.

**Global** installs make skills available in every project. **Project** installs scope skills to the current directory only.

### Manual installation

If you prefer not to use the script, copy any skill directory to the appropriate path:

```bash
# Example: install skill-creator globally for Claude Code
cp -R skills/skill-creator ~/.claude/skills/skill-creator

# Example: install skill-creator globally for Codex CLI
cp -R skills/skill-creator ~/.agents/skills/skill-creator
```

## Getting Started

### Using a Skill

Once installed, your AI agent automatically discovers skills in its skills directory. The agent reads each skill's frontmatter to understand when it applies, then loads the full instructions on demand. You can also invoke a skill directly as a slash command (e.g., `/skill-creator`).

### Creating a New Skill

1. Copy `template/SKILL.md` into a new directory under `skills/`:
   ```bash
   mkdir skills/my-new-skill
   cp template/SKILL.md skills/my-new-skill/SKILL.md
   ```

2. Or use the skill-creator's initialization script:
   ```bash
   python skills/skill-creator/scripts/init_skill.py my-new-skill --path skills
   ```

3. Edit the `SKILL.md` with your skill's name, description, and instructions.

4. Validate your skill:
   ```bash
   python skills/skill-creator/scripts/quick_validate.py skills/my-new-skill
   ```

5. Re-run the installer to deploy your new skill:
   ```bash
   ./install.sh --force --global --all
   ```

For detailed guidance on writing effective skills, see [`skills/skill-creator/SKILL.md`](skills/skill-creator/SKILL.md).

## Attribution

The `skill-creator` meta-skill and the `template/SKILL.md` are sourced from [Anthropic's skills repository](https://github.com/anthropics/skills) and redistributed under the Apache License 2.0. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for details.

## License

This project is licensed under the [MIT License](LICENSE).

Individual skills may carry their own licenses. Check each skill's directory for a `LICENSE.txt` if present.
