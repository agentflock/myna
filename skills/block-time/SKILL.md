---
name: block-time
disable-model-invocation: true
description: Create personal calendar time blocks and reminders. Finds free slots, proposes options, user confirms before any calendar write — no attendees, ever. Does not handle meeting prep or scheduling with others.
user-invocable: true
argument-hint: "reserve [duration] [when] for [what] | remind me [what] at [time]"
---

If vault_path is not in context, read `~/.myna/config.yaml` first. If the file does not exist, tell the user to run `/myna:setup` and stop.

# block-time

Creates personal calendar events — time blocks and reminders. Every calendar write is personal-only — no attendees, ever.

---

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

Event type labels (`[Myna:Focus]`, `[Myna:Reminder]`) and the base prefix (`[Myna]`) are configurable in workspace.yaml.

**Step 4: Create the event**

Only after explicit user confirmation. Apply the three-layer calendar protection from the safety steering skill: verify no attendees and title has configured prefix before calling the MCP tool. If either check fails, stop and report.

Call the calendar MCP to create the event with:
- `title`: `[Myna:Focus] {purpose}` (using configured type label)
- `start`: ISO datetime
- `end`: ISO datetime
- `description`: optional context about the task
- **No attendees field — never.**

If creation succeeds, confirm: "✅ Time block created: {title}, {day} {start}–{end}."

---

## Calendar Reminders

**Triggers:** "remind me about the design review at 2pm", "remind me to call Alice at 3pm", "set a reminder for the deployment window at 11 AM"

### Two Reminder Types

**Task reminder:** "Remind me about [task] at [time]" — the reminder is linked to an existing task or event. Title includes the task name.

**Standalone reminder:** "Remind me to [action] at [time]" — no linked vault task. Just a calendar notification.

### How It Works

**Step 1: Parse the request**

Extract: what to be reminded about, when (time today or specific datetime), and whether it links to a vault task.

If "at 2pm" is ambiguous (today or tomorrow?), assume today if the time hasn't passed, otherwise tomorrow. Confirm in the output.

**Step 2: Confirm details**

```
⏰ Proposed reminder:
Title: [Myna:Reminder] {what}
When: {day}, {time} ({duration}: 15 min)
No attendees.

Create this reminder? (yes / cancel)
```

Reminders default to 15-minute duration (enough for the calendar app to send a notification). Duration is not configurable in this skill.

**Step 3: Create the event**

Same three-layer protection as time blocks. No attendees. On success: "✅ Reminder set: {what} at {time}."

---

## Edge Cases

**Calendar MCP unavailable:** For time blocks and reminders, inform the user and stop. "Calendar MCP is unavailable — can't check free slots or create events. Try again when it's connected."

**No free slots of requested duration:** "No {duration}-hour slots available on {day}. Closest options: {slot-A} ({shorter-duration}), or {next-available-day} for a full {duration}-hour block."

**Ambiguous request — day not specified:** Ask before proceeding. "Which day? (or say 'find the best time this week' and I'll scan the week)"

**Duration exceeds work day:** "That's {N} hours — longer than your work day. Want multiple shorter blocks instead?"

**User specifies an already-booked time:** Show what's on the calendar at that time and offer the nearest free slots instead. Don't overwrite existing events.
