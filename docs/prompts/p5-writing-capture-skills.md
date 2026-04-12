# P5: Write 7 Skills — Writing, Capture, Self-Tracking, Context, Memory, Review

## Setup

**Model:** Sonnet | **Effort:** High

**Read these files:**
- `docs/architecture.md` — §2 (Skill Inventory), §4 (Vault Structure), §5 (Config System), §8 (Review Queue), §14 (Memory Model)
- `docs/design/foundations.md` — §1 (Vault Structure), §3 (Config schemas), §4 (Provenance), §6 (Review Queue routing)
- `docs/features/writing-and-drafts.md` — all features EXCEPT Pre-Read Preparation (deferred post-launch)
- `docs/features/cross-domain.md` — Quick Capture, Park & Resume, Link Manager
- `docs/features/self-tracking.md` — all features
- `docs/features/daily-workflow.md` — Review Queue feature
- `docs/features/projects-and-tasks.md` — Task Management features

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

### 1. `myna-draft`

**Intent:** Generate professional content — replies, status updates, escalations, recognition, say-no, conversation prep, monthly reports

**argument-hint:** `"[type and details, e.g. reply to Sarah about API]"`

**Features covered:** Email Draft Reply (conversation path), Follow-Up Email, Follow-Up Meeting Draft, Structured Draft (status/escalation), Recognition Draft, Help Me Say No, Difficult Conversation Prep, Monthly Update (MBR/MTR/QBR)

**Key behaviors:**
- Audience resolution: look up person in people.yaml → get relationship_tier → select tone preset from communication-style.yaml
- All drafts shown inline first. "Say 'save' to write to Drafts/." On save: frontmatter (type, audience_tier, related_project, related_person, created), tags, footer with source.
- After saving: append review TODO to daily note
- BLUF for structured communications (status, escalation, emails to leadership). Skip for casual/recognition/conversational.
- Draft types: email reply, follow-up email, meeting invite, status update, escalation, recognition (multi-format), say no, conversation prep, monthly update (MBR/MTR/QBR with trend analysis)
- Audience-adaptive depth: upward → concise BLUF. Peer → moderate. Direct → detailed.
- Monthly updates: read across time period (project timelines, contributions, meetings), include trend analysis comparing to previous period
- Check `features.monthly_updates` before MBR/MTR/QBR
- External content framing when reading email threads
- Multiple intents in one request → separate draft files

**Does NOT include:** Message Rewriting (fix/tone/rewrite) — that's `myna-rewrite`. Pre-Read Preparation — deferred post-launch.

---

### 2. `myna-rewrite`

**Intent:** Transform existing messages — fix grammar, adjust tone for audience, or fully rewrite

**argument-hint:** `"[fix | tone | rewrite] [optional: for audience]"`

**Features covered:** Message Rewriting (3 modes)

**Key behaviors:**
- Three modes:
  - **Fix:** Grammar and spelling only. Preserve structure, wording, voice. Do NOT restructure or apply BLUF.
  - **Tone:** Keep content and structure, adjust tone for target audience. Apply BLUF where appropriate.
  - **Rewrite:** Treat input as rough notes. Full restructure into polished message. Apply BLUF where appropriate.
- Default mode is **rewrite** if unspecified
- Audience resolution same as myna-draft (people.yaml → tier → style preset)
- Channel-specific: Slack = shorter, more casual. Email = more structured.
- Output shown inline (not saved to Drafts/ unless user asks)

---

### 3. `myna-capture`

**Intent:** Route user-entered data to vault — observations, tasks, links, notes, status changes, recognition

**argument-hint:** `"[what to capture]"`

**Features covered:** Quick Capture, Observations & Feedback Logging, Recognition Tracking, Task Management (add, recurring), Link Manager (save), Project/Person File Management

**Key behaviors:**
- **Quick capture** ("capture: [anything]"): decompose input into entries, each routed to its destination. Match number of entries to what user explicitly stated — don't over-decompose.
- **Observations:** resolve person → classify (strength/growth-area/contribution) → dedup check → append to person file. Growth-area also adds to Pending Feedback.
- **Tasks:** extract attributes from natural language (title, project, priority, dates, type, person, effort). Inferred fields get `[review-status:: pending]`. Obsidian Tasks plugin format.
- **Recurring tasks:** `🔁 every {interval}`
- **Links:** append to entity file's Links section + central `_system/links.md`
- **Status changes:** append timeline entry + update Status line in Overview
- **Person notes:** append to Personal Notes section
- Entity resolution: if unresolvable, ask — never guess or create entries for unknown entities
- Dedup for observations and recognition before writing
- Wiki-link validation: verify target file exists before creating `[[link]]`

