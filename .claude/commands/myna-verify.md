Close the review-fix-verify loop. Reads a fix report and corresponding review report, then confirms each fix is real (not superficial), checks that the actual file now satisfies the original concern, evaluates pushback reasoning for soundness, and does a regression scan across all modified files. Saves results to `docs/reviews/verify-{NNN}.md`.

## Arguments

$ARGUMENTS

Parse for:
- A bare cycle number (`001`, `3`, `42`) → verify that specific cycle
- No argument → verify the latest cycle (highest numbered `fix-{NNN}.md` in `docs/reviews/`)
- Anything else → error with: "Usage: /myna-verify [cycle-number]"

## Setup

**Step 1: Resolve the cycle.**

Find the fix report to verify:
- With a cycle number argument: `docs/reviews/fix-{NNN}.md` (zero-pad to 3 digits)
- Without argument: glob `docs/reviews/fix-*.md`, sort, take the highest numbered file

If the fix report does not exist, stop: "No fix report found for cycle {NNN}. Run /myna-fix first."

**Step 2: Locate the corresponding review report.**

The fix report's header contains `**Review:** docs/reviews/review-{NNN}.md`. Read that file. If missing, stop: "Review report docs/reviews/review-{NNN}.md not found — cannot verify without original issues."

**Step 3: Read the fix report in full.**

Extract:
- Every issue entry (all severity levels: Critical, Important, Minor, Nitpick)
- For each issue: its ID (e.g., `[I01]`), the action taken (`Implemented Option N` or `No change` / pushback), and the files modified
- The complete list of all files modified across all fixes

**Step 4: Determine if a prior verify report already exists.**

Glob `docs/reviews/verify-{NNN}.md`. If it exists, note this is a re-verify run and state which issues were previously Resolved vs Not Resolved.

---

## Verification — Implemented Fixes

For each issue marked "Implemented" in the fix report:

**4a. Read the actual file NOW.** Do not rely on the fix report's description of what changed. Use the Read tool on the actual file. Find the relevant lines. Quote the text you are reading.

**4b. Judge against the original concern.** Re-read the issue description in the review report. Ask: does the current file state address the concern? Apply this standard:

