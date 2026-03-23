---
name: recap
description: "Summarize what was accomplished in the current conversation. Use when the user asks what was done, wants a progress summary, or invokes /recap."
---

# Recap

Summarize what was accomplished in this conversation.

## Output

Group actions by topic. For each item:

- What was done (one line)
- Files changed or created (if applicable)
- Status: done, in progress, or blocked

End with a **Still open** section if there is unfinished work. Omit if everything is done.

Keep it concise — no re-explaining context the user already has.
