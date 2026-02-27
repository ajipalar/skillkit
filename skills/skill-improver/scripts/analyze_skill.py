#!/usr/bin/env python3
"""
Structural analysis script for skills.
Performs automated, mechanical checks and reports quantitative data.
Qualitative evaluation is left to the agent using the rubric.
"""

import sys
import os
import re
import yaml
from pathlib import Path


def parse_frontmatter(content):
    """Extract and parse YAML frontmatter from SKILL.md content.

    Handles files that have comment lines (starting with #) before
    the --- frontmatter delimiter.
    """
    # Strip leading comment lines (e.g., attribution headers)
    stripped = content
    while stripped.startswith("#"):
        newline = stripped.find("\n")
        if newline == -1:
            break
        stripped = stripped[newline + 1:]

    if not stripped.startswith("---"):
        return None, "No YAML frontmatter found"
    match = re.match(r"^---\n(.*?)\n---", stripped, re.DOTALL)
    if not match:
        return None, "Invalid frontmatter format"
    try:
        fm = yaml.safe_load(match.group(1))
        if not isinstance(fm, dict):
            return None, "Frontmatter must be a YAML dictionary"
        return fm, None
    except yaml.YAMLError as e:
        return None, f"Invalid YAML: {e}"


def extract_markdown_links(content):
    """Extract markdown links from content, skipping fenced code blocks."""
    # Remove fenced code blocks before extracting links
    stripped = re.sub(r"```.*?```", "", content, flags=re.DOTALL)
    return re.findall(r"\[([^\]]*)\]\(([^)]+)\)", stripped)


