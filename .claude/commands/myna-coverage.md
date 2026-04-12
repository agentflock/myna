Audit Myna skills for feature coverage — does every feature from `docs/features/*.md` have executable instructions in its owning skill? Not "mentioned" — actually covered with steps Claude would follow. Saves a coverage report to `docs/reviews/coverage-{NNN}.md`.

## Arguments

$ARGUMENTS

Parse for:
- **Scope:** file paths, glob patterns, `--uncommitted`, or default to all feature skills + steering skills + main agent + config examples
- No arguments → default scope: `agents/skills/myna-*/SKILL.md` + `agents/skills/myna-steering-*/SKILL.md` + `agents/main.md` + `agents/config-examples/*.yaml.example`
- Specific paths or globs → check only skills matching those paths. Always read ALL feature spec files regardless of scope — coverage is about what the spec says vs what the skill does.
- `--uncommitted` → only skills with uncommitted git changes under `agents/`
- Anything else → error out with a note on valid usage

## Setup

Read ALL of these before auditing:

1. `docs/architecture.md` — sections 1–2. Extract the "Features covered:" line for every skill. This is the authoritative feature-to-skill mapping. Build the complete map: `skill name → [list of features it owns]`.

2. All 10 feature spec files — read every sub-feature, decision criterion, and edge case:
   - `docs/features/daily-workflow.md`
   - `docs/features/email-and-messaging.md`
   - `docs/features/meetings-and-calendar.md`
   - `docs/features/people-management.md`
   - `docs/features/projects-and-tasks.md`
   - `docs/features/self-tracking.md`
   - `docs/features/writing-and-drafts.md`
   - `docs/features/setup-and-config.md`
   - `docs/features/cross-domain.md`
   - `docs/features/non-functional.md`

3. `docs/design/foundations.md` — vault structure, canonical templates, shared destination formats. Used to verify that "executable steps" reference the right paths and data structures.

4. Every skill file in scope — full content.

## What counts as a sub-feature

A sub-feature is any named, user-visible behavior described in `docs/features/*.md` under a `###` heading. If a `###` section has multiple distinct behaviors (e.g., step 1 / step 2 / step 3, or mode A / mode B / mode C), each distinct behavior is a separate sub-feature to check.

Non-functional requirements (`docs/features/non-functional.md`) are cross-cutting rules enforced by steering skills — do not audit individual feature skills against them. The steering skills do not own features from the feature spec files; they are cross-cutting. Audit only what `architecture.md` assigns to each skill.

## What "executable" means

A sub-feature is **executable** if the skill body contains specific steps Claude can follow to produce the correct output:
- Specific file paths to read (e.g., `_system/config/workspace.yaml`, `People/{slug}.md`)
- Specific data to extract or decisions to make (e.g., "grep for `- \[ \]` lines with `[type:: delegation]`")
- Specific files or sections to write to (e.g., "append to `ReviewQueue/review-work.md`")
- Concrete output format or content

A sub-feature is **not executable** if it is only:
- Named in a "features covered" comment without procedural steps
- Described in a worked example but missing the actual procedure
- Mentioned as a trigger phrase without any corresponding handling logic
- Covered by a vague verb ("handle this case", "process appropriately", "detect and surface")

## Coverage grades

For each sub-feature assigned to an in-scope skill:

- **FULL** — the skill has executable steps (read → decide → write) covering every meaningful behavior described in the spec. Minor omissions that Claude would handle by default (obvious error messages, standard graceful degradation) do not drop a grade.
- **PARTIAL** — the skill covers the core behavior but is missing one or more specific behaviors, edge cases, or decision criteria that the spec explicitly calls out and that require explicit instruction.
- **NONE** — the sub-feature appears in the architecture's "Features covered:" list for this skill but the skill body has no executable steps for it. Being named in the frontmatter description or in a comment does not count.

