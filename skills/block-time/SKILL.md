---
name: block-time
description: Create personal calendar time blocks — focus time, task blocks, deep work. Finds free slots, proposes options, confirms before any write — no attendees, ever. For reminders, use /myna:reminder. Does not handle meeting prep or scheduling others.
user-invocable: true
argument-hint: "reserve [duration] [when] for [what] | block [duration] on [day] for [purpose] | find me a slot for [task]"
---

If vault_path is not in context, read `~/.myna/config.yaml` first. If the file does not exist, tell the user to run `/myna:setup` and stop.

# block-time

Creates personal calendar time blocks — focus time, task slots, deep work. Every calendar write is personal-only — no attendees, ever. For reminders, use /myna:reminder.

---

**Intent check:** Before reading an external source (email/Slack/calendar) or making your first vault write — proceed only if the user's request addressed Myna (contains "myna") or explicitly named this action. Otherwise, confirm intent before proceeding.


## Time Block Planning

**Triggers:** "reserve 2 hours Thursday for the design doc", "block 3 hours this week for deep work", "find me a good slot for [task]"

Use `/myna:plan` for general planning and prioritization advice. This skill handles only specific blocking requests.

### How It Works

**Step 1: Determine scope and duration**

Extract duration (required), when (day, "this week", "morning", etc.), and purpose.

**Step 2: Find available slots**

Read workspace.yaml for `work_hours.start`, `work_hours.end`, and `timezone`. Query the calendar MCP for events in the target window. Identify contiguous free slots of at least the requested duration.

**For a specific day:** List up to 3 available slots that fit. If the day has no slots of the requested size, say so and offer the closest alternatives (shorter slot today, or the requested size on an adjacent day).

**For "this week" or "find a good time":** Scan Monday–Friday within work hours. Present up to 3 available slots in chronological order. Let the user pick. Do not pick for them.

**Step 3: Confirm event details**

Show all parameters before creating:

```
📅 Proposed time block:
Title: [Myna:Focus] {purpose}
When: {day}, {start time}–{end time} ({duration})
No attendees.

Create this event? (yes / pick a different slot / cancel)
```

Event type labels and the base prefix are hardcoded: `[Myna]`, `[Myna:Focus]`.

**Step 4: Create the event**

Only after explicit user confirmation. Apply the three-layer calendar protection from the safety steering skill: verify no attendees and title has hardcoded prefix `[Myna]` before calling the MCP tool. If either check fails, stop and report.

Call the calendar MCP to create the event with:
- `title`: `[Myna:Focus] {purpose}`
- `start`: ISO datetime
- `end`: ISO datetime
- `description`: optional context about the task
- **No attendees field — never.**

If creation succeeds, confirm: "✅ Time block created: {title}, {day} {start}–{end}."

---

## Edge Cases

**Calendar MCP unavailable:** Inform the user and stop. "Calendar MCP is unavailable — can't check free slots or create events. Try again when it's connected."

**Reminder request:** This skill does not handle reminders. Say: "For reminders, use /myna:reminder." Do not attempt to process reminder requests here.

**No free slots of requested duration:** "No {duration}-hour slots available on {day}. Closest options: {slot-A} ({shorter-duration}), or {next-available-day} for a full {duration}-hour block."

**Ambiguous request — day not specified:** Ask before proceeding. "Which day? (or say 'find the best time this week' and I'll scan the week)"

**Duration exceeds work day:** "That's {N} hours — longer than your work day. Want multiple shorter blocks instead?"

**User specifies an already-booked time:** Show what's on the calendar at that time and offer the nearest free slots instead. Don't overwrite existing events.
