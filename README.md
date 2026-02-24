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
│   ├── core/              # General-purpose skills
│   ├── compbio/           # Computational biology skills
│   └── meta/              # Meta-skills (skills about building skills)
│       └── skill-creator/ # How to create effective skills
├── template/              # Blank SKILL.md template for new skills
├── LICENSE                # MIT
├── THIRD_PARTY_NOTICES.md # Attribution for third-party content
└── README.md
```

## Skill Categories

### Core (`skills/core/`)

General-purpose skills broadly useful across domains. Examples: web research, blog writing, document creation, code review workflows.

### Computational Biology (`skills/compbio/`)

Domain-specific skills for comp bio workflows. Examples: bioinformatics pipelines, literature review and synthesis, data analysis, scientific writing, structural biology tools.

### Meta (`skills/meta/`)

Skills about building, evaluating, and iterating on other skills. These are first-class members of the project — they make skillkit self-documenting and help contributors write better skills.

The **skill-creator** meta-skill is included out of the box. It provides a comprehensive guide for creating effective skills, including initialization scripts, validation tools, and reference documentation on output patterns and workflows.

## Getting Started

### Using a Skill

Point your AI agent at any `SKILL.md` file. Most agent frameworks support loading instruction files directly. The agent reads the frontmatter to understand when the skill applies, then follows the markdown instructions.

### Creating a New Skill

1. Copy `template/SKILL.md` into a new directory under the appropriate category:
   ```bash
   mkdir skills/core/my-new-skill
   cp template/SKILL.md skills/core/my-new-skill/SKILL.md
   ```

2. Or use the skill-creator's initialization script:
   ```bash
   python skills/meta/skill-creator/scripts/init_skill.py my-new-skill --path skills/core
   ```

3. Edit the `SKILL.md` with your skill's name, description, and instructions.

4. Validate your skill:
   ```bash
   python skills/meta/skill-creator/scripts/quick_validate.py skills/core/my-new-skill
   ```

For detailed guidance on writing effective skills, see [`skills/meta/skill-creator/SKILL.md`](skills/meta/skill-creator/SKILL.md).

## Attribution

The `skill-creator` meta-skill and the `template/SKILL.md` are sourced from [Anthropic's skills repository](https://github.com/anthropics/skills) and redistributed under the Apache License 2.0. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for details.

## License

This project is licensed under the [MIT License](LICENSE).

Individual skills may carry their own licenses. Check each skill's directory for a `LICENSE.txt` if present.
