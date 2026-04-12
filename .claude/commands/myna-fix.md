Read the latest review report from `docs/reviews/` and implement fixes as a thoughtful senior developer — understand context before editing, push back when a fix would make things worse.

## Arguments

$ARGUMENTS

Parse for one of three modes:

- **No arguments (default mode):** Process all issues in the review. For each issue, either implement the fix OR push back with specific documented reasoning. Pushback must cite why the proposed fix would make things worse — "it's fine as-is" is not acceptable pushback.
- **`--auto`:** Implement all recommendations without pushback. Assume every recommendation in the review is correct and implement the highest-ranked option for each.
- **Issue IDs (e.g., `C01 I03 M02`):** Selective mode — only fix the listed issues. Skip all others without comment in the report (just note "Skipped — not in scope for this run").

If the argument is unrecognized (not `--auto`, not valid issue IDs, not empty), error out: "Unrecognized argument: {arg}. Valid usage: /myna-fix, /myna-fix --auto, or /myna-fix C01 I03 M02"

---

## Step 1: Find the Latest Review Report

List files matching `docs/reviews/review-*.md`. Pick the one with the highest cycle number (e.g., `review-004.md` over `review-003.md`). Read it in full.

Note the cycle number — all output goes to `docs/reviews/fix-{NNN}.md` using the same number.

If no review report exists, stop: "No review report found in docs/reviews/. Run /myna-review first."

If a `docs/reviews/fix-{NNN}.md` already exists for this cycle, stop: "Fix report for cycle {NNN} already exists at docs/reviews/fix-{NNN}.md. If you want to re-run, delete or rename it first."

---

## Step 2: Read Project Context

Read these before touching any skill file. This is non-negotiable — context determines whether a fix is correct.

1. `agents/skills/myna-steering-safety/SKILL.md` — draft-never-send, vault-only writes, confirmation policy, skill isolation
2. `agents/skills/myna-steering-conventions/SKILL.md` — entry formats, provenance markers, Obsidian conventions
3. `agents/skills/myna-steering-vault-ops/SKILL.md` — file I/O tool mapping, path conventions
4. `agents/skills/myna-steering-output/SKILL.md` — output format rules
5. `agents/skills/myna-steering-memory/SKILL.md` — emergent memory rules
6. `agents/skills/myna-steering-system/SKILL.md` — config schema, session start

---

## Step 3: Read All Referenced Files

From the review report, collect every file mentioned in the Issues section. Read each one in full before beginning any edits. You need the full current state of each file to implement fixes correctly — partial reads lead to broken edits.

---

## Step 4: Process Issues

Work through issues in severity order: **Critical → Important → Minor → Nitpick**.

For each issue:

### Default mode (no arguments)

Evaluate the issue and the proposed options against the project context you've read. Then choose one of:

**A. Implement a fix.** Pick the option from the review (or a better alternative if you see one). Implement it using Edit. After each edit, re-read the changed section to verify it reads naturally and didn't break surrounding text.

**B. Push back.** Document your reasoning in the fix report. Pushback must be specific:
- Cite what makes the proposed fix worse than the status quo
- Reference a concrete principle (a steering skill rule, an architecture constraint, a pattern in existing files)
- "No change — [specific reasoning]" is the format

Do not push back just because a fix is hard or requires touching multiple files. Push back only when the fix would genuinely make things worse or contradict a settled principle.

### `--auto` mode

Implement every issue. Use the recommended option from the review, or Option 1 if no recommendation is given. No pushback.

### Selective mode (issue IDs as arguments)

Only process listed issues using default mode evaluation. For all other issues, record "Skipped — not in scope for this run" in the report.

---

## Step 5: Self-Verification

After all edits are complete, re-read every modified file in full. Check:

**Internal consistency (per file):**
- Does the file still read coherently top to bottom?
- Do section cross-references still resolve (e.g., "see Rules section" — does the Rules section still have the thing being referenced)?
- Is the YAML frontmatter still valid if you touched it?

**Cross-file consistency:**
- If you changed an entry format, does it match what other skills writing to the same vault destinations produce?
- If you changed a config field reference, is the field spelled the same way in other skills that use it?
- If you added or removed a rule, does it conflict with or duplicate a steering skill?

**Safety check:**
- No fix introduced a send/post/deliver path
- No fix writes outside the `myna/` subfolder
- No fix introduces automatic skill chaining
- Calendar three-layer protection is unchanged if you touched calendar-related files

**Lint:** Run `bash scripts/lint-agents.sh`. Fix any errors it finds before writing the report. Record the result (errors, warnings, pass/fail) in the Self-Verification section of the report.

---

## Step 6: Write the Fix Report

Save to `docs/reviews/fix-{NNN}.md` where `{NNN}` matches the review cycle.

```
# Myna Fix Report — Cycle {NNN}

**Date:** {YYYY-MM-DD}
**Mode:** {Default | Auto | Selective ({issue IDs})}
**Review:** `docs/reviews/review-{NNN}.md`

## Actions

### [{ID}] {issue title from review}

**Action:** Implemented Option {N} — {one-line summary of what was done}
**Changes:**
- `{file path}` line {N}: {what changed — be specific. Quote old and new text for single-line changes.}
- ...
**Files modified:** {comma-separated list}

--- (repeat for each issue processed)

### [{ID}] {issue title from review}

**Action:** No change — {specific reasoning. Cite the principle, steering rule, or concrete problem with the proposed fix.}

--- (repeat for each pushback)

### [{ID}] {issue title from review}

**Action:** Skipped — not in scope for this run.

--- (only in selective mode, for issues not listed in arguments)

## Self-Verification

**Internal consistency:** {per-file notes, or "All modified files read coherently."}

**Cross-file consistency:** {notes on shared destinations, format alignment, or "No cross-file consistency issues."}

**Safety check:** {notes, or "No fix introduced a send/post/deliver path. No vault-external writes. No skill chaining. Calendar protection unchanged."}

**Lint:** {bash scripts/lint-agents.sh result — errors, warnings, pass/fail}

## Summary

| Metric | Count |
|--------|-------|
| Issues fixed | {n} |
| Issues pushed back | {n} |
| Issues skipped | {n} |
| Files modified | {n} |

**Files modified:**
- `{path}`
- ...
```

---

## Step 7: Commit

Stage the fix report and every modified agent file. One atomic commit:

```
fix(agents): address review cycle {NNN} — {n} issues fixed
```

If issues were pushed back, append to the subject: `{n} fixed, {n} pushed back`.

Do not add Co-Authored-By lines. Do not add the fix report path to the commit message body — the subject is enough.

---

## Rules

- Read context before editing. Never fix an issue based on the review alone — always verify against the actual file and steering skills first.
- Match existing patterns. If similar text exists elsewhere in the same file or in sibling skills, your fix should match that pattern exactly.
- Golden Rule: would Claude behave the same without this line? If yes, don't add it.
- Do not add features beyond what the review identified. Opportunistic improvements belong in `/myna-review`, not here.
- Do not touch files not mentioned in the review unless cross-file consistency requires it and you document the reason.
- Severity order matters. Finish all Critical issues before starting Important ones. Don't skip ahead.
- If a fix requires a decision the review didn't make (e.g., two options with real trade-offs and no recommendation), push back and note what decision is needed.
