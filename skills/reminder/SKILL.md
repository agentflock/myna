---
name: reminder
disable-model-invocation: true
description: Set a vault-native reminder for a future day. Triggers on "remind me on [day] about [X]", "remind me [when] to [do X]", "set a reminder for [X] on [day]", "remind me about [X] [when]". Writes to the vault immediately — no calendar required.
user-invocable: true
argument-hint: "remind me on [day] about [what] | remind me to [do X] on [day] | set a reminder for [X] on [day]"
---

If vault_path is not in context, read `~/.myna/config.yaml` first. If the file does not exist, tell the user to run `/myna:setup` and stop.

# reminder

Creates a vault-native reminder that surfaces in the daily brief. The vault write always happens first and is independent of the calendar.

---

## How It Works

### Step 1: Parse the request

Extract:
- **What** — the reminder subject (required)
- **When** — the target day (required)
- **Time** — a clock time (optional; only when the user explicitly gave one, e.g. "at 2pm", "at 14:00")
- **Project or person** — any entity reference (optional)

**Resolve relative dates to absolute dates** using the timezone from `workspace.yaml`. Store the resolved `YYYY-MM-DD` date, never the relative reference.

| User says | Resolved to |
|-----------|-------------|
| "tomorrow" | today's date + 1 day |
| "next Monday" | the upcoming Monday (never today if today is Monday — "next" means the following week's Monday) |
| "the 20th" | the 20th of the current month if it's still upcoming, otherwise the 20th of next month |
| "Friday" | the next upcoming Friday (including today if today is Friday and the time hasn't passed) |

**Ambiguous days:** if the day cannot be resolved without guessing — for example "the 3rd" when today is the 4th and next month's 3rd is over 3 weeks away and the user may mean something else — ask once before proceeding. Never assume.

**Ambiguous time (today/tomorrow):** if a time was given and it's already past that time today, assume tomorrow. State the resolved datetime in the confirmation output.

If the user gives neither a day nor a time, ask for the day before proceeding.

### Step 2: Write the vault reminder

Read `workspace.yaml` to get `user.name`. Use it in the `[User]` provenance marker.

**Always write this step first, before any calendar action.** The vault write must succeed even when the calendar MCP is unavailable.

**Target file:** `{vault_path}/_system/data/reminders.md`

**If the file does not exist:** create it with this header before appending:

```markdown
## Reminders

```

**If the `_system/data/` folder does not exist:** create it (Claude Code's Write tool creates parent directories automatically when writing a new file).

**Append the reminder line** to the `## Reminders` section (after the header, before any other content if the file is new; at the end of the section if the file already exists):

```
- [ ] {what} 📅 {YYYY-MM-DD} [type:: reminder] [time:: {HH:MM}] [project:: [[{name}]]] [User] (remind, {today-YYYY-MM-DD})
```

**Field rules — include only fields that have values:**
- `📅 {YYYY-MM-DD}` — always present; the day the reminder fires
- `[time:: {HH:MM}]` — include only when the user gave a clock time; format 24h HH:MM
- `[project:: [[{name}]]]` — include only when a project was named; use the wiki-link form
- `[person:: [[{name}]]]` — include only when a person was named (mutually exclusive with project)
- `[User]` — always present; provenance marker
- `(remind, {today-YYYY-MM-DD})` — always present; the date the reminder was created

**Examples:**

```
- [ ] call Alice about the contract 📅 2026-06-20 [type:: reminder] [User] (remind, 2026-06-13)
- [ ] review the auth migration doc 📅 2026-06-16 [type:: reminder] [time:: 14:00] [project:: [[Auth Migration]]] [User] (remind, 2026-06-13)
- [ ] send Sarah the Q2 numbers 📅 2026-06-14 [type:: reminder] [time:: 09:00] [person:: [[Sarah Chen]]] [User] (remind, 2026-06-13)
```

### Step 3: Calendar push (time-gated)

The vault write in Step 2 is complete regardless of what happens here.

#### Case A — Clock time given

After writing the vault reminder, create a personal calendar event using three-layer calendar protection from the safety steering skill:

1. **Instruction rule:** event title must use the hardcoded prefix `[Myna:Reminder]`; no attendees ever.
2. **Pre-tool check:** before calling the calendar MCP tool, verify: (a) no attendees field is populated, (b) event title starts with `[Myna:Reminder]`.
3. **Explicit confirmation:** show event parameters and wait for approval:

```
✅ Reminder saved to vault: "{what}" on {YYYY-MM-DD} at {HH:MM}.

📅 Calendar event:
Title: [Myna:Reminder] {what}
When: {YYYY-MM-DD}, {HH:MM}–{HH:MM+15min}
No attendees.

Create this calendar event? (yes / cancel)
```

Reminders default to 15-minute duration.

Only after explicit user confirmation, call the calendar MCP to create the event with:
- `title`: `[Myna:Reminder] {what}`
- `start`: ISO datetime ({YYYY-MM-DD}T{HH:MM}:00)
- `end`: ISO datetime ({YYYY-MM-DD}T{HH:MM+15min}:00)
- No attendees field — never.

On success, confirm: "✅ Calendar event created: [Myna:Reminder] {what} at {HH:MM}."

If the calendar MCP is unavailable when a time was given, report it inline after confirming the vault write — do not fail the skill:

```
✅ Reminder saved to vault: "{what}" on {YYYY-MM-DD} at {HH:MM}.
⚠️ Calendar MCP unavailable — no calendar event created. The vault reminder will still surface in your daily brief.
```

If the calendar MCP call errors after the user confirms, report the error inline. The vault reminder stands.

#### Case B — No clock time; calendar MCP available

After writing the vault reminder, ask whether the user wants a calendar notification:

```
✅ Reminder saved to vault: "{what}" on {YYYY-MM-DD}.

Want a calendar notification for this? If so, what time? (or say "no thanks")
```

Do not block on this question — if the user dismisses or does not answer, the vault reminder is already written and complete.

If the user provides a time, proceed as Case A (confirm → create event).

#### Case C — No clock time; calendar MCP unavailable

After writing the vault reminder, confirm and stop:

```
✅ Reminder saved to vault: "{what}" on {YYYY-MM-DD}.
```

No mention of the calendar — do not surface an error for something the user didn't ask for.

---

## Output Format

Always show the vault path for the written file using both Obsidian URI and disk path so the user can navigate from the terminal:

```
✅ Reminder saved to vault: "{what}" on {YYYY-MM-DD}.
obsidian://open?vault={vault-name}&file=myna%2F_system%2Fdata%2Freminders.md
{vault_path}/_system/data/reminders.md
```

---

## Edge Cases

**Day not given:** "Remind me about the deploy" with no date — ask: "Which day should I remind you?"

**Ambiguous day:** see Step 1 resolution table. When genuinely ambiguous, ask once. Never guess between two specific days.

**Multiple reminders in one request:** "Remind me about the deploy on Monday and the retro on Wednesday" — write both vault entries sequentially, then handle calendar for both. Confirm once for the calendar events together if both have times.

**Entity resolution:** if the user says "remind me about the auth project meeting" and "auth project" is ambiguous (matches multiple projects), apply the fuzzy name resolution cascade from foundations §9.3. If still ambiguous after cascade, ask.

**User asks to list reminders:** this skill sets reminders, not lists them. Suggest: "Open `_system/data/reminders.md` in your vault, or ask for your daily brief — open reminders for today or earlier appear in the Reminders section."
