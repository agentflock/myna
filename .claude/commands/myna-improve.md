Run the full Myna quality pipeline end-to-end: lint until clean, then run Review/Fix/Verify cycles until issues are resolved or the cycle limit is reached. Long-running — every phase gets full attention. This command is self-contained and does not call other commands as subcommands; it executes each phase directly.

**Role:** Engineering Manager — orchestrates the full pipeline, monitors progress, knows when to stop early, and prevents thrashing.

## Arguments

$ARGUMENTS

Parse for:
- `--cycles N` — max Review/Fix/Verify cycles to run (default: 3, min: 1, max: 10)
- **Scope:** file paths, glob patterns, or `--uncommitted` for skills with uncommitted git changes under `agents/skills/`
- No scope argument → all feature skills (`agents/skills/myna-*/SKILL.md`, excluding steering) plus `agents/main.md`
- `--include-steering` — also include `agents/skills/myna-steering-*/SKILL.md` in the review scope
- Anything else: error out with a note on valid arguments

If scope resolves to zero files, error out before doing any work.

---

## Setup — Read Context Before Starting

Read ALL of the following before beginning. Do not skip any file.

1. `CLAUDE.md` — ground rules and decisions
2. `agents/skills/myna-steering-*/SKILL.md` — all six steering skills (safety, conventions, output, system, memory, vault-ops). These define the cross-cutting rules feature skills must not duplicate.
3. `docs/architecture.md` — sections 1–2. Authoritative skill inventory and "Features covered:" mapping.
4. `docs/design/foundations.md` — canonical vault formats, path patterns, file templates, entry formats.
5. `docs/decisions.md` — settled decisions. Note anything deferred so you don't propose out-of-scope fixes.
6. `scripts/lint-agents.sh` — read this file to understand exactly what the lint script checks. You'll be interpreting its output throughout Phase 0.
7. `docs/features/*.md` — only feature files that map to skills in scope (check architecture.md for the mapping).

Build a mental map: each in-scope skill → its owning features → the shared vault destinations it writes to. You'll need this for feature completeness and cross-skill consistency checks.

**Determine the next cycle number** before proceeding. Check `docs/reviews/` for the highest existing `review-{NNN}.md`. The next cycle is that number + 1, starting at `001` if none exist. All reports from this run share the same numbering sequence (e.g., `review-004.md`, `fix-004.md`, `verify-004.md` for cycle 004). Each subsequent cycle increments by one.

Print a startup summary:
```
Myna Improve — starting
Scope: {N} skills + main agent [+ steering if --include-steering]
Max cycles: {N}
Starting cycle number: {NNN}
```

---

## Phase 0 — Lint

**Goal:** Clean lint before any review work. Lint errors in shipped artifacts are blocking — no review cycle starts until lint passes.

### Step 0.1: Run the lint script

```bash
bash scripts/lint-agents.sh
```

Read the full output. The script exits non-zero if there are any FAIL items.

### Step 0.2: Fix all FAIL items

For each FAIL item, go to the flagged file and fix the specific issue. Lint checks are mechanical — fixes are also mechanical. The checks are:

1. **Self-containment:** No references to `foundations.md`, `architecture.md`, `decisions.md`, `docs/` paths, or decision IDs (`D001`–`D999`) in shipped artifacts. Remove or rewrite any such references — these docs don't exist at runtime.
2. **Skill structure:** Every feature skill must have at least 3 H2 sections and 50+ lines of content. Section names are free-form — skills choose their own structure. H1 heading is optional.
3. **Worked examples:** Every feature skill must have either a heading containing "Example" or "Worked", or inline example content (patterns like "User says", "User:", "Example:", "→"). Add examples if missing.
4. **Skill directory cross-reference:** Every skill listed in `agents/main.md`'s skill table must have a matching `agents/skills/{name}/SKILL.md`. Every skill directory must be listed in `agents/main.md`. Fix the gap in whichever direction is correct.
5. **Steering skills:** All six `myna-steering-{safety,conventions,output,system,memory,vault-ops}/SKILL.md` files must exist. If missing, this is a structural problem — flag it rather than creating empty stubs.
6. **Safety keywords:** `send`, `post`, `deliver` (and their variants) outside of a clear refusal/safety context are warnings, not errors. Review each warning, and if the context is ambiguous, tighten the language.
7. **Frontmatter:** Every `SKILL.md` must have a `---` block with `name:` and `description:`. Fix any that are missing.
8. **Config examples:** All six `agents/config-examples/{workspace,projects,people,meetings,communication-style,tags}.yaml.example` files must exist. If missing, this is structural — flag it.

