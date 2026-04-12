# P5: Generate Vault Templates

## Setup

**Model:** Sonnet | **Effort:** Medium
**Output:** 6 template files in `agents/templates/`

## Context

Myna skills reference templates at `_system/templates/` in the vault for creating new files (projects, people, meetings, weekly notes). Currently these templates don't exist anywhere — the skills fall back to inline minimal structures. We need to create canonical template files that the install script copies into the vault.

The templates live in the repo at `agents/templates/` and install copies them to `{vault}/{subfolder}/_system/templates/`.

## Read first

1. `agents/skills/myna-capture/SKILL.md` — lines 280-360: project and person file creation (inline fallback structures)
2. `agents/skills/myna-prep-meeting/SKILL.md` — lines 210-245: meeting file templates (1:1, recurring, adhoc)
3. `agents/skills/myna-sync/SKILL.md` — lines 44-85: weekly note template
4. `agents/skills/myna-steering-vault-ops/SKILL.md` — lines 79-104: template creation pattern and vault path conventions
5. `docs/design/foundations.md` — canonical file formats, frontmatter conventions, tag conventions
6. `agents/skills/myna-performance-narrative/SKILL.md` — lines 36-38: what fields are read from person files (tells you what sections matter)
7. `agents/skills/myna-prep-meeting/SKILL.md` — lines 100-130: what's read from person files during 1:1 prep
8. `agents/skills/myna-brief-person/SKILL.md` — lines 24-30: what's read from person files during person briefs

## Critical: No YAML frontmatter

**Do NOT use YAML frontmatter (`---` blocks) in any template.** All metadata goes inline as `#tags` on the first line of the file. This is how the user's Obsidian vault works.

Instead of:
```markdown
---
type: 1-1
person: [[sarah-chen]]
created: 2026-04-10
---
#meeting #1-1
```

Do this:
```markdown
#meeting #1-1 #person/{{person-slug}}
```

Metadata that was previously in frontmatter becomes either:
- **Tags:** `#type/value` — for typed metadata (e.g., `#status/active`, `#type/1-1`, `#tier/direct`)
- **Inline fields:** `**Key:** value` in the Overview section — for human-readable info (name, role, team, description)
- **Wiki-links:** `[[slug]]` — for entity references (person, project)

**This also means the skills' inline fallback structures need updating.** After generating the templates, grep all skills for YAML frontmatter in file-creation examples and update them to use `#tags` instead. The steering skill `myna-steering-vault-ops` "Template Creation" section must also be updated to reflect this pattern.

## Templates to generate

### 1. `agents/templates/project.md`

A new project file. Must include:
- First line tags: `#project #{{project-tag}}` + `#status/active`
- Sections: Overview (description, status, key people), Timeline (append-only log), Open Tasks (with dataview query placeholder), Links, Notes
- Use `{{variable}}` syntax for all placeholders (matches the substitution pattern in `myna-steering-vault-ops`)

Reference: `myna-capture/SKILL.md` lines 287-318

### 2. `agents/templates/person.md`

A new person file. Must include:
- First line tags: `#person` + `#tier/{{relationship-tier}}`
- Sections: Overview (name, role, team, relationship), Communication Preferences, Observations, Pending Feedback, Recognition, Personal Notes, Meeting History
- The sections must match what `myna-performance-narrative`, `myna-prep-meeting`, and `myna-brief-person` read from person files

Reference: `myna-capture/SKILL.md` lines 329-358

### 3. `agents/templates/meeting-1-1.md`

A 1:1 meeting file (accumulates sessions over time).
- First line tags: `#meeting #1-1` + `#person/{{person-slug}}`
- Person wiki-link: `[[{{person-slug}}]]` in Overview or inline
- No session content — sessions are appended by `myna-sync` and `myna-prep-meeting`

Reference: `myna-prep-meeting/SKILL.md` lines 216-225

### 4. `agents/templates/meeting-recurring.md`

A recurring meeting file.
- First line tags: `#meeting #recurring`
- Project wiki-link if applicable: `[[{{project-slug}}]]`

Reference: `myna-prep-meeting/SKILL.md` lines 227-235

### 5. `agents/templates/meeting-adhoc.md`

An adhoc/one-off meeting file.
- First line tags: `#meeting #adhoc`

Reference: `myna-prep-meeting/SKILL.md` lines 237-244

### 6. `agents/templates/weekly-note.md`

A weekly note created on Mondays.
- First line tags: `#weekly`
- Sections: Week Capacity (table with Mon-Fri columns for meetings/focus/task effort), Weekly Goals (user-editable), Carry-Forwards
- Match the structure in `myna-sync/SKILL.md` lines 50-73 but without YAML frontmatter

Reference: `myna-sync/SKILL.md` lines 48-85

## Constraints

- **No YAML frontmatter anywhere.** All metadata as `#tags` on the first line.
- Use `{{variable}}` placeholder syntax consistently (double curly braces)
- Keep templates lean — they should be the "right" starting structure, not documentation. No instructional comments or explanations inside the template content.
- Tags go on the first line of the file
- Section headers use `##` for top-level sections within the file
- Templates must be valid markdown that Obsidian renders cleanly even before substitution

## Skill updates (required)

After generating templates, update the inline fallback structures in these skills to remove YAML frontmatter and use `#tags` instead:

1. `agents/skills/myna-capture/SKILL.md` — project creation (lines ~289-314) and person creation (lines ~331-358)
2. `agents/skills/myna-prep-meeting/SKILL.md` — meeting file creation (lines ~216-244)
3. `agents/skills/myna-sync/SKILL.md` — weekly note creation (lines ~50-73) and meeting file creation (lines ~210-234)
4. `agents/skills/myna-steering-vault-ops/SKILL.md` — "Template Creation" section (lines ~79-88)

The inline fallbacks should match the templates exactly — they're the same content, just hardcoded as a fallback.

## Install script update

After creating the templates, update `install.sh` to copy them:

1. Add a new step after "Setting up config files" that copies `agents/templates/*.md` → `$MYNA_ROOT/_system/templates/`
2. Same pattern as config files: always refresh templates on install (they're system files, not user-editable)
3. Report count: `info "Installed N templates"`

## Verification

After writing all files, confirm:
- [ ] All 6 template files exist in `agents/templates/`
- [ ] No template contains YAML frontmatter (`---` blocks)
- [ ] Each template's sections match what the consuming skills expect to read
- [ ] `{{placeholder}}` syntax is used consistently
- [ ] `install.sh` copies templates to the vault
- [ ] Templates render as valid markdown
- [ ] All inline fallback structures in skills updated to match (no YAML frontmatter)
- [ ] `myna-steering-vault-ops` Template Creation section updated to describe tags-only pattern
