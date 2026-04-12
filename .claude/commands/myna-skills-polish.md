Review and fix Myna skills (Claude Code SKILL.md files) in one pass — frontmatter correctness, description quality, instruction clarity, tool declarations, feature completeness, safety, edge cases, conciseness, consistency, and output usefulness. Fixes issues directly, then generates a report of what was found and changed.

This command is narrower than `/myna-improve` (skills only, no steering/main) and narrower than `/myna-review` (skills only, tuned dimensions), but broader than a prose-only tightening pass. Use this when you want a comprehensive quality pass on the skills set. Expected to be long-running.

## Arguments

$ARGUMENTS

Parse for:
- **Scope:** file paths, glob patterns, `--uncommitted`, or default to `agents/skills/myna-*/SKILL.md` (excludes steering skills)
- `--include-steering` — also review `agents/skills/myna-steering-*/SKILL.md`
- Anything else: error out with a note on valid usage

## Setup

Read project context before reviewing:

1. `CLAUDE.md` — ground rules
2. `agents/skills/myna-steering-*/SKILL.md` — all six steering skills (safety, conventions, output, system, memory, vault-ops). These are the cross-cutting rules. Feature skills should not duplicate what steering already covers.
3. `docs/architecture.md` — skill inventory and "Features covered:" mapping. This is authoritative for what each skill owns.
4. `docs/design/foundations.md` — skills section, canonical vault templates, shared destination formats
5. `docs/decisions.md` — settled decisions. Pay attention to the Golden Rule, draft-never-send, no skill chaining, and anything marked deferred so you don't propose out-of-scope fixes.
6. `docs/features/*.md` — only the feature files that map to skills in scope, per architecture.md

Build a mental map of each in-scope skill → its owning feature(s) + the shared vault destinations it writes to. You'll need both to evaluate feature completeness and cross-skill consistency.

## Scope resolution

- No arguments → `agents/skills/myna-*/SKILL.md` (all feature skills, excludes steering)
- `--include-steering` → also include `agents/skills/myna-steering-*/SKILL.md`
- Paths or glob → resolve and review matching files
- `--uncommitted` → only skills with uncommitted git changes under `agents/skills/`
- If the resolved scope is empty, error out.

## Review methodology

**One subagent per skill.** Each skill gets its own dedicated reviewer subagent with full context. This prevents reviewers from rushing through later skills as their context fills up, and ensures every skill gets the same depth of attention whether it's the 1st or the 24th.

**If scope has 1–3 skills:** review them directly in the main context. Skip subagents — the overhead isn't worth it for a tiny batch.

**If scope has 4+ skills:** spawn one subagent per skill, all in parallel (multiple Agent tool calls in a single message), `subagent_type=general-purpose`, `model=sonnet`. Yes, this means 24 parallel subagents for a full review. That's fine — thoroughness matters more than speed. The command is expected to be long-running.

**Batch spawning limit:** If the number of skills exceeds what you can spawn in a single message, spawn them in batches. Wait for each batch to complete before spawning the next. Each batch should be as large as possible.

### Subagent task prompt

Pass each subagent this exact prompt, substituting the skill path:

---

You are reviewing and fixing ONE Claude Code skill file. These are `SKILL.md` files with YAML frontmatter that Claude Code loads as persistent prompts.

**Skill to review and fix:** {SKILL_PATH}

Follow these steps IN ORDER. Do not skip any step.

---

**STEP 1: Read context files.**

Read ALL of these before touching the skill:
- `CLAUDE.md`
- `agents/skills/myna-steering-*/SKILL.md` — all six steering skills
- `docs/architecture.md` — find this skill's "Features covered:" line
- `docs/design/foundations.md` — skills section, canonical vault templates
- `docs/features/{domain}.md` — the feature file(s) for this skill (check architecture.md for the mapping)
- `docs/decisions.md` — note deferred features so you don't add them

---

**STEP 2: Read the skill file in full.** Read it top to bottom. Note the line count.

---

