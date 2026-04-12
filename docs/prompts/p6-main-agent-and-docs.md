# P6: Rewrite Main Agent + Update All Supporting Files

## Setup

**Model:** Opus | **Effort:** High

**Read these files:**
- `docs/architecture.md` — full file (updated by P0)
- `docs/design/foundations.md` — full file
- All 24 skill SKILL.md files under `agents/skills/myna-*/SKILL.md` — read at least the frontmatter + Purpose + Triggers of each to understand what every skill does
- All 6 steering skill SKILL.md files under `agents/skills/myna-steering-*/SKILL.md`
- `install.sh` — current file (needs updating)
- `CLAUDE.md` — current file (needs updating)
- `README.md` — current file (needs updating)
- `docs/decisions.md` — read for context, add new decision if warranted
- `docs/roadmap.md` — read for context, update if needed
- `scripts/lint-agents.sh` — current file (needs updating)
- `tests/manual-test-checklist.md` — current file (needs updating)

**Do NOT read** any old skill files (`agents/skills/*.md` flat files) — those are being replaced.

## Part 1: Rewrite `agents/main.md` from scratch

**Do not patch — write a new file.** The current main.md was written for a different architecture.

Read the current `agents/main.md` to understand its scope, then write a new version designed for native Claude Code skills.

### What main.md must contain

**Header comment:**
```markdown
<!--
This file is installed to ~/.claude/agents/myna.md by the install script.
The install script substitutes these placeholders:
  {{VAULT_PATH}} → absolute path to the user's Obsidian vault
  {{SUBFOLDER}} → Myna subfolder name (default: "myna")
The agent's frontmatter lists steering skills for preloading.
Users invoke Myna with: claude --agent myna (from any directory).
-->
```

**Identity & session start:**
- Who Myna is, what it does, vault path
- Read 6 config files from `{{VAULT_PATH}}/{{SUBFOLDER}}/_system/config/` on first user message

**Skill directory:**
A table of all 24 skills with name and one-line description. NO file paths. This is routing guidance — Claude Code handles loading.

**Routing logic:**
Route by user intent, not keywords. Include these sections:
- **Universal Done** — "done with X" resolves across meetings, tasks, drafts
- **Day Start, Planning, and End** — sync vs plan vs wrap-up vs weekly-summary
- **Inbox Routing** — "process my inbox" → always email-triage, not process-messages
- **Email/Message Processing** — process-messages vs draft-replies vs email-triage
- **Meeting Routing** — prep-meeting vs process-meeting
- **Writing Routing** — draft vs rewrite
- **Ambiguous Intent** — present options, ask
- **Safety Refusals** — "send this" → refuse. "Schedule meeting with attendees" → refuse.
- **Fallback** — out of scope, help, undo

**Do NOT include** a "Briefing and Status Routing" section — auto-invocation from skill descriptions handles brief-person/brief-project/team-health/unreplied-threads/blockers/1on1-analysis/performance-narrative routing.

**Direct operations** (handled without loading a skill):
- Vault search, link find, task completion, draft deletion, task move, file creation from template

**Rules:**
Brief reminders of critical rules (full details in steering skills). Draft-never-send, vault-only writes, never assume, no skill chaining, feature toggles, graceful degradation, one skill at a time.

### Agent frontmatter

The install script generates the frontmatter. Document the expected structure:
```yaml
---
name: myna
description: Personal assistant for tech professionals
skills:
  - myna-steering-safety
  - myna-steering-conventions
  - myna-steering-output
  - myna-steering-system
  - myna-steering-memory
  - myna-steering-vault-ops
---
```

## Part 2: Update install.sh

Read the current `install.sh` and update:

