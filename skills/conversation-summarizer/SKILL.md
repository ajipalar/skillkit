---
name: conversation-summarizer
description: >-
  Summarize AI text conversations into structured, actionable overviews.
  Use when a user provides a conversation log, chat export, or dialogue
  transcript and wants a summary. Supports multiple formats: JSON logs
  with turn-based structure, ChatGPT/Claude exports, OpenAI API message
  arrays, JSONL chat logs, and plain-text transcripts with role markers.
  Triggers on requests like "summarize this conversation," "give me an
  overview of this chat," "extract key decisions from this dialogue,"
  or "what action items came out of this conversation."
---

# Conversation Summarizer

Summarize AI text conversations into structured, multi-level overviews.

## Workflow

1. Detect the conversation format
2. Parse the conversation into a normalized turn sequence
3. Generate the requested summary level(s)
4. Present the summary

## Step 1: Detect and Parse the Conversation Format

Identify the format by examining the input structure. See
[references/format-detection.md](references/format-detection.md)
for format signatures and parsing guidance.

**Normalized turn structure** (internal representation after parsing):

Each turn should resolve to:

- `role`: "user", "assistant", or "system"
- `content`: The substantive text of the turn
- `turn_number`: Sequential position in conversation
- `metadata`: Any additional fields (timestamps, actions, tool calls)

If the format is unrecognized, inform the user and ask for
clarification about the structure. Do not guess.

## Step 2: Generate Summary

Determine which summary levels to produce based on the user's request.
If the user does not specify, default to producing all applicable levels.

### Level 1: High-Level Overview

Produce a single paragraph (3-5 sentences) capturing:

- What the conversation was about (topic/goal)
- The main outcome or conclusion
- The overall arc (e.g., "exploration -> decision -> implementation")

### Level 2: Key Decisions and Outcomes

Extract a bulleted list of decisions made, conclusions reached,
or significant turning points. For each decision:

- State the decision clearly
- Note which turn(s) it emerged from
- Note any alternatives that were considered and rejected

### Level 3: Action Items and Follow-ups

Extract concrete next steps, tasks, or commitments. For each:

- State the action item
- Note who is responsible (user or assistant) if discernible
- Note any deadlines or conditions mentioned

### Level 4: Per-Turn Summary

Produce a sequential summary with one entry per meaningful turn:

- Skip turns that are purely procedural (e.g., "OK", "thanks")
- Consolidate adjacent turns from the same role when they form
  a single logical unit
- Keep each entry to 1-2 sentences

## Handling Edge Cases

- **Very long conversations (50+ turns)**: Group turns into phases
  or topics before summarizing. Identify natural breakpoints where
  the conversation shifted focus.
- **Multi-topic conversations**: Organize summaries by topic rather
  than strictly chronologically. Note where topics interleave.
- **Conversations with code/technical content**: Summarize the intent
  and outcome of code blocks rather than reproducing code. Note file
  paths, function names, and key technical decisions.
- **Conversations with tool use/actions**: Summarize tool invocations
  by their purpose and result, not by the raw tool call syntax.
- **Incomplete or truncated conversations**: Note that the conversation
  appears truncated and summarize only what is present.

## Output Format

Present summaries in clean markdown. Use this structure, adapting
sections based on what the user requested:

```markdown
# Conversation Summary

## Overview
[Level 1 content]

## Key Decisions
[Level 2 content]

## Action Items
[Level 3 content]

## Turn-by-Turn Summary
[Level 4 content]
```

If the user requests only specific levels, produce only those sections.
If the conversation metadata includes a date or project name, include
it in the header.
