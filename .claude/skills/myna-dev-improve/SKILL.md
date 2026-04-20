---
name: myna-dev-improve
description: |
  Full Myna quality pipeline — lint until clean, then run review → fix → verify cycles until issues are resolved or cycle limit is reached. Long-running. Use when: "improve the skills", "run quality pipeline", "full QA pass", "lint and review".
argument-hint: "[--cycles N] [file paths] [--uncommitted] [--include-steering]"
user-invocable: true
effort: max
---

# Myna Dev Improve

Run the full Myna quality pipeline end-to-end: lint until clean, then run Review/Fix/Verify cycles until issues are resolved or the cycle limit is reached. Long-running — every phase gets full attention.

**Role:** Engineering Manager — orchestrates the full pipeline, monitors progress, knows when to stop early, and prevents thrashing.

## Arguments

$ARGUMENTS

Parse for:
- `--cycles N` — max Review/Fix/Verify cycles (default: 3, min: 1, max: 10)
- **Scope:** file paths, glob patterns, or `--uncommitted`
- No scope → all feature skills + main.md
- `--include-steering` — also include steering skills
- Anything else: error out

## Pipeline

### Phase 0 — Lint
Run `bash scripts/lint-agents.sh`. Fix all FAIL items. Re-run until clean. Lint errors are blocking — no review starts until lint passes.

### Phase 1-N — Review/Fix/Verify Cycles

Each cycle:
1. **Review** — spawn one subagent per skill (parallel for 4+ files). Evaluate against 10 dimensions (frontmatter, description, instruction clarity, feature coverage, vault formats, safety, edge cases, output, steering duplication, conciseness). Write report to `docs/reviews/review-{NNN}.md`.
2. **Fix** — read review report, implement all fixes (Critical → Important → Minor → Nitpick). Cross-skill consistency check after fixes. Write report to `docs/reviews/fix-{NNN}.md`.
3. **Verify** — confirm each fix resolved the original issue. Regression check on all modified files. Write report to `docs/reviews/verify-{NNN}.md`.

### Early Exit
- After Review: 0 Critical + 0 Important → skip Fix/Verify
- After Verify: 0 remaining blocking issues → stop cycling

### Oscillation Guard
If cycle N has >= blocking issues as cycle N-1, stop immediately. More cycles won't help.

## Pacing Rules
- Never skim a skill. Read every line.
- Never skip a dimension. Write "no issues" for clean ones.
- Never rush later cycles. Cycle 3 gets same attention as cycle 1.
- Never combine Fix and Verify. Fix, then re-read files for Verify.
- Do not manufacture findings. If clean, say so.

## Final Commit

Stage all modified files + all reports. One commit:
```
fix(agents): improve cycle {NNN-to-NNN} — {N} issues fixed, {N} remaining
```

No Co-Authored-By lines.