def analyze_skill(skill_path):
    """Analyze a skill directory and return a structured report."""
    skill_path = Path(skill_path).resolve()
    results = []

    def record(section, check, status, detail=""):
        results.append((section, check, status, detail))

    # --- SKILL.md existence ---
    skill_md = skill_path / "SKILL.md"
    if not skill_md.exists():
        record("STRUCTURE", "SKILL.md exists", "FAIL", "SKILL.md not found")
        return results

    record("STRUCTURE", "SKILL.md exists", "PASS")
    content = skill_md.read_text()
    lines = content.splitlines()
    line_count = len(lines)

    # --- Frontmatter ---
    fm, err = parse_frontmatter(content)
    if err:
        record("FRONTMATTER", "Valid frontmatter", "FAIL", err)
    else:
        record("FRONTMATTER", "Valid frontmatter", "PASS")

        # Required fields
        ALLOWED = {"name", "description", "license", "allowed-tools", "metadata", "compatibility"}
        unexpected = set(fm.keys()) - ALLOWED
        if unexpected:
            record("FRONTMATTER", "No unexpected keys", "WARN", f"Unexpected: {', '.join(sorted(unexpected))}")
        else:
            record("FRONTMATTER", "No unexpected keys", "PASS")

        name = fm.get("name", "")
        if not name:
            record("FRONTMATTER", "Name present", "FAIL", "Missing 'name' field")
        elif not re.match(r"^[a-z0-9]+(-[a-z0-9]+)*$", str(name)):
            record("FRONTMATTER", "Name format", "FAIL", f"'{name}' is not valid kebab-case")
        elif len(str(name)) > 64:
            record("FRONTMATTER", "Name length", "FAIL", f"{len(str(name))} chars (max 64)")
        else:
            record("FRONTMATTER", "Name valid", "PASS", str(name))

        desc = fm.get("description", "")
        if not desc:
            record("FRONTMATTER", "Description present", "FAIL", "Missing 'description' field")
        else:
            desc_len = len(str(desc))
            if desc_len < 50:
                record("FRONTMATTER", "Description length", "WARN", f"{desc_len} chars (recommend >= 50)")
            elif desc_len > 1024:
                record("FRONTMATTER", "Description length", "FAIL", f"{desc_len} chars (max 1024)")
            else:
                record("FRONTMATTER", "Description length", "PASS", f"{desc_len} chars")

    # --- Line count ---
    if line_count > 500:
        record("SIZE", "SKILL.md line count", "WARN", f"{line_count} lines (recommend <= 500)")
    else:
        record("SIZE", "SKILL.md line count", "PASS", f"{line_count} lines")

    # --- Body content after frontmatter ---
    # Strip leading comment lines before looking for frontmatter end
    body_content = content
    while body_content.startswith("#"):
        newline = body_content.find("\n")
        if newline == -1:
            break
        body_content = body_content[newline + 1:]
    body_match = re.match(r"^---\n.*?\n---\n?(.*)", body_content, re.DOTALL)
    body = body_match.group(1) if body_match else content
    word_count = len(body.split())
    if word_count > 5000:
        record("SIZE", "Body word count", "WARN", f"{word_count} words (recommend <= 5000)")
    else:
        record("SIZE", "Body word count", "PASS", f"{word_count} words")

    # --- File structure ---
    all_files = []
    for root, dirs, files in os.walk(skill_path):
        # Skip hidden directories
        dirs[:] = [d for d in dirs if not d.startswith(".")]
        for f in files:
            if not f.startswith("."):
                rel = os.path.relpath(os.path.join(root, f), skill_path)
                all_files.append(rel)

    dirs_present = set()
    for f in all_files:
        parts = Path(f).parts
        if len(parts) > 1:
            dirs_present.add(parts[0])

    record("FILES", "Directories", "INFO", ", ".join(sorted(dirs_present)) if dirs_present else "none")
    record("FILES", "Total files", "INFO", str(len(all_files)))

    # Extraneous files
    EXTRANEOUS = {"README.md", "INSTALLATION_GUIDE.md", "QUICK_REFERENCE.md", "CHANGELOG.md", "CONTRIBUTING.md", "SETUP.md"}
    found_extraneous = [f for f in all_files if os.path.basename(f) in EXTRANEOUS]
    if found_extraneous:
        record("FILES", "Extraneous files", "WARN", ", ".join(found_extraneous))
    else:
        record("FILES", "Extraneous files", "PASS", "none detected")

    # --- Internal link integrity ---
    links = extract_markdown_links(body)
    relative_links = [(text, href) for text, href in links if not href.startswith(("http://", "https://", "#", "mailto:"))]

    if relative_links:
        valid_links = 0
        broken_links = []
        for text, href in relative_links:
            target = skill_path / href
            if target.exists():
                valid_links += 1
            else:
                broken_links.append(href)

        if broken_links:
            record("REFERENCES", "Link integrity", "FAIL", f"Broken: {', '.join(broken_links)}")
        else:
            record("REFERENCES", "Link integrity", "PASS", f"{valid_links}/{len(relative_links)} links valid")
    else:
        record("REFERENCES", "Link integrity", "INFO", "No internal links found")

    # --- Unlinked reference files ---
    ref_dir = skill_path / "references"
    if ref_dir.exists() and ref_dir.is_dir():
        ref_files = [f.name for f in ref_dir.iterdir() if f.is_file() and not f.name.startswith(".")]
        linked_refs = {href for _, href in relative_links if href.startswith("references/")}
        linked_basenames = {Path(h).name for h in linked_refs}
        unlinked = [f for f in ref_files if f not in linked_basenames
                    and f"references/{f}" not in {h for _, h in relative_links}]
        if unlinked:
            record("REFERENCES", "Unlinked reference files", "WARN", ", ".join(unlinked))
        else:
            record("REFERENCES", "All references linked", "PASS")
    else:
        record("REFERENCES", "References directory", "INFO", "No references/ directory")

    # --- Scripts check ---
    scripts_dir = skill_path / "scripts"
    if scripts_dir.exists() and scripts_dir.is_dir():
        scripts = [f for f in scripts_dir.iterdir() if f.is_file() and not f.name.startswith(".")]
        record("SCRIPTS", "Scripts found", "INFO", str(len(scripts)))
        for s in scripts:
            if os.access(s, os.X_OK):
                record("SCRIPTS", f"{s.name} executable", "PASS")
            else:
                record("SCRIPTS", f"{s.name} executable", "WARN", "Not marked executable")
    else:
        record("SCRIPTS", "Scripts directory", "INFO", "No scripts/ directory")

    return results


def format_report(skill_path, results):
    """Format analysis results as a readable report."""
    skill_name = Path(skill_path).name
    lines = [f"=== Skill Analysis: {skill_name} ===", ""]

    current_section = None
    pass_count = 0
    warn_count = 0
    fail_count = 0

    for section, check, status, detail in results:
        if section != current_section:
            if current_section is not None:
                lines.append("")
            lines.append(section)
            current_section = section

        if status == "PASS":
            pass_count += 1
        elif status == "WARN":
            warn_count += 1
        elif status == "FAIL":
            fail_count += 1

        detail_str = f": {detail}" if detail else ""
        lines.append(f"  {check}: {status}{detail_str}")

    lines.append("")
    lines.append(f"SUMMARY: {fail_count} FAIL, {warn_count} WARN, {pass_count} PASS")
    return "\n".join(lines)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python analyze_skill.py <skill-directory>")
        sys.exit(1)

    skill_dir = sys.argv[1]
    if not os.path.isdir(skill_dir):
        print(f"Error: '{skill_dir}' is not a directory")
        sys.exit(1)

    results = analyze_skill(skill_dir)
    print(format_report(skill_dir, results))
