---
name: addressing-comments
description: Use when the user asks to address, resolve, answer, or respond to COMMENT: markers left in a spec, plan, design doc, or other .md file. Triggers on requests like "address my comments", "resolve the comments in the plan", "respond to the COMMENT/ANSWER blocks", or reviewing a doc that contains COMMENT:, ANSWER:, ACCEPTED, or REJECTED: fields.
---

# Addressing Comments

## Overview

A reviewer leaves inline notes in a spec or plan as `COMMENT:` fields. Your job is to
respond to each one in an `ANSWER:` field, apply the ones the reviewer has accepted, and
keep answering the ones they have pushed back on — without touching anything else in the
document.

**Core constraint:** the only prose you may write is `ANSWER:` text. The single exception
is applying an `ACCEPTED` comment's resolution to the rest of the document. Never revise,
reword, or "improve" any other part of the doc.

## Marker grammar

Markers are plain text at the start of a line:

- `COMMENT:` — a reviewer note. Begins a comment chain.
- `ANSWER:` — a response to the most recent comment or rejection.
- `ACCEPTED` — the reviewer accepts the preceding answer (keyword alone, no text needed).
- `REJECTED:` — the reviewer rejects the preceding answer; text after it explains why.

A **chain** is one `COMMENT:` plus the alternating `ANSWER:` / disposition entries that
follow it, up to the next `COMMENT:` or the end of the document. A chain can grow long:

```
COMMENT: This timeout seems too short.
ANSWER: Increased to 30s to allow for cold starts.
REJECTED: 30s is still too short for batch jobs.
ANSWER: Made it configurable; default 120s.
```

## The procedure

1. Confirm which file to work on (ask if the user did not name one).
2. Find every `COMMENT:` in the file and identify each chain.
3. For each chain, look at its **terminal state** (the last marker) and act per the table below.
4. After processing all chains, report results and the implementation gate (see below).

### Decide by the chain's terminal state

| Chain ends with… | Do this | Outcome |
|---|---|---|
| `ACCEPTED` | Remove the **entire** chain, then edit the rest of the document so it reflects the accepted resolution (described by the final `ANSWER:`, in service of the original `COMMENT:`). | Resolved — chain removed |
| `REJECTED: <reason>` (no answer after it) | Append a new `ANSWER:` that directly addresses the rejection reason. | Stays — still dangling |
| `COMMENT:` (no answer yet) | Append an `ANSWER:`. If you cannot answer confidently without a decision or information only the user has, **write the ANSWER as a question back to the user**. | Stays — still dangling |
| `ANSWER:` (no disposition after it) | Leave it untouched — the reviewer has not yet accepted or rejected. | Stays — still dangling |

### Applying an ACCEPTED comment

"Accepted" means the reviewer agreed with the resolution in the final `ANSWER:`. To apply it:

1. Implement that resolution in the document body — update the affected sections, tables,
   lists, or steps so the doc now says what the answer promised.
2. Delete the whole comment chain (the `COMMENT:`, every `ANSWER:`, and every `ACCEPTED`/
   `REJECTED:` line in it).
3. Make these edits autonomously, then summarize: what chain you removed and which sections
   you changed. Do not ask for approval first.

### Writing a good ANSWER

- Address the comment directly and concretely; do not restate it.
- When uncertain, the answer is a question — make it specific enough that one reply unblocks it.
- When answering a `REJECTED:`, treat the rejection text as the spec for what to fix. Do not
  repeat the rejected answer; resolve the objection.

## The implementation gate

A spec or plan with any remaining comment chain is **not ready to implement**. After a pass,
always report:

- Comments answered (new `ANSWER:` written)
- Comments re-answered after a rejection
- Comments accepted and applied (with a one-line summary of each doc change)
- **Dangling comments still in the document** — count and line references

Then state plainly: while dangling comments remain, the spec/plan must not proceed to
implementation. If the user asks to implement anyway, surface the dangling comments first.

## Common mistakes

| Mistake | Fix |
|---|---|
| Editing doc prose while merely *answering* a comment | Only `ACCEPTED` comments let you touch other prose. Answering = write `ANSWER:` only. |
| Removing a `COMMENT:`/`ANSWER:` pair that has no `ACCEPTED` | Only remove a chain whose terminal state is `ACCEPTED`. |
| Re-answering a chain that already ends in an unaccepted `ANSWER:` | If it ends with `ANSWER:` and no disposition, leave it alone. |
| Ignoring the `REJECTED:` text and repeating the old answer | The rejection text is the requirement for the new answer. |
| Inventing an answer when you lack the needed decision | Write the `ANSWER:` as a precise question to the user instead. |
| Declaring the plan ready while comments remain | Any remaining chain blocks implementation. Report it. |
