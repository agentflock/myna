---
name: myna-unreplied-threads
description: Show what's waiting on you and what you're waiting on others for — queries reply-needed tasks across email and Slack. Invoke for "what am I waiting on?", "what's waiting for me?", "unreplied threads", "who owes me a reply?".
user-invocable: true
argument-hint: "[optional: waiting-on-me | waiting-on-them | person name]"
---

# Unreplied & Follow-up Tracker

Queries reply-needed TODOs and shows what's waiting on you versus what you're waiting on. Read-only — inline output.

The unreplied tracker is not a separate log file. It's a Dataview-backed view over TODOs with `[type:: reply-needed]`, maintained across the vault. This skill queries those tasks.

---

## How the Tracker Gets Populated

TODOs with `[type:: reply-needed]` are created during email processing, messaging processing, or email triage (via the myna-process-messages and myna-email-triage skills). Each one represents either:

- **Waiting on you:** a message received that you haven't responded to — the task description says what to reply to and who sent it
- **Waiting on them:** a message you sent where you need a response — the task description says what you're waiting on and from whom

When a reply is detected in a subsequent processing run, the corresponding TODO is marked complete. Items that age out (no reply after a long time) remain open — this is intentional, so stale waits don't silently disappear.

---

## Query

Grep for open reply-needed tasks across the vault:

```
Pattern: - \[ \] .* \[type:: reply-needed\]
Path: {vault}/{subfolder}/
```

Separate into two lists based on the task description:
- Tasks where you're waiting on someone else (descriptions like "Waiting on [person] for...", contain `[person:: {name}]`)
- Tasks where someone is waiting on you (descriptions like "Reply to [person] about...")

Use `[person:: {name}]` field when present to identify who the task is with. Fall back to reading the task description to determine direction.

---

## Mode Selection

| Trigger | Shows |
|---------|-------|
| "what am I waiting on?", "waiting on them" | Only waiting-on-them tasks |
| "what's waiting for me?", "who needs a reply?", "waiting on me" | Only waiting-on-you tasks |
| "unreplied threads", no qualifier | Both lists |
| "what am I waiting on from Sarah?" | Filter to Sarah only |

---

## Output

```
## 📬 Unreplied Threads — [date]

### ⏳ Waiting On You ([count])
[Messages received that need a reply from you]

- **[person]** — [what you need to reply to] — [age: X days] — [source: email/slack]
- **Sarah** — API spec timeline question — 2 days — email
- **James** — Budget approval request — 5 days — email
- **Alex** — Question about caching strategy — 1 day — slack #auth-team

### 🔔 Waiting On Them ([count])
[Messages you sent where you're waiting for a response]

- **[person]** — [what you sent / what you're waiting for] — [age: X days] — [source]
- **Platform Team** — API endpoint spec request — 9 days — email
- **Maya** — Q2 roadmap input request — 3 days — slack
```

Age is calculated from the due date or creation date of the TODO (whichever is available). Sort each list by age descending (oldest first).

---

## Worked Examples

### Default: both lists

**User:** "unreplied threads"

**Grep result:** 6 open tasks with `[type:: reply-needed]`

**Output:**
```
## 📬 Unreplied Threads — 2026-04-12

### ⏳ Waiting On You (3)

- **Sarah** — API spec timeline question — 2 days — email [Auth Migration]
- **James** — Budget approval for Q2 infra — 5 days — email
- **Alex** — Question about caching strategy — 1 day — slack #auth-team

### 🔔 Waiting On Them (3)

- **Platform Team** — API endpoint spec (committed Apr 8, now overdue) — 9 days — email
- **Maya** — Q2 roadmap priorities input — 3 days — slack #team-general
- **Legal** — OSS license review for new SDK dependency — 12 days — email
```

---

### Filtered to one person

**User:** "what am I waiting on from Sarah?"

**Output:**
```
## 🔔 Waiting On Sarah

- Draft API spec v2 — due Apr 10 (2 days overdue) [type:: delegation] [project:: Auth Migration]
- Response to onboarding guide feedback — 4 days — email
```

Note: this query also includes delegations assigned to Sarah, not just reply-needed tasks, since the user likely wants a full picture of what's pending with that person. Show both types, labeled.

---

### Nothing pending

**User:** "what am I waiting on?"

**Output:**
```
## 🔔 Waiting On Them

Nothing in your waiting-on-them list. Either you're caught up or no threads have been flagged for tracking yet.

To track a thread, say "I'm waiting on [person] for [topic]" or flag it during email/message processing.
```

---

## Edge Cases

- **No reply-needed tasks found:** Show the empty state message with guidance on how to populate the tracker.
- **Task has no person field:** Include in the list, show "Unknown" for person. Suggest the user add `[person:: {name}]` to the task for better filtering.
- **Reply-needed task is overdue:** Mark with ⚠️ if the due date has passed.
- **Both directions for same person:** Sarah waiting on you AND you waiting on Sarah — show in both lists, labeled separately.
