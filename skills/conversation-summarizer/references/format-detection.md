# Conversation Format Detection

Identify the conversation format by examining structural signatures,
then normalize to the standard turn sequence.

## JSON Turn-Based Log

**Signature**: Top-level object with `metadata` and `conversation` array.
Each entry has `turn`, `role`, and content fields.

**Example**:

```json
{
  "metadata": { "project": "...", "date": "..." },
  "conversation": [
    { "turn": 1, "role": "user", "content": "..." },
    { "turn": 2, "role": "assistant", "summary": "...", "actions": [...] }
  ]
}
```

**Parsing notes**:

- Content may be in `content`, `summary`, or distributed across
  `actions`, `question`, `answer`, `topics`, `findings`
- Concatenate all substantive fields for the normalized `content`
- Preserve structured fields (`actions`, `findings`, `topics`) in `metadata`

## ChatGPT Export (JSON)

**Signature**: Array of conversation objects, each with a `mapping`
field containing message nodes, or a flat `messages` array with
`author` and `content` fields.

**Parsing notes**:

- `author.role` maps to role ("user", "assistant", "system")
- `content.parts` is an array; join parts into a single string
- Messages may include `metadata` with timestamps and model info

## OpenAI API Messages Format

**Signature**: Array of objects each with `role` and `content`.
Roles: "system", "user", "assistant".

**Parsing notes**:

- Directly maps to normalized structure
- May include `function_call` or `tool_calls` on assistant messages
- System messages are setup/context; summarize separately

## Claude Export

**Signature**: JSON with `chat_messages` array. Each message has
`sender` ("human" or "assistant") and `text` fields.

**Parsing notes**:

- Map "human" to "user"
- May include `attachments` array and `files` references

## JSONL Format

**Signature**: One JSON object per line. Each line typically has
`role` and `content` (or similar fields).

**Parsing notes**:

- Parse line by line
- Validate each line is valid JSON independently
- Fall back to plain text parsing if lines are not valid JSON

## Plain Text Transcript

**Signature**: Text with role markers. Common patterns:

- `User:` / `Assistant:` prefix per message
- `Human:` / `AI:` prefix
- `[user]` / `[assistant]` bracket notation
- Blank line or `---` separating turns

**Parsing notes**:

- Identify the role marker pattern from the first few lines
- Split on role markers to extract turns
- Handle multi-line messages (content continues until next role marker)
- If no clear role markers, ask the user to clarify the format

## Unrecognized Format

If none of the above signatures match:

1. Report to the user that the format was not automatically recognized
2. Show a brief excerpt of the input structure
3. Ask the user to describe the format or identify which known
   format it most closely resembles
