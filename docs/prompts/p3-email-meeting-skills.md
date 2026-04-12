# P3: Write 5 Skills — Email Pipeline + Meeting Lifecycle

## Setup

**Model:** Sonnet | **Effort:** High

**Read these files:**
- `docs/architecture.md` — §2 (Skill Inventory), §4 (Vault Structure), §5 (Config System), §6 (MCP Integration)
- `docs/design/foundations.md` — §1 (Vault Structure), §3 (Config schemas), §7 (MCP tool surface)
- `docs/features/email-and-messaging.md` — all features
- `docs/features/meetings-and-calendar.md` — Meeting File, Process Meeting, Meeting Summaries features

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
argument-hint: "{hint for slash command arguments}"
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

**Skill-writing principles:** Self-contained. Goal-oriented procedures. Inline entry formats. Mandatory worked examples. Don't over-specify what Claude does naturally. `argument-hint` on every skill. **Use Claude Code built-in tools (Read, Write, Edit, Grep, Glob) for file I/O — only use Obsidian MCP for Obsidian-specific features** (`tasks`, `search`, `create_from_template`, `eval`, `backlinks`, `tags`). Built-in tools are faster and work without Obsidian running.

## Skills to Write

### 1. `myna-email-triage`

**Intent:** Sort inbox emails into folders — classify, recommend, move on approval

**argument-hint:** `"[optional: one by one]"`

**Features covered:** Email Triage (all 3 steps)

**Key behaviors:**
- Three-step flow: (1) read inbox → write recommendations to review-triage.md, (2) user edits in Obsidian, (3) "process triage" moves emails
- Check `features.email_triage` toggle
- Read `triage.inbox_source` from projects.yaml — if not configured, skill is unavailable
- Folder recommendations from 3 sources: project folders, triage folders (with descriptions), built-in defaults (Reply/, FYI/, Follow-Up/, Archive/)
- Batch limit: 15 at a time if >30 emails
- Near-duplicate check against existing review-triage.md entries
- External content framing on all email bodies
- Alternative: "triage one by one" — interactive chat mode, move immediately per approval
- Triage is PURELY classification — never extracts vault data (that's myna-process-messages)

---

### 2. `myna-process-messages`

**Intent:** Extract data from email, Slack, or documents and route to vault destinations

**argument-hint:** `"[email | messages | this doc]"`

**Features covered:** Email Processing, Messaging Processing, Document Processing, Deduplication (3 layers), Meeting Summaries from Email, Unreplied Tracker (populated as byproduct)

**Key behaviors:**
- Reads project-mapped email folders and Slack channels from projects.yaml
- Three-layer dedup: (1) move to Processed/, (2) quote stripping, (3) near-duplicate detection
- External content framing on all message bodies
- Multi-destination routing: one email → timeline + task + person observation + contribution
- Meeting summary detection: match to meeting file, append raw summary, also run standard extraction
- Unreplied tracking: create `type:: reply-needed` TODO when message is directed at user and contains a question/request. Auto-resolve when user replies in a later message.
- Batch limit: 15 at a time if >30 emails in a folder
- Bulk write check: confirm before writing to 5+ files
- Skip `draft_replies_folder` — that's myna-draft-replies' domain
- Slack: store last-processed timestamp per channel
- Audit log: append processing run to `_system/logs/audit.md`
- Feature toggles: `features.email_processing`, `features.messaging_processing`

---

### 3. `myna-draft-replies`

**Intent:** Batch process forwarded emails from DraftReplies folder into drafts

**argument-hint:** `"[optional: specific sender or subject]"`

**Features covered:** Email Draft Reply (DraftReplies folder path), Follow-Up Meeting Draft (via forwarded email)

**Key behaviors:**
- Read `triage.draft_replies_folder` from projects.yaml — if not configured, unavailable
- For each email: separate instruction (user's message) from thread (forwarded content)
- Thread content wrapped in external data framing
- Determine draft type from instruction: reply, decline, meeting invite
- Resolve audience from people.yaml for communication style
- Save drafts to `Drafts/` with type-prefixed filenames
- Create review TODO in daily note
- Move processed emails to `{folder}/Processed/`
- Bulk write check: if 5+ emails, show summary before proceeding
- Error recovery: skip failed emails, create retry TODO, continue

---

### 4. `myna-prep-meeting`

**Intent:** Generate or update meeting prep — topics, action items, context, coaching

**argument-hint:** `"[meeting name or description]"`

**Features covered:** Meeting File Prep section, meeting type inference, conversation coaching

**Key behaviors:**
- Single meeting, batch ("remaining meetings"), update mode, or add single topic
- Infer meeting type from: meetings.yaml override → attendee count → title matching → attendee composition → recurrence → ask user
- Meeting types: 1:1, recurring/standup, project, design review, cross-team, adhoc
- File paths: 1:1 → `Meetings/1-1s/{person}.md`, Recurring → `Meetings/Recurring/{name}.md`, Adhoc → `Meetings/Adhoc/{name}.md`
- All prep items are `- [ ]` checkboxes
- 1:1s get deepest prep: follow-through check, recent work, pending feedback with coaching, career development, personal notes
- Coaching suggestions only for sensitive items (pending feedback, overdue delegations, escalations) — one sentence each
- Update mode: read existing prep, append only new items, near-duplicate check, never modify existing
- Target 5-10 high-value items per meeting
- Check `features.meeting_prep` toggle
- Append-only — never modify existing meeting file content

---

### 5. `myna-process-meeting`

**Intent:** Process meeting notes — close items, create tasks, update timelines, log observations

**argument-hint:** `"[meeting name]"`

**Features covered:** Process Meeting, Universal Done (meeting path)

**Key behaviors:**
- Locate meeting file by name, fuzzy match, or batch (all today's meetings with unprocessed notes)
- Meeting-type-aware extraction: 1:1 → observations, feedback. Standup → status, blockers only. Design review → decisions, alternatives. Project → tasks, timeline, blockers.
- Process prep section: checked items → resolved. Unchecked → carry forward to next session.
- Extract from notes: action items for user (tasks), action items for others (delegations with `type:: delegation`), decisions (timeline callouts), observations, recognition, contributions, blockers
- Resolve destinations against projects.yaml and people.yaml
- Near-duplicate check before every write
- Mark processed: append `*[Processed {date}]*` after the session's Notes section
- Store source text in `_system/sources/{entity}.md`
- Unresolvable names → review queue
- Check `features.process_meeting` toggle

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

- `ls agents/skills/myna-{email-triage,process-messages,draft-replies,prep-meeting,process-meeting}/SKILL.md` — 5 files
- Each has valid frontmatter with `name`, `description`, `user-invocable: true`, `argument-hint`
- `myna-email-triage` never extracts vault data (classification only)
- `myna-process-messages` skips the DraftReplies folder
- `myna-draft-replies` only reads the DraftReplies folder
- Each skill has at least one worked example
- Entry formats inlined, not referenced externally