WARN items are not blocking, but review each one. If you can fix a warning in under two edits, fix it. Otherwise, note it in the final summary.

### Step 0.3: Re-run until clean

After fixing, re-run `bash scripts/lint-agents.sh`. Repeat until exit code is 0 (no FAIL items).

**If lint cannot be fixed** (e.g., missing structural files that require human decisions): stop the pipeline, report what's broken, and exit. Do not proceed to review cycles with a failing lint.

### Step 0.4: Record lint outcome

Note: how many FAIL items were found, how many were fixed, and how many re-runs were needed. Include this in the final summary.

---

## Phase 1-N — Review/Fix/Verify Cycles

Run up to `--cycles N` cycles (default 3). Each cycle has three phases: Review, Fix, Verify.

**Before each cycle:** check the oscillation guard (see below). If it triggers, stop immediately.

### Cycle Numbering

Cycles are labeled by their report number (`NNN`), not their relative position in this run. Cycle 1 of this run might produce `review-004.md` if three prior cycles exist. Always use the absolute number in filenames and output.

---

### Review Phase — Evaluate All In-Scope Skills

**Scope:** all skills resolved at startup (plus `agents/main.md`).

**One subagent per skill for 4+ skills.** For 1–3 skills, review directly in main context.

For 4+ skills: spawn one subagent per skill, all in parallel (`subagent_type=general-purpose`, `model=sonnet`). If the skill count exceeds what you can spawn in one message, batch them — each batch as large as possible, wait for each batch to complete before spawning the next.

#### Subagent prompt for each skill

Pass this exact prompt, substituting the skill path:

---

You are evaluating ONE Claude Code skill file for the Myna project. These are `SKILL.md` files with YAML frontmatter that Claude Code loads as persistent prompts.

**Skill to evaluate:** {SKILL_PATH}

**STEP 1: Read context files.**

