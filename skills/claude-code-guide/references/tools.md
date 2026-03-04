# Built-in Tools Reference

## Table of Contents

- [File Operations](#file-operations) (Read, Write, Edit)
- [Search Tools](#search-tools) (Grep, Glob)
- [Execution](#execution) (Bash)
- [Agent Tools](#agent-tools) (Task, TodoWrite)
- [Web Tools](#web-tools) (WebFetch, WebSearch)
- [Other Tools](#other-tools) (AskUserQuestion, EnterPlanMode, EnterWorktree)
- [Tool Selection Guidelines](#tool-selection-guidelines)

## File Operations

### Read

Read file contents from the local filesystem.

| Parameter | Required | Description |
|-----------|----------|-------------|
| `file_path` | Yes | Absolute path to the file |
| `offset` | No | Line number to start from |
| `limit` | No | Number of lines to read |
| `pages` | No | Page range for PDFs (e.g., "1-5") |

Key behaviors:
- Reads up to 2000 lines by default
- Lines longer than 2000 characters are truncated
- Returns content with line numbers (cat -n format)
- Supports images (PNG, JPG — displayed visually), PDFs (max 20 pages per request), and Jupyter notebooks
- Cannot read directories — use `ls` via Bash or Glob instead
- Must read a file before editing it with Edit or overwriting with Write

### Write

Create or overwrite a file.

| Parameter | Required | Description |
|-----------|----------|-------------|
| `file_path` | Yes | Absolute path (must be absolute, not relative) |
| `content` | Yes | Full file content |

Key behaviors:
- Overwrites the entire file if it exists
- Must Read an existing file first before overwriting
- Creates parent directories as needed
- Prefer Edit for targeted changes to existing files

### Edit

Perform exact string replacements in an existing file.

| Parameter | Required | Description |
|-----------|----------|-------------|
| `file_path` | Yes | Absolute path to the file |
| `old_string` | Yes | Exact text to find and replace |
| `new_string` | Yes | Replacement text |
| `replace_all` | No | Replace all occurrences (default: false) |

Key behaviors:
- Fails if `old_string` is not unique in the file (unless `replace_all` is true)
- Provide more surrounding context to make `old_string` unique
- Must Read the file first before editing
- Preserve exact indentation from the file

## Search Tools

### Grep

Search file contents using regular expressions. Built on ripgrep.

| Parameter | Required | Description |
|-----------|----------|-------------|
| `pattern` | Yes | Regex pattern to search for |
| `path` | No | File or directory to search in |
| `glob` | No | Glob pattern to filter files (e.g., `"*.js"`) |
| `type` | No | File type filter (e.g., `"js"`, `"py"`, `"rust"`) |
| `output_mode` | No | `"files_with_matches"` (default), `"content"`, `"count"` |
| `-A`, `-B`, `-C` | No | Lines of context after/before/around matches |
| `multiline` | No | Enable cross-line pattern matching |
| `head_limit` | No | Limit output to first N results |

Key behaviors:
- Always use Grep instead of `bash grep` or `bash rg`
- Default output mode returns only file paths
- Use `output_mode: "content"` to see matching lines
- Literal braces need escaping: `interface\{\}` to find `interface{}`

### Glob

Find files by name pattern.

| Parameter | Required | Description |
|-----------|----------|-------------|
| `pattern` | Yes | Glob pattern (e.g., `"**/*.ts"`, `"src/**/*.test.js"`) |
| `path` | No | Directory to search in |

Key behaviors:
- Returns matching file paths sorted by modification time
- Always use instead of `bash find` or `bash ls`
- Works efficiently with any codebase size

## Execution

### Bash

Execute shell commands with optional timeout.

| Parameter | Required | Description |
|-----------|----------|-------------|
| `command` | Yes | Shell command to execute |
| `description` | No | Short description of what the command does |
| `timeout` | No | Timeout in ms (default: 120000, max: 600000) |
| `run_in_background` | No | Run asynchronously, check output later |

Key behaviors:
- Working directory persists between calls; shell state does not
- Avoid for file operations — use Read/Write/Edit/Grep/Glob instead
- Quote paths with spaces: `cd "/path with spaces/"`
- Chain dependent commands with `&&`
- Use `run_in_background: true` for long-running processes
- Output truncated at 30000 characters

## Agent Tools

### Task

Launch a subagent to handle complex sub-tasks autonomously.

| Parameter | Required | Description |
|-----------|----------|-------------|
| `description` | Yes | Short (3-5 word) summary shown in progress |
| `prompt` | Yes | Full task instructions for the subagent |
| `subagent_type` | Yes | Agent type to use |

Subagent types include: `Bash`, `general-purpose`, `Explore`, `Plan`,
and any custom agents defined in `.claude/agents/` or `~/.claude/agents/`.

Key behaviors:
- Each subagent gets an isolated context window
- Multiple Task calls in the same response run in parallel
- Subagent results are returned to the parent
- Use `run_in_background: true` for independent background work
- Use `isolation: "worktree"` for git-isolated work

See `agents-and-subagents.md` for detailed patterns.

### TodoWrite

Create and manage structured task lists.

| Parameter | Required | Description |
|-----------|----------|-------------|
| `todos` | Yes | Array of `{content, status, activeForm}` objects |

Status values: `pending`, `in_progress`, `completed`.

Key behaviors:
- Use for tasks requiring 3+ steps
- Keep exactly one task `in_progress` at a time
- Mark tasks completed immediately after finishing
- `content` is imperative form ("Run tests"), `activeForm` is progressive ("Running tests")

## Web Tools

### WebFetch

Fetch and process web content.

| Parameter | Required | Description |
|-----------|----------|-------------|
| `url` | Yes | URL to fetch |
| `prompt` | Yes | What to extract from the page |

Key behaviors:
- Fetches URL, converts HTML to markdown, processes with a small model
- 15-minute cache for repeated requests
- HTTP auto-upgraded to HTTPS
- If an MCP web fetch tool exists, prefer that instead

### WebSearch

Search the web for current information.

| Parameter | Required | Description |
|-----------|----------|-------------|
| `query` | Yes | Search query |
| `allowed_domains` | No | Only include results from these domains |
| `blocked_domains` | No | Exclude results from these domains |

Key behaviors:
- Returns search results with links
- Must include a "Sources:" section with URLs in response
- Use for information beyond the training cutoff

## Other Tools

### AskUserQuestion
Prompt the user for input during execution. Supports single-select and
multi-select questions with 2-4 options.

### EnterPlanMode
Transition to planning mode for non-trivial implementation tasks.
Allows codebase exploration before committing to an approach.

### EnterWorktree
Create an isolated git worktree. Only use when the user explicitly
says "worktree."

### NotebookEdit
Edit Jupyter notebook cells. Supports replace, insert, and delete modes.

## Tool Selection Guidelines

| Scenario | Correct Tool | Wrong Tool |
|----------|-------------|------------|
| Read file contents | Read | `bash cat` |
| Search for text in files | Grep | `bash grep` or `bash rg` |
| Find files by name | Glob | `bash find` |
| Edit part of a file | Edit | `bash sed` |
| Create a new file | Write | `bash echo >` |
| Run a test suite | Bash | — |
| Explore a large codebase | Task (Explore) | Many sequential Grep calls |
| Track multi-step work | TodoWrite | — |