---

### 4. `myna-self-track`

**Intent:** Log contributions and generate career documents — brag docs, self-reviews, promo packets

**argument-hint:** `"[log | brag doc | self-review | promo case | query]"`

**Features covered:** Contributions Tracking, Self-Narrative Generation, Contribution Queries, Self-calibration

**Key behaviors:**
- Check `features.self_tracking` toggle
- **Logging:** determine contribution category from user role (IC vs manager categories). Append to weekly file `Journal/contributions-{monday-date}.md`. Provenance: `[User]`.
- **Generation** (brag doc / self-review / promo packet): read contributions across time range, cross-reference projects/people/meetings. Highlight [Inferred] entries. Save to `Drafts/[Self] {type} {period}.md`.
- **Queries:** filter contributions by category, project, person, date range. Present inline.
- **Self-calibration** ("am I underselling myself?"): compare draft claims vs contributions log. Flag: claims without evidence, missing contributions, understated language.
- Performance narratives for OTHERS belong to myna-performance-narrative. This skill handles SELF-narratives only.

---

### 5. `myna-park`

**Intent:** Save and resume working context across sessions with zero context loss

**argument-hint:** `"[topic to park or resume]"`

**Features covered:** Park & Resume

**Key behaviors:**
- **Park:** gather context from conversation — topic, referenced files, discussion summary, current state, next steps, open questions, key constraints. Write to `_system/parked/{topic-slug}.md`. Must be detailed enough for a brand new session to resume with zero context loss.
- **Resume:** resolve topic against `_system/parked/` files (fuzzy match). Present summary: what, where you left off, what's next, open questions. Session continues from next steps.
- **Switch** ("switch to [project]"): park current context, then load target project status.
- **List:** show all parked items with topic, summary, date.
- Check `features.park_resume` toggle
- Never auto-delete parked files
- Wiki-links must point to real files — verify before linking

---

### 6. `myna-learn`

**Intent:** Capture and manage Myna's experiential memory — preferences, corrections, patterns

**argument-hint:** `"[what to remember, forget, or reflect on]"`

**Features covered:** Emergent memory: capture, reflect, delete, negotiate

**Key behaviors:**
- **Capture:** refuse factual entries (redirect to entity notes). Determine domain (email/meetings/tasks/people/general). Check for duplicates. Active section for explicit directives ("remember", "always", "never"). Proposed section for observed patterns.
- **Reflect** (invoked by myna-wrap-up, or "what have you noticed?"): scan session for patterns. New patterns → Proposed with `[obs: 1]`. Existing Proposed → increment (max +1 per reflection pass). Count reaches 3 → auto-promote to Active.
- **Negotiate** (when user pushes back on a promotion): demote → rewrite with user's scope → move to Active with `[Verified]`. Or delete.
- **Delete:** search across all domain files, semantic match, remove matching entry.
- Files: `vault/_meta/learnings/{domain}.md` (email, meetings, tasks, people, general). Created lazily.
- Skill never edits CLAUDE.md. Skill never leaks learning content into outputs.
- Provenance markers: `[User]`, `[Auto]`, `[Inferred]`, `[Verified]`

---

### 7. `myna-process-review-queue`

**Intent:** Process review queue items — approve, edit, skip, or discard with user judgment

**argument-hint:** `"[optional: process approved items]"`

**Features covered:** Review Queue processing (review-work, review-people, review-self)

**Key behaviors:**
- Read review-work.md, review-people.md, review-self.md. Count pending items.
- **Chat mode** ("review my queue"): present items one at a time. Accept: approve, edit, skip, discard.
- **File mode** ("process my queue"): read checked items, write to destinations, leave unchecked.
- Approved items written with `[Verified]` replacing original marker. Note: `(was Inferred, confirmed {date})`.
- Audit trail: append to `ReviewQueue/processed-{date}.md`
- Remove processed entries from active queue files
- review-triage.md is NOT handled here — that's myna-email-triage
- Never auto-approve
- Check `features.self_tracking` before processing review-self items

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

- `ls agents/skills/myna-{draft,rewrite,capture,self-track,park,learn,process-review-queue}/SKILL.md` — 7 files
- Each has valid frontmatter with `name`, `description`, `user-invocable: true`, `argument-hint`
- `myna-draft` does NOT include message rewriting or pre-read
- `myna-rewrite` is focused only on fix/tone/rewrite of existing text
- `myna-self-track` handles self-narratives only (not performance narratives for others)
- `myna-learn` never writes to CLAUDE.md
- Each skill has at least one worked example
