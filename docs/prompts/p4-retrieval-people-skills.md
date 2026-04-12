# P4: Write 7 Skills — Information Retrieval + People Management

## Setup

**Model:** Sonnet | **Effort:** High

**Read these files:**
- `docs/architecture.md` — §2 (Skill Inventory), §4 (Vault Structure), §5 (Config System), §8 (Review Queue)
- `docs/design/foundations.md` — §1 (Vault Structure), §3 (Config schemas)
- `docs/features/people-management.md` — Person Briefing, 1:1 Pattern Analysis, Feedback Gap Detection, Performance Narrative, Team Health, Attention Gap Detection
- `docs/features/projects-and-tasks.md` — Project Status Summary, Blocker Detection
- `docs/features/email-and-messaging.md` — Unreplied & Follow-up Tracker, Thread Summary

**Do NOT read** any files under `agents/skills/` or `agents/steering/`.

## SKILL.md Format

```
agents/skills/myna-{name}/
└── SKILL.md
```

```markdown
---
name: myna-{name}
description: {concise — Claude uses for auto-invocation. Max ~250 chars.}
user-invocable: true
argument-hint: "{hint}"
---

# {Skill Title}

## Purpose
## Triggers
## Inputs
## Procedure
## Output
## Rules
## Examples
```

**Skill-writing principles:** Self-contained. Goal-oriented procedures. Inline entry formats. Mandatory worked examples. Don't over-specify. `argument-hint` on every skill. **Use Claude Code built-in tools (Read, Write, Edit, Grep, Glob) for file I/O — only use Obsidian MCP for Obsidian-specific features** (`tasks`, `search`, `create_from_template`, `eval`, `backlinks`, `tags`). Built-in tools are faster and work without Obsidian running.

## Skills to Write

### 1. `myna-brief-person`

**Intent:** Person briefing — role, shared projects, open items, pending feedback, 1:1 history, personal notes

**argument-hint:** `"[person name]"`

**Features covered:** Person Briefing

**Key behaviors:**
- Resolve person against people.yaml (aliases, partial matches). If ambiguous, ask.
- Read person file, shared project files, 1:1 meeting file, open tasks referencing this person
- Present inline, 15-25 lines, structured sections with priority tiers:
  - **Always:** Role & context, open items between you, last 1:1
  - **If data exists:** Shared projects, pending feedback with coaching talking points, feedback gap detection, personal notes
  - **If space permits:** Stakeholder mentions
- Check `features.people_management` for feedback/gap sections
- Read-only — never writes to vault unless user explicitly asks to save
- Insufficient data: state it plainly, don't pad. "No observations logged" is correct.
- Present factual data only. Never infer engagement, morale, or performance.

---

### 2. `myna-brief-project`

**Intent:** Project status — timeline, tasks, blockers, meetings. Quick and full modes.

**argument-hint:** `"[project name]"`

**Features covered:** Project Status Summary (quick and full modes)

**Key behaviors:**
- Resolve project against projects.yaml. If ambiguous, ask.
- Two modes:
  - **Quick** ("catch me up quick", "TL;DR"): 3-5 bullet summary — status, top blocker, next milestone, trajectory
  - **Full** (default): recent timeline entries (2 weeks), all open blockers (callouts + overdue dependencies), task breakdown (open/overdue/delegated counts), upcoming meetings (7 days, group recurring)
- Full mode reads calendar MCP for upcoming meetings — gracefully degrade if unavailable
- Read-only — inline output only
- Missing vault files are not errors — skip and note what was unavailable

---

### 3. `myna-team-health`

**Intent:** Team health dashboard — open tasks, overdue, feedback gaps, attention gaps for all directs

**argument-hint:** `"[optional: specific team]"`

**Features covered:** Team Health Overview (point-in-time dashboard)

**Key behaviors:**
- Check `features.team_health` toggle
- Read people.yaml for direct reports (`relationship_tier: direct`)
- For each: read person file, query open tasks, read 1:1 meeting file
- Present table with columns: Person, Open Tasks, Overdue, Last 1:1, Feedback Gap, Delegations, Contribs (2wk), Attention
- Feedback Gap: days since last observation/recognition, flag if exceeding `feedback_cycle_days`
- Attention: flag if no observations in 45+ days or no career topics in 4+ months
- After table, highlight 2-3 people who most need attention and why
- Read-only — inline output

---