- **Resolved** — the concern is gone. The fix either eliminates the problem, adds the missing content, or corrects the incorrect content in a way a reasonable reviewer would accept. State what you read that confirms this.
- **Not Resolved** — one of these is true:
  - The change is cosmetic but the underlying problem remains (e.g., rephrased without fixing the logic gap)
  - The change introduced a different form of the same problem
  - The fix is in the wrong location (different file/section than the issue cited)
  - The fix is missing entirely (fix report claims a change that isn't in the file)

**4c. For each verdict, write:**
```
### [{ID}] {one-line issue summary}
**Fix action:** {what the fix report claimed was done}
**Verdict:** Resolved | Not Resolved
**Evidence:** {quote the specific text you read that proves Resolved, or explain specifically why Not Resolved — cite file, line range, and what you expected vs what you found}
```

---

## Verification — Pushbacks (No Change)

For each issue marked "No change" or with a pushback in the fix report:

**5a. Re-read the pushback reasoning** in the fix report.

**5b. Re-read the original concern** in the review report.

**5c. Judge whether the pushback reasoning is sound:**

- **Accepted** — the pushback is logically sound. The reasoning explains why the original concern doesn't apply, is out of scope, is a false positive, or is addressed by an alternative already in place. A reasonable reviewer would agree.
- **Rejected** — the pushback is unsound. The reasoning misunderstands the concern, relies on factually incorrect claims about the files, or dismisses a real gap without addressing it. State what the correct reasoning would be.

**5d. For each verdict, write:**
```
### [{ID}] {one-line issue summary}
**Pushback:** {what the fix report argued}
**Verdict:** Accepted | Rejected
**Reasoning:** {why the pushback is sound or unsound — cite specific facts}
```

If there are no pushbacks, skip this section.

---

## Regression Check

After verifying individual fixes, read all files that the fix report lists as modified. Do this even for issues marked Resolved — regressions are often introduced by fixes to other issues in the same files.

For each modified file, do a full re-read and check:

**6a. Internal consistency.** Does each change fit naturally with the surrounding content? Are there contradictions within the file introduced by the edits?

**6b. Cross-skill consistency on shared vault destinations.** For each shared write destination touched by any fix, check that all skills writing to that destination still agree on format. Shared destinations to check:

- **Timeline entries** (`Projects/{name}.md ## Timeline`) — format: `- [{date} | {source}] {content} [{provenance}] ({source-detail})`
- **Observation entries** (`People/{name}.md ## Observations`) — format: `- [{date} | {source}] **{type}:** {observation} [{provenance}] ({source-detail})`
- **Recognition entries** (`People/{name}.md ## Recognition`) — format: `- [{date} | {source}] {what they did} — {context} [{provenance}] ({source-detail})`
- **Contribution entries** (`Journal/contributions-*.md`) — format from conventions skill
- **Tasks (Open Tasks sections)** — Obsidian Tasks plugin format with `[type:: ...]` inline properties
- **Review queue entries** (`ReviewQueue/review-work.md`, `review-people.md`, `review-self.md`) — format per conventions skill
- **Draft files** (`Drafts/[{Type}] {topic}.md`) — frontmatter fields: type, audience_tier, related_project, related_person, created; tags: `#draft #{type}`; footer
- **Daily/Weekly notes** (`Journal/DailyNote-*.md`, `Journal/WeeklyNote-*.md`) — section names and format
- **Meeting files** (`Meetings/1-1s/`, `Meetings/Recurring/`, `Meetings/Adhoc/`) — session and prep item format

If a fix changed how a skill writes to one of these destinations, check every other skill that also writes there. If they now disagree on format, that is a regression.

**6c. Safety check.** For every modified file, verify:
- No new code path leads to sending, posting, or delivering anything outside the vault (look for `send`, `post`, `deliver`, `publish`)
- No new write paths outside the vault's `myna/` subfolder
- Calendar three-layer protection is intact if any calendar-related file was modified (Layer 1: instruction says personal events only; Layer 2: title must start with configured prefix before tool call; Layer 3: explicit confirmation required)
- Bulk write confirmation threshold (5 or more files) is not softened
- No automatic skill chaining introduced (one skill invoking another)

**6d. Toggle and config references.** If any fix modified toggle-gating logic, check that the same toggle is gated consistently across all skills that reference that feature. Known multi-skill toggles: `features.feedback_gap_detection` (brief, prep-meeting, wrap-up), `features.people_management` (brief multiple sub-features), `features.team_health` (brief Team Health Overview).

**6e. Provenance and source values.** If any fix added or referenced a source value (email, slack, meeting, capture, user, wrap-up), verify it is in the canonical source list in the conventions steering skill. If a fix added a new source value, verify conventions.md was also updated.

**6f. Self-containment.** If any fix modified a skill file, verify the file still has no references to:
- Design docs: `foundations.md`, `architecture.md`, `decisions.md`
- Repo paths: anything starting with `docs/`
- Decision IDs: D followed by three digits (e.g., D003, D046)

Write a summary of the regression check results:
```
## Regression Check

1. **Modified files re-read:** {list files} — {findings or "no contradictions introduced"}
2. **Cross-skill consistency:** {for each shared destination touched — findings or "no drift"}
3. **Safety check:** {findings or "no new send/post/deliver paths, no writes outside vault"}
4. **Toggle gating:** {findings or "N/A — no toggle logic modified"}
5. **Source values:** {findings or "N/A — no source values added or changed"}
6. **Self-containment:** {findings or "no design doc references introduced"}
```

For each regression found, assign it an ID: `[R01]`, `[R02]`, etc. Describe the regression at the same level of detail as an original review issue (what file, what the problem is, what the correct state should be).

---

## Lint Check

Run `bash scripts/lint-agents.sh` and report the result. The expected baseline for cycles 001 and onward is 0 errors, 8 warnings (the 8 warnings are known false positives: "Review and send" user-action TODOs in draft-replies and draft, example content in prep-meeting, process-meeting, and conventions). If the error count has increased, report which new errors appeared. If warning count has increased, report new warnings.

If the lint script does not exist or fails to run, note that and skip.

---

## Save the Report

Write the verify report to `docs/reviews/verify-{NNN}.md` using this exact structure:

```markdown
# Myna Verify Report — Cycle {NNN}

**Date:** {YYYY-MM-DD}
**Review:** `docs/reviews/review-{NNN}.md`
**Fix report:** `docs/reviews/fix-{NNN}.md`

## Issue Verification

{per-issue sections — Implemented fixes first, then Pushbacks}

## Regression Check

{regression check summary — if regressions found, full regression descriptions follow}

## Lint

{lint result}

## Verdict

**{CLEAN | NOT CLEAN}** — {one-sentence summary}

| Metric | Count |
|--------|-------|
| Issues verified | {n} |
| Resolved | {n} |
| Not resolved | {n} |
| Pushbacks accepted | {n} |
| Pushbacks rejected | {n} |
| Regressions found | {n} |
```

**Verdict rules:**
- **CLEAN** — every implemented fix is Resolved, every pushback is Accepted (or there are no pushbacks), and no regressions found. Recommend: "stop iterating" or "ready for next cycle."
- **NOT CLEAN** — one or more of: a fix is Not Resolved, a pushback is Rejected, or a regression was found. List exactly what's still wrong and what action is needed.

---

## Print to User

After saving the report, print:

```
Myna Verify — Cycle {NNN}
Report: docs/reviews/verify-{NNN}.md

Verdict: {CLEAN | NOT CLEAN}

Issues: {resolved}/{total} resolved
Pushbacks: {accepted}/{total} accepted
Regressions: {n}

{If NOT CLEAN: "Unresolved:" followed by bullet list of each Not Resolved / Rejected Pushback / Regression ID with one-line description}
{If CLEAN: "All fixes confirmed. No regressions."}
```

---

## Rules

- Read the actual files. Do not take the fix report's word for what changed — verify by reading the source.
- Quote specific text as evidence. "I read line N which says X" is evidence. "The fix was applied" is not.
- A fix that rephrases the problem without solving it is Not Resolved.
- A fix applied to the wrong file or wrong section is Not Resolved.
- A pushback that says "this is handled elsewhere" must cite where. If the citation is wrong or missing, reject it.
- Regressions in files that were not the subject of any issue still count. Read every modified file fully.
- Do not invent issues not visible in the current file state. If you can't find evidence of a problem, don't report one.
- The lint baseline is 0 errors, 8 known-false-positive warnings. Any new errors are regressions. New warnings need review.
- Do not commit. Only the user commits.