**STEP 3: Evaluate against each criterion below.** Go through them one by one. For each, write down your findings before moving to the next. Do not skip criteria even if the skill looks fine — write "no issues" for that criterion.

**Criterion 1 — Frontmatter correctness.** Valid YAML between `---` markers. Check each field:
- `name:` — lowercase, hyphens only, matches directory name, max 64 chars
- `description:` — present, under 250 chars, front-loads the use case, includes trigger keywords, differentiates from sibling skills
- `user-invocable:` — `true` for user-facing, `false` for background/steering
- `argument-hint:` — present for user-invocable skills, shows example syntax
- No unknown fields. Valid fields: `name`, `description`, `user-invocable`, `argument-hint`, `disable-model-invocation`, `allowed-tools`, `model`, `effort`, `context`, `agent`, `paths`, `shell`, `hooks`
- No missing fields (e.g., should it have `allowed-tools` for MCP operations?)

**Criterion 2 — Instruction clarity.** Can Claude execute every step without guessing?
- No vague verbs ("determine the appropriate…", "handle this case")
- Every branch has a concrete decision criterion
- No ambiguous pronouns ("update it" — what is "it"?)
- File paths are specific (`_system/config/workspace.yaml`, not "the config file")
- MCP tool usage is explicit (which MCP, what operation)
- Instructions that contradict each other across sections
- Steps that say "if X, do Y" without defining how to detect X
- Implicit assumptions (assumes a config field exists without fallback)

**Criterion 3 — Structure and conciseness.** Does the file work well as a Claude Code skill?
- Most important constraints front-loaded, not buried at line 300+
- Standing rules separated from sequential steps
- Numbered lists for workflows, bullets for rules
- Decision/trigger tables for multi-mode skills (verify correctness)
- Worked examples present for complex procedures
- File under 500 lines (flag sections that are bloated):
  - Worked examples longer than the procedure they illustrate
  - Edge cases Claude would handle by default
  - Repeated explanations across sections
  - "What this skill does NOT do" that restates the description
- Golden Rule: would Claude produce the same output without this line? If yes, delete it.

**Criterion 4 — Feature completeness.** Cross-reference architecture.md "Features covered:" with `docs/features/*.md`:
- Does the skill have executable steps for every assigned feature?
- "Mentioned" is not enough — the procedure must tell Claude what to read, decide, and write

**Criterion 5 — Correctness.** Does the procedure produce the right vault state?
- Read/write paths match canonical templates in foundations.md
- File names, section names, field names are accurate
- Config field references spelled correctly
- Frontmatter templates match canonical format
- Shared destination formatting matches other skills (check foundations.md)

**Criterion 6 — Safety.** Check all of these:
- Draft-never-send: no code path leads to sending/posting anything
- Vault-only writes: nothing outside the configured vault path
- No automatic skill chaining
- Calendar three-layer protection (if applicable)
- External content wrapped in safety delimiters before reasoning
- Confirmation for bulk writes (5+ files)
- No overly permissive tool declarations

**Criterion 7 — Edge cases.** Are these handled?
- First run (empty vault, no daily note, no person/project files)
- Missing referenced files
- Ambiguous entity resolution (two people with same name)
- Empty MCP results
- Bulk operations (5+ items)
- Re-run idempotency
- Missing config or disabled feature toggle

**Criterion 8 — Output usefulness.** Check against `agents/skills/myna-steering-output/SKILL.md`:
- Output is specific and actionable (counts, file links, next steps)
- Not generic or verbose
- User can figure out how to invoke the skill from description + argument-hint alone

**Criterion 9 — Duplication with steering.** Compare against the six steering skills:
- Flag any rules that duplicate what a steering skill already covers (cite which one)
- These duplicates should be removed from the feature skill

---

**STEP 4: Fix every issue you found.**

Work in priority order: Critical → Important → Minor. For each fix:
1. Edit the skill file using the Edit tool.
2. Re-read the changed section to verify it reads naturally.
3. If you touched frontmatter, verify YAML is still valid.