Read ALL of these before evaluating the skill:
- `CLAUDE.md`
- `agents/skills/myna-steering-*/SKILL.md` — all six steering skills
- `docs/architecture.md` — find this skill's "Features covered:" line and example triggers
- `docs/design/foundations.md` — canonical vault formats and path patterns
- `docs/features/{domain}.md` — the feature file(s) for this skill (per architecture.md's mapping)
- `docs/decisions.md` — note deferred features so you don't flag missing out-of-scope content

**STEP 2: Read the skill file in full.** Top to bottom. Note line count.

**STEP 3: Evaluate against each dimension.** Go through each one. Write your findings before moving to the next. Write "no issues" if the skill is clean on that dimension — don't skip.

**Dimension 1 — Frontmatter quality.**
- `name:` lowercase, hyphens only, matches directory name, max 64 chars
- `description:` present, under 250 chars, front-loads the use case, includes trigger keywords, differentiates from sibling skills. This is Claude's only context until the skill is invoked — it must be good.
- `user-invocable:` set to `true` for user-facing skills, `false` for background/steering. Default is `true`.
- `argument-hint:` present for user-invocable skills, shows realistic example syntax
- Valid fields only: `name`, `description`, `user-invocable`, `argument-hint`, `disable-model-invocation`, `allowed-tools`, `model`, `effort`, `context`, `agent`, `paths`, `shell`, `hooks`

**Dimension 2 — Auto-discovery.** Would Claude load this skill at the right moment?
- Does the description include words the user would naturally say?
- If the skill has `disable-model-invocation: true`, is that intentional? Should it?
- Could the description be confused with a sibling skill?

**Dimension 3 — Instruction clarity.** Can Claude execute every step without guessing?
- No vague verbs ("determine the appropriate…", "handle this case", "process accordingly")
- Every branch has a concrete decision criterion
- File paths are specific (`_system/config/workspace.yaml`, not "the config file")
- MCP tool usage is explicit — which MCP, what operation
- No implicit assumptions (config field assumed to exist without a fallback)
- No contradictions between sections
- Steps that say "if X, do Y" define how to detect X

**Dimension 4 — Feature coverage.** Cross-reference architecture.md "Features covered:" with `docs/features/*.md`.
- Does the skill have executable steps for every assigned feature?
- "Mentioned" is not enough — the procedure must tell Claude what to read, decide, and write for each feature.
- Do not flag missing deferred features (check decisions.md).

**Dimension 5 — Vault format correctness.** Does the procedure produce the right vault state?
- Read/write paths match foundations.md canonical patterns
- File names, section names, field names spelled correctly
- Config field references match workspace.yaml schema
- Entry formats (provenance markers, date+source headers, task syntax) match myna-steering-conventions
- Shared destination formatting consistent with other skills writing to the same files

**Dimension 6 — Safety.** Check ALL of these:
- Draft-never-send: no code path leads to sending/posting/delivering anything
- Vault-only writes: nothing written outside the configured `myna/` subfolder
- No automatic skill chaining
- Calendar three-layer protection present if skill touches calendar writes
- External content (email bodies, Slack messages) wrapped in safety delimiters before reasoning
- Confirmation required for bulk writes (5+ files)
- No overly permissive `allowed-tools` declarations

**Dimension 7 — Edge cases.** Are these handled?
- First run (empty vault, no entity files, no daily note)
- Missing referenced files
- Ambiguous entity resolution (two people with same name)
- Empty MCP results
- Bulk operations (5+ items)
- Re-run idempotency
- Missing config or disabled feature toggle

**Dimension 8 — Output usefulness.** Against myna-steering-output:
- Output is specific and actionable: counts, file links, concrete next steps
- Not generic ("processing complete") or verbose
- No AI tells, no filler phrases
- User can figure out how to invoke the skill from description + argument-hint alone

**Dimension 9 — Steering duplication.** Compare against all six steering skills.
- Flag any rules that duplicate what a steering skill already covers (cite which steering skill by name)
- These duplicates should be removed from the feature skill

**Dimension 10 — Conciseness.** Would Claude produce the same output without a given line?
- Flag sections that are bloated: worked examples longer than the procedure they illustrate, edge cases Claude would handle by default, repeated explanations, "what this skill does NOT do" that restates the description
- Flag skills over 500 lines

**STEP 4: Return your findings** in this exact format:

```
### {skill-directory-name}/SKILL.md

Lines: {count}

**Findings:**
[C01] Critical — {one-line description}
      Location: line {N}
      Details: {specific text or behavior; cite which steering skill / foundations template / feature spec}

[I01] Important — {one-line description}
      Location: line {N}
      Details: {specific text or behavior}

[M01] Minor — {one-line description}
      Location: line {N}
      Details: {specific text or behavior}

[N01] Nitpick — {one-line description}
      Location: line {N}
      Details: {specific text or behavior}

**Strengths:** {1-2 bullets — only if genuine}
**No issues found on dimensions:** {list any clean dimensions}
```

Severity guide:
- **Critical** — breaks functionality, safety violation, skill undiscoverable, missing required frontmatter
- **Important** — Claude would struggle or produce wrong output, sub-feature missing, significant bloat, ambiguous instructions
- **Minor** — polish issue, Golden Rule candidate, slight inconsistency
- **Nitpick** — cosmetic, optional improvement only

Rules:
- Quote specific text and cite line numbers
- Ground every finding in a reference (steering skill name, foundations template, feature spec, Claude Code frontmatter field)
- No vague criticism. "This is wordy" is not a finding. "Lines 45–62 repeat the draft-never-send rule already covered by myna-steering-safety" is.
- Don't manufacture findings. If the skill is clean on a dimension, say so.

---

#### After all subagents return

Consolidate all findings. Assign cross-skill IDs: `[C01]`, `[C02]`, etc. per severity, globally across all skills.

Write the review report to `docs/reviews/review-{NNN}.md`:

```markdown
# Myna Improve — Review {NNN}

**Date:** {YYYY-MM-DD}
**Scope:** {what was reviewed — list skill names}
**Cycle:** {relative cycle number within this run} of {max cycles}

## Summary

| Skill | Lines | Critical | Important | Minor | Nitpick |
|---|---|---|---|---|---|
| {name} | {N} | {C} | {I} | {M} | {N} |
| **Total** | — | {C} | {I} | {M} | {N} |

## Findings by skill

{each subagent's report, verbatim, consolidated and cross-referenced}

## Cross-skill observations

{Any patterns spanning multiple skills — shared-destination drift, common missing edge case, etc.}
```

**Early exit check:** If total Critical + Important = 0, stop here. Skip Fix and Verify. Record "Early exit: no blocking issues" in the final summary.

---

### Fix Phase — Implement All Recommended Fixes

Read `docs/reviews/review-{NNN}.md` in full before making any edits.

**Priority order:** Critical → Important → Minor → Nitpick. Implement all severities — this is auto mode.

For each finding:
1. Go to the file and line. Verify the issue is still present (a prior fix may have resolved it).
2. Implement the fix. Edit the file using the Edit tool.
3. Re-read the changed section to confirm it reads naturally and is valid.
4. If you touched frontmatter, verify the YAML is still valid after the edit.
5. Record what you did.

**Do NOT fix without flagging:**
- Issues that would add features not listed in architecture.md's "Features covered:" for that skill
- Deferred features from decisions.md
- Issues where the right fix is genuinely unclear — flag it in the fix report instead

**After all individual fixes, cross-skill consistency check:**
Read every skill that was modified. Check that skills writing to the same vault destinations produce identical formatting. Check that skills referencing the same config fields use the same field names. Fix any inconsistencies introduced during this fix pass.

Write the fix report to `docs/reviews/fix-{NNN}.md`:

```markdown
# Myna Improve — Fix {NNN}

**Date:** {YYYY-MM-DD}
**Scope:** {skills touched}

## Fixes applied

| Issue ID | Skill | Severity | Summary | Action |
|---|---|---|---|---|
| [C01] | {skill} | Critical | {one-liner} | Fixed / Flagged |

## Flagged (not fixed)

For each flagged issue:
- **[ID] {skill}:** {reason not fixed}

## Cross-skill consistency changes

{Any changes made during the consistency pass, with skill names and what changed}
```

---

### Verify Phase — Confirm Fixes Resolved Issues

Read `docs/reviews/fix-{NNN}.md`. For every item marked "Fixed":

1. Go to the file at the relevant location.
2. Confirm the original issue is gone.
3. Confirm the fix doesn't introduce a new problem.
4. Check that the fix is consistent with the surrounding context.

**Regression check:** For every skill that was modified in the Fix phase:
- Confirm frontmatter is still valid YAML
- Confirm skill structure is intact (at least 3 H2 sections, 50+ lines)
- Confirm no safety rules were accidentally removed or weakened
- Confirm vault path patterns still match foundations.md

Write the verify report to `docs/reviews/verify-{NNN}.md`:

```markdown
# Myna Improve — Verify {NNN}

**Date:** {YYYY-MM-DD}

## Verification results

| Issue ID | Skill | Status | Notes |
|---|---|---|---|
| [C01] | {skill} | Resolved / Partially resolved / Regressed | {details if not fully resolved} |

## Regression check

| Skill | Frontmatter | Sections | Safety | Paths | Status |
|---|---|---|---|---|---|
| {name} | OK / FAIL | OK / FAIL | OK / FAIL | OK / FAIL | Clean / Issues |

## Remaining issues

{Any issues from review-NNN that are still present after the fix pass, with explanation}
```

---

## Oscillation Guard

**Check before every cycle after the first.**

After the Verify phase of cycle N, count blocking issues remaining: Critical + Important from `verify-{NNN}.md`.

If cycle N has >= blocking issues remaining as cycle N-1:
- **Stop immediately.** Do not start another cycle.
- Record reason: "Oscillation detected — cycle {N} found {X} blocking issues, same or worse than cycle {N-1} ({Y}). Pipeline halted to prevent thrashing."
- Proceed directly to final commit and summary.

The oscillation guard exists because repeated fix passes without reduction in blocking issues means either the fixes are reverting themselves, the issues require human judgment, or the review and fix passes are contradicting each other. More cycles won't help — stop.

---

## Early Exit Conditions

Stop the Review/Fix/Verify loop early (before reaching `--cycles N`) if:

1. **After Review:** Total Critical + Important = 0. No fix pass needed. Record "Early exit after review {NNN}: 0 blocking issues found."
2. **After Verify:** Total remaining Critical + Important = 0. Record "Early exit after verify {NNN}: all blocking issues resolved."
3. **Oscillation guard triggers.** See above.

In all early exit cases: proceed immediately to the final commit and summary.

---

## Pacing Rules

These are non-negotiable. Quality over speed.

- **Never skim a skill.** Read every line before evaluating. A skill review that misses a safety hole in line 300 is worse than no review.
- **Never skip a dimension.** Even if the first five dimensions are clean, check the remaining four. Write "no issues" for clean dimensions — don't leave them blank.
- **Never rush later cycles.** Cycle 3 gets exactly the same attention as cycle 1. Context filling up is not a reason to cut corners.
- **Never combine Fix and Verify.** Fix, then stop. Then re-read the actual files for Verify. Do not verify from memory.
- **Never assume a fix is complete** without reading the changed section. An edit that fixes one sentence while breaking the next is not a fix.

---

## Final Commit

After all phases are complete (lint clean + all cycles done + early exit or oscillation guard):

1. Stage all modified skill files, the main agent if changed, and all report files created during this run (`review-{NNN}.md`, `fix-{NNN}.md`, `verify-{NNN}.md` for each cycle).
2. One commit for the entire run. Commit message format:

```
fix(agents): improve cycle {NNN-to-NNN} — {N} issues fixed, {N} remaining

Phase 0: lint {clean from start | fixed N errors in K re-runs}
Cycles: {N} of {max} — stop reason: {early exit / max cycles / oscillation guard}
Critical: {found} found, {fixed} fixed, {remaining} remaining
Important: {found} found, {fixed} fixed, {remaining} remaining
Minor: {found} found, {fixed} fixed
Nitpick: {found} found, {fixed} fixed
```

Do not add Co-Authored-By lines.

---

## Final Summary

Print to the user:

```
Myna Improve — complete

Phase 0 (Lint)
  Result: {PASS from start | PASS after N fixes in K re-runs}
  Errors fixed: {N}
  Warnings reviewed: {N} ({N} fixed, {N} noted)

Cycles run: {N} of {max}
Stop reason: {early exit after review NNN | early exit after verify NNN | max cycles reached | oscillation guard triggered at cycle N}

Issues found / fixed / remaining:
  Critical:  {found} / {fixed} / {remaining}
  Important: {found} / {fixed} / {remaining}
  Minor:     {found} / {fixed} / {remaining}
  Nitpick:   {found} / {fixed} / {remaining}

Skills modified: {N}
  {skill-name}: {before} → {after} lines
  ...

Reports:
  {list all docs/reviews/*.md files written during this run}

Flagged for human review:
  {any issues that were not fixed and why — or "none"}
```

---

## Rules

- Do not touch steering skills unless `--include-steering` was passed. Flag steering issues in the report instead.
- If a feature skill rule duplicates a steering skill, remove it from the feature skill.
- Do not add features beyond v1 scope. Check decisions.md.
- Do not invent new conventions. Match existing patterns in foundations.md and the steering skills.
- `docs/reviews/` — create it if it doesn't exist.
- Create `docs/reviews/` with `mkdir -p` if needed before writing the first report.
- The lint script runs from the repo root. Always run it as `bash scripts/lint-agents.sh` from the workspace root.