- **`copy_skills()` function:** copy `agents/skills/myna-*/SKILL.md` to `~/.claude/skills/myna-*/SKILL.md` (preserving directory structure). Include both feature skills and steering skills.
- **Directory creation:** replace `$MYNA_HOME/skills` with `$HOME/.claude/skills`
- **Agent file generation:** the generated agent file now has `skills:` in frontmatter listing the 5 steering skills. The body is just main.md content with placeholders substituted.
- **Header comment, manifest, summary output:** update all path references
- **`substitute_placeholders()`:** still needed for `{{VAULT_PATH}}` and `{{SUBFOLDER}}`

## Part 3: Update remaining files

Update these files for the new skill structure. The specific changes listed are starting points — **also search each file for any other stale references** to old skill names, old paths, old counts, or old mechanisms that need updating.

### `CLAUDE.md`
- Update skill file reference in the artifact table
- Update skill count
- Search for any other references to old skill structure

### `README.md`
- Update install description (skills → `~/.claude/skills/`)
- Update skill count and list
- Search for any stale references

### `docs/decisions.md`
- Add a new decision (next available D number) documenting the native Claude Code skills adoption: why, what changed, alternatives considered
- Check if any existing decisions need annotation (e.g., D049's description of `~/.myna/skills/`)

### `docs/roadmap.md`
- Update Phase 2 task status if applicable
- Update any skill references

### `docs/features/setup-and-config.md`
- Update any install-related feature descriptions

### `scripts/lint-agents.sh`
- Update skill file path expectations for new directory structure (`myna-*/SKILL.md`)
- Update skill count expectations
- Update cross-reference checks

### `tests/manual-test-checklist.md`
- Update references to skill file paths
- Update skill names throughout

### `agents/INSTALL-NOTES.md`
- Update for new install model (skills to `~/.claude/skills/`, steering as preloaded skills)

### `agents/myna-agent-template.md`
- Update template to reflect new agent frontmatter with `skills:` field

### `docs/vision.md`
- Check for any stale references

### Clean up old files
- Delete all old flat skill files: `agents/skills/brief.md`, `agents/skills/sync.md`, etc. (15 files)
- Delete old steering files: `agents/steering/safety.md`, `agents/steering/conventions.md`, etc. (5 files) — these are now under `agents/skills/myna-steering-*/`
- Delete MCP server directory: `agents/mcp/myna-obsidian/` — replaced by `myna-steering-vault-ops` skill
- Search the entire repo for any remaining references to old paths and fix them

## Git

Commit logically:

```bash
# Main agent rewrite
git add agents/main.md
git commit -m "feat(agents): rewrite main agent for native Claude Code skills"

# Install script
git add install.sh
git commit -m "feat(install): update install for ~/.claude/skills/ and steering preload"

# Delete old skill and steering files
git rm agents/skills/brief.md agents/skills/sync.md ... agents/steering/safety.md ...
git commit -m "refactor(agents): remove old flat skill and steering files"

# Doc updates
git add docs/ CLAUDE.md README.md agents/INSTALL-NOTES.md agents/myna-agent-template.md
git commit -m "docs: update all references for 24 native Claude Code skills"

# Supporting files
git add scripts/ tests/
git commit -m "chore: update lint script and test checklist for new skill structure"
```

After all commits, push:
```
git push origin main
```

## Verification

After all changes:
- `agents/main.md` references all 24 skills by name, no file paths
- `install.sh` copies to `~/.claude/skills/`, generates agent frontmatter with `skills:` field
- No old flat skill files remain under `agents/skills/` (only `myna-*/SKILL.md` directories)
- No old steering files remain under `agents/steering/` (only `agents/skills/myna-steering-*/`)
- `grep -rn "~/.myna/skills" .` — 0 matches in active files
- `grep -rn "agents/skills/brief\.md\|agents/skills/sync\.md\|agents/skills/draft\.md" .` — 0 matches
- `grep -rn "14 skills\|15 skills\|14 feature" docs/ CLAUDE.md README.md` — 0 matches (should say 24)
- `grep -rn "steering file" docs/ agents/ CLAUDE.md` — should say "steering skill" instead
- All cross-references between files are consistent
