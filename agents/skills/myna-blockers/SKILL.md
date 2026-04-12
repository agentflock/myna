---
name: myna-blockers
description: Scan all active projects for blockers — items marked as blockers in project timelines, overdue dependency tasks, and overdue tasks that block downstream work. Invoke for "what's blocked?", "show me blockers", "any blockers across projects?".
user-invocable: true
argument-hint: "[optional: project name to scope to one project]"
---

# Blocker Detection

Scans active projects for blockers and surfaces them inline. Read-only — no vault writes. Informational only — no auto-actions, no auto-escalation.

---

## What Counts as a Blocker

Three signal types, checked in this order:

**1. Explicit blocker entries in project timelines**
Timeline entries with the `Blocker` category, or entries in `> [!warning] Blocker` callout blocks.

Grep patterns:
```
\[!warning\] Blocker
\| Blocker \|
[Blocker]
```

**2. Overdue dependency tasks**
Open tasks with `[type:: dependency]` where the due date has passed.

Grep: `- \[ \] .* \[type:: dependency\]` — then filter for `📅` dates before today.

**3. Overdue high-priority tasks with downstream impact**
Open tasks marked ⏫ (high priority) that are more than 3 days overdue. These are likely blocking something downstream even if not explicitly marked as blockers. Include with a note: "may be blocking downstream work."

Grep: `- \[ \] .*⏫.* 📅` — filter for dates more than 3 days before today.

---

## Scope

Default: scan all projects with `status: active` in projects.yaml.

If the user names a specific project: scope to that project only.

Read each active project's file at `Projects/{project-slug}.md`.

---

## Output

```
## 🚧 Blockers — [date]

[Count] blockers across [N] projects.

---

### [Project Name]

> [!warning] [Blocker description]
> [[date] | [source]] [details] [[provenance]]
> Age: [X days since logged]
> Suggested next: [say "escalate this blocker" to draft a message]

---

### [Another Project]

> [!warning] [Blocker description]
> ...
```

If no blockers found:

```
## 🚧 Blockers — [date]

No open blockers across [N] active projects. ✅
```

---

## Worked Example

**User:** "what's blocked?"

**Projects scanned:** Auth Migration, Platform API, Onboarding Flow (all active)

**Findings:**
- Auth Migration: `[!warning] Blocker` entry from Apr 3 — Platform API dependency overdue
- Auth Migration: dependency task overdue by 4 days
- Onboarding Flow: high-priority task overdue 5 days — "Design review not scheduled, blocks implementation"
- Platform API: no blockers

**Output:**
```
## 🚧 Blockers — 2026-04-12

3 blockers across 2 projects.

---

### Auth Migration

> [!warning] Platform API Integration
> [2026-04-03 | email from James] Waiting on Platform team for API endpoint spec — committed April 8, now 4 days overdue [Auto]
> Age: 9 days
> Suggested next: say "escalate this blocker" to draft a message to the Platform team

> [!warning] Dependency task overdue
> Waiting on Platform team for API endpoint spec [type:: dependency] — due 2026-04-08 (4 days overdue)

---

### Onboarding Flow

> [!warning] Design review not scheduled
> [2026-04-07 | capture] Design review hasn't been scheduled — blocks implementation kickoff [User]
> Age: 5 days (high-priority task, 5 days overdue — may be blocking downstream work)
> Suggested next: say "escalate this blocker" or "schedule a design review"
```

---

## Single-Project Scope

**User:** "any blockers on auth migration?"

Shows only Auth Migration blockers. Same format, scoped output.

---

## Source References

Each blocker includes:
- Which file it came from (project name)
- The exact entry text with date + source
- Provenance marker
- Days since it was logged

This gives the user enough to act — they know what's blocked, how long, and where the data came from.

---

## Connection to Escalation

This skill is informational. It never auto-escalates or drafts messages.

When blockers are shown, suggest: "Say 'escalate this blocker' to draft a message." This routes to the myna-draft skill (escalation mode), which requires the user to explicitly request the draft.

---

## Edge Cases

- **No active projects:** "No active projects found. Update project statuses in projects.yaml if needed."
- **Project file missing for an active project:** Skip it, note: "Skipped [project] — project file not found."
- **Blocker already has a follow-up task:** If there's an open retry or follow-up task linked to the blocker, note it: "Follow-up task exists: [task description]."
- **Scoped to one project with no blockers:** "[Project Name]: no open blockers."