When grading PARTIAL, list the specific gaps. Quote from both the spec (what it says) and the skill (what exists, or what's absent).

## Audit methodology

**For 1–4 skills in scope:** audit directly in this context, skill by skill.

**For 5+ skills in scope:** spawn one subagent per skill — all in parallel — using the subagent task prompt below. Wait for all subagents, then compile the results. Each subagent handles all features assigned to its skill.

### Subagent task prompt

Pass each subagent this exact text, substituting values:

---

You are auditing ONE Myna skill for feature coverage.

**Skill to audit:** {SKILL_PATH}

**Features assigned to this skill (from architecture.md):** {FEATURES_COVERED_LIST}

Follow these steps IN ORDER.

**STEP 1: Read context.**

Read these files — do not skip any:
- `docs/architecture.md` — confirm the "Features covered:" line for this skill
- `docs/design/foundations.md` — vault structure and canonical file paths
- The feature spec file(s) that contain this skill's assigned features. Assigned features may span multiple spec files — check architecture.md to see which domains apply.
- The skill file in full: {SKILL_PATH}

**STEP 2: Build the sub-feature checklist.**

For each feature name in the "Features covered:" list, go to the relevant `docs/features/*.md` file and extract every distinct behavior under that `###` heading. Write out the checklist before grading anything. If a feature has 4 distinct behaviors, list all 4. This is your audit target.

**STEP 3: Grade each sub-feature.**

For each item on your checklist:
1. Search the skill body for steps that cover that behavior.
2. Assign a grade: FULL, PARTIAL, or NONE (definitions below).
3. For PARTIAL: quote the spec text describing the missing behavior and note what the skill currently has (or lacks).
4. For NONE: confirm the feature is in the architecture's "Features covered:" line — if it isn't, note the discrepancy.

**Grades:**
- **FULL** — executable read → decide → write steps for every meaningful behavior in the spec. Obvious defaults Claude handles without instruction are fine.
- **PARTIAL** — core behavior is covered but specific behaviors, modes, edge cases, or decision criteria that the spec explicitly calls out are missing executable steps.
- **NONE** — no executable steps for this sub-feature anywhere in the skill body.

**STEP 4: Return your findings** in this exact format:

```
### {skill-name} — Feature Coverage

**Features checked:** {list of feature names from architecture.md}

**Sub-feature results:**

| Sub-feature | Grade | Notes |
|-------------|-------|-------|
| {feature name} — {sub-feature or behavior} | FULL / PARTIAL / NONE | {what's missing for PARTIAL/NONE; "ok" for FULL} |

**Gap details** (PARTIAL and NONE only):

#### {sub-feature name} — {PARTIAL or NONE}

Spec says:
> {quote from docs/features/*.md — the specific behavior described}

Skill has:
{either quote the relevant section if PARTIAL, or "Nothing — no executable steps for this sub-feature." if NONE}

Missing:
{specific steps, decision criteria, or behaviors not covered}

Suggested fix:
{one-sentence description of what to add to the skill body}
```

---

## After all audits complete

1. **Determine cycle number.** Read `docs/reviews/`. Find the highest existing `coverage-NNN.md`. Next number is that + 1. If none exist, use `001`. Format: three digits zero-padded.

2. **Write the report** to `docs/reviews/coverage-{NNN}.md`.

   Report format:

   ```markdown
   # Myna Feature Coverage — Cycle {NNN}

   **Date:** {YYYY-MM-DD}
   **Scope:** {what was checked — e.g., "all 24 feature skills" or specific paths}

   ## Summary

   - **Features checked:** {total sub-features audited}
   - **FULL:** {count} ({percentage}%)
   - **PARTIAL:** {count} ({percentage}%)
   - **NONE:** {count} ({percentage}%)
   - **Overall coverage:** {percentage of sub-features graded FULL}%

   ## Coverage Matrix

   | Feature | Owning Skill | Grade | Notes |
   |---------|-------------|-------|-------|
   | {feature name} — {sub-feature} | {skill-name} | FULL / PARTIAL / NONE | {brief note or "ok"} |

   Sort: NONE first, then PARTIAL, then FULL. Within each grade, sort by owning skill name.

   ## Gap Details

   For every PARTIAL and NONE entry, include the full gap detail block from the subagent output.

   ### [C{NN}] {skill-name} / {sub-feature name} — NONE
   ### [I{NN}] {skill-name} / {sub-feature name} — PARTIAL

   Use issue IDs: NONE gaps → `[C{NN}]` (Critical — assigned but absent). PARTIAL gaps → `[I{NN}]` (Important — degraded coverage). Number sequentially across the full report.

   Each entry:

   **Spec says:**
   > {quote}

   **Skill has:**
   {current state or "Nothing."}

   **Missing:**
   {specific behaviors not covered}

   **Suggested fix:**
   {one sentence}

   ## Architecture Discrepancies

   Any cases where a feature appears in the spec but is NOT in any skill's "Features covered:" line — or appears in "Features covered:" but not in the spec. List them here for human review. These are documentation gaps, not skill gaps.
   ```

3. **Print summary** to the user:

   ```
   Myna Feature Coverage — Cycle {NNN} complete
   Report: docs/reviews/coverage-{NNN}.md

   {total} sub-features checked across {n} skills
   FULL: {count} ({pct}%) | PARTIAL: {count} ({pct}%) | NONE: {count} ({pct}%)
   Overall coverage: {pct}%

   Critical gaps (NONE): {count}
   Partial gaps (PARTIAL): {count}
   ```

## Rules

- Scope controls which skills are audited. Feature spec files are always read in full regardless of scope — you need the complete spec to grade any skill.
- Non-functional requirements in `docs/features/non-functional.md` are enforced by steering skills, not feature skills. Do not audit feature skills against them.
- "Mentioned" is not coverage. A feature name in a description, a comment, or a worked-example title does not count as executable steps.
- Do not propose fixes outside v1 scope — check `docs/decisions.md` for deferred features. If a NONE gap is explicitly deferred, note it as deferred rather than a gap.
- Do not manufacture gaps. If a skill covers a behavior in a way that differs from the spec but would produce correct output, grade it FULL and note the implementation difference.
- Steering duplicates are not gaps — if a behavior is handled by a steering skill and the feature skill correctly relies on it, grade FULL. Do not flag steering-covered behaviors as gaps in the feature skill.
- If scope is empty after resolution, error out with a message explaining valid usage.
