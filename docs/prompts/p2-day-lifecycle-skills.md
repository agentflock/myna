# P2: Write 5 Skills — Day Lifecycle + Calendar

## Setup

**Model:** Sonnet | **Effort:** High

## Context

Myna is a personal assistant for tech professionals built on Claude Code. You're writing 5 skills from scratch using the feature specs and architecture as source of truth.

**Read these files:**
- `docs/architecture.md` — §2 (Skill Inventory for feature coverage), §4 (Vault Structure), §5 (Config System), §10 (Cross-Domain Data Flow)
- `docs/design/foundations.md` — §1 (Vault Structure), §2 (File templates), §3 (Config schemas)
- `docs/features/daily-workflow.md` — Morning Sync, Daily Note, Weekly Note, Planning, End of Day, Weekly Summary features
- `docs/features/meetings-and-calendar.md` — Time Block Planning, Calendar Reminders, Task Breakdown features
- `docs/features/cross-domain.md` — Park & Resume (for context on carry-forward patterns)

**Do NOT read** any files under `agents/skills/` or `agents/steering/` — write from scratch.

## SKILL.md Format

```
agents/skills/myna-{name}/
└── SKILL.md
```

```markdown
---
name: myna-{name}
description: {concise — Claude uses this for auto-invocation. Max ~250 chars. Front-load the action.}
user-invocable: true
argument-hint: "{hint for slash command arguments}"
---

# {Skill Title}

## Purpose
{1-3 sentences — what this skill does}

## Triggers
{Example natural language phrases that invoke this skill — illustrative, not exhaustive}

## Inputs
{Config files, vault files, MCP tools this skill reads}

## Procedure
{Step-by-step instructions — goal-oriented, not LLM-teaching}

## Output
{What this skill produces — vault files written, inline output shown}

## Rules
{Constraints, edge cases, feature toggles to check}

## Examples
{At least one realistic worked example per major workflow path}
```

## Skill-writing principles

- **Self-contained.** A fresh Claude session should execute the skill with ONLY the SKILL.md + steering skills loaded. Don't say "see architecture.md" — inline the relevant rules.
- **Goal-oriented procedures.** Tell Claude what to accomplish, not how to think. "Read today's calendar via calendar MCP" not "You should consider checking the calendar."
- **Include entry formats inline.** When the skill writes vault entries (tasks, timeline, observations), show the exact format. Don't reference external format docs.
- **Mandatory worked examples.** At least one per major workflow path. Show: user input → what the skill reads → what it decides → what it writes → what it tells the user.
- **Don't over-specify.** If Claude would naturally do something right (understand context, generate coherent text), don't instruct it. Only specify where Claude might get the default wrong.
- **argument-hint on every skill.** Even if arguments are optional, provide a hint.
- **Use Claude Code built-in tools for file I/O, not Obsidian MCP.** Read files with the Read tool, write/edit with Write/Edit, search contents with Grep, find files with Glob. Only use Obsidian MCP for Obsidian-specific features: `tasks` (Tasks plugin queries), `search` (indexed metadata-aware search), `create_from_template` (Obsidian template substitution), `eval` (Dataview queries), `backlinks`/`tags` (Obsidian graph data). This is faster, simpler, and works even when Obsidian isn't running.

## Skills to Write

### 1. `myna-sync`

**Intent:** Set up or refresh your day — create daily note, meeting preps, weekly note, archive journals

**argument-hint:** `"[optional: plan tomorrow]"`

**Features covered:** Morning Sync, Daily Note, Weekly Note (first sync of the week), Plan Tomorrow, Journal auto-archiving

**Key behaviors:**
- Creates daily note from template if doesn't exist; prepends new snapshot if re-run
- Reads calendar for today's meetings → creates lightweight prep files under Meetings/
- Surfaces overdue tasks, delegation alerts, review queue count
- Writes Capacity Check (focus time vs task effort)
- Suggests top 3 priorities
- Weekly note created on first sync of the week
- "Plan tomorrow" creates next day's daily note
- Auto-archives journal notes older than configured threshold
- Morning Focus section is sacred — never overwrite
- Snapshots are immutable — on re-run, prepend new snapshot, never edit previous ones

**Does NOT include:** Planning Modes (plan day, priority coaching, week optimization) — those go to `myna-plan`

---

### 2. `myna-plan`

**Intent:** Planning advice — plan day, priority coaching, week optimization. Inline only, no vault writes.

**argument-hint:** `"[plan day | priorities | week optimization]"`

**Features covered:** Plan Day, Priority Coaching, Week Optimization