### 4. `myna-unreplied-threads`

**Intent:** Unreplied tracker — what's waiting on you vs what you're waiting on

**argument-hint:** `"[optional: person or project filter]"`

**Features covered:** Unreplied & Follow-up Tracker queries

**Key behaviors:**
- Query tasks with `type:: reply-needed` via Obsidian MCP tasks tool
- Split into two lists:
  - **Waiting on you:** reply-needed tasks where you are the owner (no `person::` field)
  - **Waiting on them:** reply-needed tasks where `person::` is someone else
- Sort by age (oldest first), show original message context and days waiting
- If "waiting on them" is empty, note: suggest tracking with "add task: waiting for reply from [person]"
- Read-only — inline output

---

### 5. `myna-blockers`

**Intent:** Blocker detection — scan all active projects for blockers, overdue dependencies, stuck items

**argument-hint:** `"[optional: specific project]"`

**Features covered:** Blocker Detection

**Key behaviors:**
- Scan ALL active project files (or one specific project) for:
  - `> [!warning] Blocker` callout blocks in timelines
  - Tasks with `type:: dependency` past due date
  - Tasks significantly overdue that may block other work
- Present grouped by project: explicit blockers with source reference and age, overdue dependencies with owner and days overdue
- For each blocker: which project, what's blocked, who owns resolution, how long blocked
- Suggest escalation: "Say 'escalate this blocker' to draft an escalation message."
- Read-only — inline output

---

### 6. `myna-1on1-analysis`

**Intent:** 1:1 pattern analysis — follow-through rates, recurring topics, carry-forward rate, topic balance

**argument-hint:** `"[person name]"`

**Features covered:** 1:1 Pattern Analysis

**Key behaviors:**
- Check `features.people_management` toggle
- Resolve person, read FULL 1:1 meeting file (all sessions, not just most recent)
- Compute and present metrics across sessions:
  - **Action item follow-through:** yours vs theirs, completion rate before next session
  - **Recurring topics:** themes in 3+ sessions with session count
  - **Carry-forward rate:** percentage of prep items carried to next session
  - **Topic source balance:** categorize prep items as user-added, carried, or agent-generated. Flag if agent-generated >70% (user may be under-engaged in agenda)
  - **Feedback delivery:** sessions with pending feedback in prep vs sessions where feedback was checked off
  - **Session gaps:** flag any gap >3 weeks
- Read-only — inline output, 20-30 lines

---

### 7. `myna-performance-narrative`

**Intent:** Generate evidence-based performance review narrative for a direct report. Includes review calibration.

**argument-hint:** `"[person name] [period]"`

**Features covered:** Performance Narrative, Review Calibration

**Key behaviors:**
- Check `features.people_management` toggle
- Resolve person, determine time period (user specifies or default last 3 months)
- **Narrative generation:**
  - Gather evidence: person file (observations, recognition), project timelines mentioning this person, 1:1 notes, contributions log
  - Structure: Summary (2-3 sentences), Strengths (evidence-backed with dates), Growth areas (factual, not judgmental), Key contributions (specific, dated), Development highlights
  - Highlight all [Inferred] data points — user must verify
  - Save to `Drafts/[Review] Performance Narrative {person} {period}.md`
- **Review calibration** (triggered by "calibrate my reviews", "check my reviews for consistency"):
  - Find all `[Review] Performance Narrative` drafts in Drafts/ for the same period
  - Need at least 2 to calibrate
  - Compare: evidence count per person, narrative length, language strength (hedging vs strong verbs), category coverage
  - Present discrepancies inline — do NOT auto-correct
- Narrative always saves to Drafts/. Calibration is inline only.

## Git

After writing each skill, commit individually:
```
git add agents/skills/myna-{name}/
git commit -m "feat(agents): add myna-{name} skill"
```

After all 7 skills are committed, push:
```
git push origin main
```

## Verification

- `ls agents/skills/myna-{brief-person,brief-project,team-health,unreplied-threads,blockers,1on1-analysis,performance-narrative}/SKILL.md` — 7 files
- Each has valid frontmatter with `name`, `description`, `user-invocable: true`, `argument-hint`
- Only `myna-performance-narrative` writes to the vault (Drafts/). All others are read-only inline output.
- No skill duplicates another's scope (e.g., person briefing doesn't include blocker detection)
- Each skill has at least one worked example
- Feature toggle checks present where required
