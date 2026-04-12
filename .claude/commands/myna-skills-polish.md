Review and fix Myna skills (Claude Code SKILL.md files) in one pass — frontmatter correctness, description quality, instruction clarity, tool declarations, feature completeness, safety, edge cases, conciseness, consistency, and output usefulness. Fixes issues directly, then generates a report of what was found and changed.

This command is narrower than `/myna-improve` (skills only, no steering/main) and narrower than `/myna-review` (skills only, tuned dimensions), but broader than a prose-only tightening pass. Use this when you want a comprehensive quality pass on the skills set. Expected to be long-running.

## Arguments

$ARGUMENTS

Parse for:
- **Scope:** file paths, glob patterns, `--uncommitted`, or default to `agents/skills/myna-*/SKILL.md` (excludes steering skills)
- `--include-steering` — also review `agents/skills/myna-steering-*/SKILL.md`
- Anything else: error out with a note on valid usage

## Setup (orchestrator reads once)

Read these files ONCE before spawning any subagents. You will pass the extracted content inline to each subagent — subagents do not read these files themselves.

1. `agents/skills/myna-steering-*/SKILL.md` — read all six. Extract the full text of each.
2. `docs/architecture.md` — for each in-scope skill, extract its "Features covered:" line and the vault destinations it writes to.
3. `docs/design/foundations.md` — extract the canonical templates for every vault destination written by any in-scope skill.
4. `docs/decisions.md` — extract the list of deferred features and the Golden Rule.
5. `docs/features/*.md` — read only the feature files that map to in-scope skills.

## Scope resolution

- No arguments → `agents/skills/myna-*/SKILL.md` (all feature skills, excludes steering)
- `--include-steering` → also include `agents/skills/myna-steering-*/SKILL.md`
- Paths or glob → resolve and review matching files
- `--uncommitted` → only skills with uncommitted git changes under `agents/skills/`
- If the resolved scope is empty, error out.

## Review methodology

**One subagent per skill, all in parallel.** Each subagent gets only what it needs — shared context is passed inline, not re-read from disk.

**If scope has 1–3 skills:** review and fix directly in the main context using the criteria below. No subagents needed.

**If scope has 4+ skills:** spawn one subagent per skill (`subagent_type=general-purpose`, `model=sonnet`), all in a single message. Each subagent receives its prompt with shared context already inlined — no disk reads needed except for the skill file itself and its feature file(s).

**Batch spawning:** If you can't spawn all at once, do it in as-large-as-possible batches. Wait for each batch before spawning the next.

### Subagent task prompt

For each skill, construct the prompt by filling in ALL placeholders below, then pass it to the subagent. Do not tell the subagent to read shared files — you've already read them and will inline the content.

---

You are reviewing and fixing ONE Claude Code skill file. These are `SKILL.md` files with YAML frontmatter that Claude Code loads as persistent prompts.

**Skill to review and fix:** {SKILL_PATH}

Follow these steps IN ORDER. Do not skip any step.

---

**STEP 1: Read the skill file and its feature file(s).**

Read `{SKILL_PATH}` in full. Note the line count.

Also read: `{FEATURE_FILE_PATHS}` — the feature spec(s) for this skill.

(All other context is provided inline below. Do not read any other files.)

---

**STEP 2: Review context (provided by orchestrator — do not re-read from disk)**

**This skill's feature assignment** (from architecture.md):
```
{SKILL_FEATURE_ASSIGNMENT}
```

**Vault destinations this skill writes to, with canonical templates** (from foundations.md):
```
{RELEVANT_VAULT_TEMPLATES}
```

**Deferred features** (from decisions.md — do not add these):
```
{DEFERRED_FEATURES_LIST}
```

**Steering skills — full text** (feature skills must not duplicate these rules):

*myna-steering-safety:*
```
{STEERING_SAFETY_TEXT}
```

*myna-steering-conventions:*
```
{STEERING_CONVENTIONS_TEXT}
```

*myna-steering-output:*
```
{STEERING_OUTPUT_TEXT}
```

*myna-steering-system:*
```
{STEERING_SYSTEM_TEXT}
```

*myna-steering-memory:*
```
{STEERING_MEMORY_TEXT}
```

*myna-steering-vault-ops:*
```
{STEERING_VAULT_OPS_TEXT}
```

---

**STEP 2: Evaluate against each criterion below.** Go through them one by one. For each, write down your findings before moving to the next. Do not skip criteria even if the skill looks fine — write "no issues" for that criterion.

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

**STEP 3: Fix every issue you found.**

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

**STEP 4: Re-read the full skill file** after all edits. Verify it still makes sense as a whole. Note the new line count.

---

**STEP 5: Return your report** in this exact format:

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