**Key behaviors:**
- All output is ephemeral inline advice — NEVER writes to the vault
- Reads the same data as sync (calendar, tasks, daily note, weekly note) but produces advice, not files
- **Plan Day:** suggest a schedule — which tasks in which focus blocks, what to tackle first, flag over-commitment
- **Priority Coaching:** recommend top 3 priorities with reasoning. Flag blockers, tasks deferred 3+ times, overdue delegation follow-ups
- **Week Optimization:** suggest meetings to skip/delegate, optimal focus block times, tasks that can safely defer
- Output is 5-7 bullet points max — not planning essays
- Reads weekly note goals if available

---

### 3. `myna-wrap-up`

**Intent:** Close out your day — planned vs actual, detect contributions, carry forward, reflect

**argument-hint:** `"[optional: wrap up anyway]"`

**Features covered:** End of Day Wrap-Up, contribution detection, carry-forward, reflection (invokes myna-learn)

**Key behaviors:**
- Reads today's daily note; compares FIRST sync snapshot (the day's plan) against current state
- Planned vs Actual: completed, not started, partially done — factual lists, not narrative
- Contribution detection (if `features.contribution_detection` enabled): scan completed work, classify by user role categories, dedup against existing contributions log
  - High-confidence → [Auto], less certain → [Inferred], genuinely uncertain → review-self queue
- Quick notes prompt: ask once, don't block
- Carry-forward: list unfinished items, append to tomorrow's daily note with "(carried from {date})"
- Writes End of Day section at bottom of daily note
- Final step: invoke myna-learn's reflect operation for session pattern detection
- Output format: "Day wrapped up. Completed: X of Y. N contributions detected (N certain, N inferred, N in review queue). N items carried to tomorrow."

**Does NOT include:** Weekly Summary — that's `myna-weekly-summary`

---

### 4. `myna-weekly-summary`

**Intent:** Summarize your week — accomplishments, decisions, blockers, tasks, team health snapshot

**argument-hint:** `"[optional: specific week date]"`

**Features covered:** Weekly Summary, Team Health Tracking snapshot (for managers)

**Key behaviors:**
- Check `features.weekly_summary` before proceeding
- Reads all daily notes for the current week, contributions log, project timelines
- Creates or appends to weekly note (`Journal/WeeklyNote-{monday-date}.md`)
- Sections: Accomplishments, Decisions Made, Blockers (unresolved/new/resolved), Tasks (completed vs carried by project), Self-Reflection prompts
- Self-Reflection: time allocation balance, delegation health, recurring carry-overs, feedback gaps (if manager + enabled)
- If `features.team_health` enabled and user is manager: generate Team Health snapshot per direct report (open tasks, overdue, feedback gap, attention gap, last 1:1) → append to Team/ file
- Additive on re-run — only add new information since previous summary timestamp

---

### 5. `myna-calendar`

**Intent:** Create time blocks, reminders, and break down tasks into subtasks

**argument-hint:** `"[what to schedule or break down]"`

**Features covered:** Time Block Planning, Calendar Reminders, Task Breakdown

**Key behaviors:**
- **Time blocks:** Read calendar for target day, show 2-3 best free slots (not exhaustive list), apply three-layer calendar protection (prefix + no attendees check + explicit confirmation), create event
- **Reminders:** Determine if task-linked or standalone. 15-min default duration. Same three-layer protection.
- **Task breakdown:** Find task via Obsidian MCP, read project context, split into subtasks as indented TODOs under parent task, each with due date and effort estimate
- Calendar event titles use configured prefix and type: `{prefix}:{type} {description}` (e.g., `[Myna:Focus] Design doc review`)
- **Never add attendees** — absolute, non-negotiable
- Check feature toggles: `features.time_blocks` for time blocks, `features.calendar_reminders` for reminders
- Free slots respect work_hours from workspace.yaml only

## Git

After writing each skill, commit individually:
```
git add agents/skills/myna-{name}/
git commit -m "feat(agents): add myna-{name} skill"
```

After all 5 skills are committed, push:
```
git push origin main
```

## Verification

After writing all 5 skills:
- `ls agents/skills/myna-{sync,plan,wrap-up,weekly-summary,calendar}/SKILL.md` shows exactly 5 files
- Each has valid YAML frontmatter with `name`, `description`, `user-invocable: true`, `argument-hint`
- `myna-sync` does NOT contain planning modes (plan day, priority coaching, week optimization)
- `myna-plan` does NOT write any vault files
- `myna-wrap-up` does NOT contain weekly summary logic
- `myna-weekly-summary` does NOT contain daily wrap-up logic
- Each skill has at least one worked example
- Entry formats (tasks, timeline entries) are inlined, not referenced externally
