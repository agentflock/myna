QA pass for format consistency across the Myna vault. Finds the #1 source of real bugs: multiple skills writing to the same vault destination with diverging formats. Reads canonical formats from foundations.md and the conventions steering skill, then reads each writing skill's actual format instructions and compares them. Reports exact divergences — which skill is wrong and what the correct format is.

This command reads, compares, and reports. It does NOT modify skill files. Use `/myna-skills-polish` to fix issues it surfaces.

## Arguments

$ARGUMENTS

Parse for:
- **No arguments:** default scope — check all shared destinations listed below against their writing skills
- **Destination name(s):** e.g., `timeline`, `contributions`, `review-queue` — check only those destinations
- **Skill path(s):** e.g., `agents/skills/myna-capture/SKILL.md` — check only the named skills against canonical formats for every destination they write
- `--uncommitted` — only check skills with uncommitted git changes
- Anything else: error out with a note on valid usage

## Step 1: Read Canonical Sources

Read these files in order. They are the source of truth — do not skip any.

**1a. `docs/design/foundations.md`**

Extract canonical entry formats for all shared destinations. Focus on:
- §2.1 Project File → `## Timeline` section — the timeline entry format, blocker callout format, decision callout format
- §2.2 Person File → `## Observations` section entry format, `## Recognition` section entry format
- §2.8 Contributions Log — the full entry format, frontmatter, and file-creation header
- §2.10 Review Queue Entry — the format for entries in review-work.md, review-people.md, review-self.md
- §2.10b Review Triage Entry — the format for entries in review-triage.md
- §2.6 Daily Note — section names with emoji, the `## End of Day` structure, `## Carry-Forwards` section format

**1b. `agents/skills/myna-steering-conventions/SKILL.md`**

Extract the authoritative entry format patterns from the "Entry Formats" section:
- Timeline Entry format string
- Observation format string (including `**{type}:**` bold prefix)
- Recognition format string
- Contribution format string (including `**{category}:**` bold prefix)
- Task format string (Obsidian Tasks plugin syntax with emojis and inline properties)
- Review Queue Entry format (the 4-field format: heading, Ambiguity, Proposed, Content)

Note any differences or refinements between foundations.md and the conventions skill. If they differ, the conventions skill is more authoritative for per-entry format details; foundations.md is more authoritative for file structure and section names.

**1c. `agents/skills/myna-steering-vault-ops/SKILL.md`**

Extract vault path patterns for all shared destinations. Build a lookup table:
- contributions file path pattern
- review queue file paths
- daily note path
- project file path pattern
- person file path pattern

---

## Step 2: Identify Writing Skills Per Destination

Use this authoritative map. Do not infer — this is the ground truth from `docs/architecture.md`:

### Shared destinations and their writing skills