**Do NOT fix** (flag in your report instead):
- Issues that would add features not in architecture.md's assignment for this skill
- Deferred features from decisions.md
- Rules that should be promoted to steering (note which steering skill)
- Issues where the right fix is genuinely unclear

---

**STEP 5: Re-read the full skill file** after all edits. Verify it still makes sense as a whole. Note the new line count.

---

**STEP 6: Return your report** in this exact format:

```
### {skill-directory-name}/SKILL.md

Lines: {old} → {new}
Verdict: keep | trim | restructure | rework

**Frontmatter:** {ok | list specific issues}

**Holistic assessment:**
- Length: {right-sized | too long by ~N lines | too short}
- Bloat spots: {line ranges, or "none"}
- Ambiguity/contradiction spots: {line ranges, or "none"}
- Structure: {well-organized | needs reorg — explain}

**Findings:**
1. [{criterion number}] ({Critical|Important|Minor}) **FIXED** — {one-line issue}
   Was: "{original text}" (line N)
   Now: "{new text or description of change}"
2. [{criterion number}] ({Critical|Important|Minor}) **FLAGGED** — {one-line issue}
   Text: "{problem text}" (line N)
   Reason not fixed: {why}
3. ...

**Strengths:** {1-2 bullets}

**Cross-cutting notes:**
- Steering duplicates: {list, or "none"}
- Shared-destination drift: {list, or "none"}
- Overlap with other skills: {list, or "none"}
```

**Rules:**
- Quote specific text and cite original line numbers (before your edits)
- Ground every finding in a concrete reference (steering skill, feature spec, foundations template, Claude Code best practice)
- No vague criticism ("feels wordy"). Cite what's wrong and why.
- Don't manufacture findings. If the skill is solid, say so.
- Severity: **Critical** = breaks functionality, safety violation, skill undiscoverable. **Important** = Claude would struggle, sub-feature missing, significant bloat. **Minor** = polish, Golden Rule, slight inconsistency.

---

## After subagents complete

1. **Cross-skill consistency check.** Read every modified skill file. Check that skills writing to the same vault destinations still produce identical formatting. Fix any inconsistencies introduced by subagent edits.

2. **Write the report** to `docs/reviews/skills-polish-{NNN}.md`. Cycle number: highest existing `skills-polish-*.md` + 1, starting at `001`. Create `docs/reviews/` if needed.

   Report format:
   ```
   # Myna Skills Polish — Cycle {NNN}

   **Date:** {YYYY-MM-DD}
   **Scope:** {what was reviewed}
   **Skills reviewed:** {count}

   ## Summary

   | Skill | Before | After | Fixed | Flagged | Verdict |
   |---|---|---|---|---|---|
   | {name} | {old lines} | {new lines} | {n} | {n} | {verdict} |

   Total: {fixed} fixed, {flagged} flagged across {n} skills

   ## Per-skill details

   {each subagent's report, consolidated}

   ## Flagged issues (need human decision)

   {all FLAGGED items, grouped by reason}
   ```

3. **Lint check.** Run `bash scripts/lint-agents-1.sh` if it exists. Fix failures.

4. **Commit.** Stage all modified skill files and the report file. One commit for the entire review+fix run:
   ```
   fix(agents): skills polish cycle {NNN} — {n} issues fixed across {n} skills
   ```
   Do not add Co-Authored-By lines.

5. **Print summary** to the user:
   ```
   Myna Skills Polish — Cycle {NNN} complete
   Report: docs/reviews/skills-polish-{NNN}.md

   {fixed} issues fixed across {n} skills
   {flagged} issues flagged for human review

   Skills modified:
   - {skill}: {old lines} → {new lines}
   ```

## Rules

- Do not touch steering skills unless `--include-steering` was passed. Flag steering issues instead.
- If a rule duplicates a steering skill, remove it from the feature skill.
- Golden Rule: would Claude behave the same without this line? If yes, delete it.
- Do not invent new conventions. Match existing patterns.
- Do not add features beyond v1 scope (check decisions.md).
- If scope is 1–3 skills, skip subagents — review and fix directly.