| Destination | Writing skills |
|---|---|
| **Project timeline entries** (regular, decision callout, blocker callout) | myna-capture, myna-process-messages, myna-process-meeting, myna-sync (blockers surface; check if myna-sync writes to timelines) |
| **Person observations** (`## Observations` section) | myna-capture, myna-process-messages, myna-process-meeting |
| **Person recognition** (`## Recognition` section) | myna-capture, myna-process-messages, myna-process-meeting |
| **Contributions log** (`Journal/contributions-{YYYY-MM-DD}.md`) | myna-capture, myna-process-messages, myna-process-meeting, myna-wrap-up, myna-self-track |
| **Task entries** (in project files or daily note) | myna-capture, myna-process-messages, myna-process-meeting |
| **Review queue entries** (review-work, review-people, review-self) | myna-capture, myna-process-messages, myna-process-meeting, myna-email-triage (review-triage only), myna-wrap-up (review-self only) |
| **Daily note sections** | myna-sync (creates full structure + re-run snapshots), myna-wrap-up (End of Day section, Carry-Forwards to tomorrow's note) |

---

## Step 3: Read Each Writing Skill

Read every SKILL.md file in the writing-skills map above. For each file:

1. Find all sections that specify output format — look for code fences containing entry format strings, "Entry format:", "Format:", worked examples showing written output, or inline format examples.
2. Extract the **exact format string** each skill says it will write to each destination. Quote it verbatim — do not paraphrase.
3. Note the line number where the format appears.
4. If a skill has no explicit format instruction for a destination it writes to, flag this as a Critical issue — the skill relies on implicit format knowledge.

Skill files to read:
- `agents/skills/myna-capture/SKILL.md`
- `agents/skills/myna-process-messages/SKILL.md`
- `agents/skills/myna-process-meeting/SKILL.md`
- `agents/skills/myna-sync/SKILL.md`
- `agents/skills/myna-wrap-up/SKILL.md`
- `agents/skills/myna-self-track/SKILL.md`
- `agents/skills/myna-email-triage/SKILL.md`

---

## Step 4: Compare Each Destination

For each shared destination, compare every writing skill's format against the canonical format from Step 1.

### What to check for each format comparison

**Timeline entries:**
- Does the date+source header match `[{YYYY-MM-DD} | {source}]` exactly?
- Does the source value match conventions? (e.g., `email from Sarah`, `slack #channel`, `meeting {name}`, `capture`)
- Is the provenance marker present and in the right position — after content, before source-detail?
- Is the source-detail present in the right format — `({source-type}, {identity}, {date})`?
- For blocker callouts: is the callout type exactly `> [!warning] Blocker`?
- For decision callouts: is the callout type exactly `> [!info] Decision`?

**Person observations:**
- Is `**{type}:**` in bold with a colon, followed by the observation text?
- Are the valid types only: `strength`, `growth-area`, `contribution`?
- Is the date+source header format consistent?
- Is the provenance marker position consistent?

**Person recognition:**
- Does the format match the canonical recognition format (no `**{type}:**` prefix — recognition entries are not typed)?
- Is the dash separator `—` (em dash) used between what-they-did and context, or is a different separator used?

**Contributions log:**
- Is `**{category}:**` in bold with a colon?
- Does the source value in the date+source header match conventions for the writing skill (e.g., `wrap-up` for myna-wrap-up, `capture` for myna-capture)?
- Is the source-detail present as the last element?
- For myna-self-track: does the format omit source-detail when the user logs directly? (This is permitted — check if myna-self-track's format is intentionally simpler and document it.)
- Does the contributions file header format match? (frontmatter with `week_start`, `#contributions` tag, `## Contributions — Week of {YYYY-MM-DD}` heading)

**Task entries (Obsidian Tasks plugin format):**
- Is the task checkbox `- [ ]` at the start?
- Is the due date emoji `📅` (not a text date marker)?
- Is priority expressed as emoji: `⏫` high, `🔼` medium, omitted for low?
- Are inline properties using the `[field:: value]` syntax (double colon, no spaces around colons)?
- Are the correct field names used: `project::`, `type::`, `person::`, `effort::`, `review-status::`?
- Are valid `type::` values only: `task`, `delegation`, `dependency`, `reply-needed`, `retry`?
- Is provenance marker present?

**Review queue entries (review-work, review-people, review-self):**
- Does the entry use the 4-field format: checkbox heading, `Ambiguity:`, `Proposed:`, `Content:`?
- Is the heading bolded: `- [ ] **{heading}**`?
- Note: the conventions skill defines the format as `- [ ] **{heading}** — {source reference}` with a trailing em dash + source. Check whether each skill includes the source reference.
- Does the `Content:` field include the full entry that would be written if approved?

**Review triage entries (review-triage.md, myna-email-triage only):**
- Does the entry use the simpler triage format (not the full queue format)?
- Is the `## Triage — {YYYY-MM-DD}` section header present?
- Does each entry follow: `- [ ] **{subject}** — {sender}, {date}` + `Move to: **{folder}** — {reasoning}`?

**Daily note structure (myna-sync vs myna-wrap-up):**
- Do section names with emoji match between what myna-sync creates and what myna-wrap-up expects to find?
- Does myna-wrap-up's `## End of Day — {HH:MM}` section heading match the format in foundations.md `§2.6`?
- Does myna-wrap-up's carry-forward section heading `## Carry-Forwards from {YYYY-MM-DD}` match foundations.md? (foundations calls it `### Carried to Tomorrow` — flag if there's a mismatch)
- Does myna-wrap-up's contribution entry in the End of Day section under `### Contributions Detected` match the format in foundations.md `§2.6`?

---

## Step 5: Scope Filtering

If `$ARGUMENTS` specified destinations or skill paths, filter results to only those. For `--uncommitted`, get the list of changed skill files via `git diff --name-only HEAD` filtered to `agents/skills/`, then check only those skills.

---

## Step 6: Determine Report Number

Check `docs/reviews/` for existing `consistency-*.md` files. The next number is the highest existing N + 1, zero-padded to 3 digits. If no consistency reports exist, start at `001`. Create `docs/reviews/` if it doesn't exist.

---

## Step 7: Write the Report

Save to `docs/reviews/consistency-{NNN}.md`.

### Report format

```
# Myna Consistency Review — {NNN}

**Date:** {YYYY-MM-DD}
**Scope:** {what was checked — all destinations / specific destinations / specific skills}
**Canonical sources:** docs/design/foundations.md, agents/skills/myna-steering-conventions/SKILL.md

## Summary

| Destination | Skills checked | Consistent | Issues |
|---|---|---|---|
| Project timeline entries | {N} | {yes/no} | {count} |
| Person observations | {N} | {yes/no} | {count} |
| Person recognition | {N} | {yes/no} | {count} |
| Contributions log | {N} | {yes/no} | {count} |
| Task entries | {N} | {yes/no} | {count} |
| Review queue entries | {N} | {yes/no} | {count} |
| Review triage entries | {N} | {yes/no} | {count} |
| Daily note sections | {N} | {yes/no} | {count} |

**Total destinations checked:** {N}
**Fully consistent:** {N}
**Has issues:** {N}
**Total issues:** {Critical: N, Important: N, Minor: N, Nitpick: N}

---

## Results by Destination

### {Destination Name}

**Canonical format** (from {source file}, line {N}):
```
{exact canonical format string}
```

#### myna-{skill-a}

**Format as written** (line {N}):
```
{exact format string from skill}
```

**Verdict:** CONSISTENT / INCONSISTENT

{If INCONSISTENT:}
**Divergences:**
- [{severity code}] {what differs} — canonical has `{X}`, skill has `{Y}`. Canonical source is correct.

#### myna-{skill-b}

{...same structure...}

---

{repeat for each destination}

---

## All Issues by Severity

### Critical [C]

- [C01] `{skill-name}` — `{destination}` — {description of issue}
  Canonical: `{correct format}`
  Actual: `{incorrect format in skill}`
  Fix: {specific edit needed}

### Important [I]

- [I01] ...

### Minor [M]

- [M01] ...

### Nitpick [N]

- [N01] ...

---

## Skills with No Format Instructions for Destinations They Write

{If any: list skill + destination + note that this is a Critical gap}

---

## Notes

{Any observations that don't fit neatly into issue categories — e.g., intentional format variations that are documented, cross-cutting patterns, places where the canonical format itself may be ambiguous}
```

---

## Severity Definitions

Assign severity based on real-world impact:

| Severity | Code | Meaning |
|---|---|---|
| Critical | C | Vault entries from two skills would be unreadable to the other or cause data loss — e.g., wrong section name means entries go to wrong place, missing field breaks a Dataview query |
| Important | I | Format drift that causes visual inconsistency or makes vault queries unreliable — e.g., different provenance marker position, missing source-detail |
| Minor | M | Small wording or punctuation differences that don't affect function — e.g., em dash vs hyphen in recognition entries |
| Nitpick | N | Cosmetic only — e.g., extra space, slightly different example phrasing |

---

## After Writing the Report

Print to the user:

```
Consistency Review {NNN} complete.
Report: docs/reviews/consistency-{NNN}.md

Destinations checked: {N}
  Fully consistent: {N}
  Has issues: {N}

Issues: {C} critical, {I} important, {M} minor, {N} nitpick

{If critical issues:}
Critical issues require immediate fixes — run /myna-skills-polish on the affected skills.

{Top 3 issues by severity, one line each:}
- [C01] {skill}: {one-line description}
- [I01] {skill}: {one-line description}
- [M01] {skill}: {one-line description}
```

## Rules

- Never modify skill files. Read and report only.
- Quote formats verbatim from both canonical source and skill — do not paraphrase.
- Cite line numbers for every quoted format.
- If a skill's format matches canonical, say CONSISTENT and move on — do not manufacture findings.
- If the canonical format itself is ambiguous or contradictory between foundations.md and the conventions skill, note it in the Notes section and apply the conventions skill as the tiebreaker.
- Do not flag differences in worked examples (illustrative examples may use different dates/names) — only flag differences in the format instruction itself.
- Intentional format differences (e.g., myna-self-track omitting source-detail for direct user logs) are not bugs if the difference is documented in the skill. Flag as Nitpick with a note that it appears intentional.
