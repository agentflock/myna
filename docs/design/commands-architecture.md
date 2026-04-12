# Myna Command System — Architecture

## Overview

Myna has 8 quality-management components: one bash lint script and 7 Claude Code commands. Together they form a self-improvement pipeline for Myna's agent artifacts — the 24 feature skills, 6 steering skills, main agent, and config examples that ship to the user.

The pipeline runs in phases: fast mechanical checks first, then iterative review/fix/verify cycles, with specialized audits available at any point.

```
scripts/lint-agents.sh          Phase 0 — mechanical checks (bash, fast)
        ↓
/myna-review                    Phase 1 — structured quality audit (report only)
        ↓
/myna-fix                       Phase 2 — implement fixes (edits files)
        ↓
/myna-verify                    Phase 3 — confirm fixes resolved issues
        ↓ (repeat if NOT CLEAN)
     done

/myna-improve                   Orchestrator — runs Phase 0→N autonomously
/myna-coverage                  Standalone — feature spec vs skill coverage audit
/myna-consistency               Standalone — cross-skill vault format audit
/myna-skills-polish             Quick pass — per-skill review+fix in one command
```

---

## Command Inventory

| Component | Role | Scope | Output |
|-----------|------|-------|--------|
| `scripts/lint-agents.sh` | Mechanical checks: structure, self-containment, safety keywords | All shipped artifacts | stdout pass/fail |
| `/myna-skills-polish` | Review + fix per-skill in one pass (skills only) | Feature skills (default), optionally steering | `docs/reviews/skills-polish-{NNN}.md` + edits |
| `/myna-review` | Deep audit across 8 dimensions, report only | All artifacts (default) or targeted | `docs/reviews/review-{NNN}.md` |
| `/myna-fix` | Implement or push back on issues from a review | Files listed in latest review | `docs/reviews/fix-{NNN}.md` + edits |
| `/myna-verify` | Confirm fixes resolved issues, check for regressions | Files modified in fix report | `docs/reviews/verify-{NNN}.md` |
| `/myna-coverage` | Feature spec completeness audit | Feature skills (default) or targeted | `docs/reviews/coverage-{NNN}.md` |
| `/myna-consistency` | Cross-skill vault format consistency audit | All writing skills (default) or targeted | `docs/reviews/consistency-{NNN}.md` |
| `/myna-improve` | Full pipeline orchestrator: lint → Review/Fix/Verify cycles | Feature skills + main agent (default) | All report types above |

---

## Pipeline Flow

### Manual cycle

```
bash scripts/lint-agents.sh     # fix all FAIL items first
/myna-review                    # produces review-{NNN}.md
/myna-fix                       # reads latest review, produces fix-{NNN}.md + edits
/myna-verify                    # reads fix + review, produces verify-{NNN}.md
```

If verify says NOT CLEAN, increment the cycle: run `/myna-review` again (new NNN), then fix, then verify.

### Autonomous pipeline (`/myna-improve`)

```
Phase 0: bash scripts/lint-agents.sh → fix all FAIL items → re-run until clean
Phase 1..N (up to --cycles N, default 3):
  Review phase  → review-{NNN}.md
  Early exit?   → if Critical + Important = 0, skip Fix and Verify
  Fix phase     → fix-{NNN}.md + edits to skill files
  Verify phase  → verify-{NNN}.md
  Oscillation?  → if blocking issues ≥ previous cycle, stop
  All resolved? → stop early
Final commit    → one atomic commit covering all cycles
```

### Specialized audits (independent of the main pipeline)

`/myna-coverage` and `/myna-consistency` are standalone commands. They read and report only — neither modifies skill files. Run them at any time, in any order, independently of review/fix/verify cycles.

- `/myna-coverage` — checks every sub-feature in `docs/features/*.md` against its owning skill's executable steps
- `/myna-consistency` — checks every shared vault destination (timeline, observations, tasks, etc.) against canonical formats from `docs/design/foundations.md` and the conventions steering skill

To fix issues surfaced by either audit, use `/myna-skills-polish` on the affected skills.

---

## Targeting System

All commands accept `$ARGUMENTS` for scope control. Targeting is consistent across commands.

### Common targeting arguments

| Argument | Meaning |
|----------|---------|
| (none) | Default scope for that command (see below) |
| `agents/skills/myna-sync/SKILL.md` | Specific file |
| `agents/skills/myna-*/SKILL.md` | Glob pattern |
| `--uncommitted` | Files with uncommitted git changes under `agents/` |

### Default scopes by command

| Command | Default scope (no arguments) |
|---------|------------------------------|
| `/myna-review` | All 24 feature skills + all 6 steering skills + `agents/main.md` + `agents/config-examples/*.yaml.example` |
| `/myna-fix` | Derives scope from the latest review report — no targeting needed |
| `/myna-verify` | Derives scope from the latest fix report — no targeting needed |
| `/myna-skills-polish` | All feature skills (`agents/skills/myna-*/SKILL.md`, excludes steering) |
| `/myna-coverage` | All feature skills + steering skills + main agent + config examples |
| `/myna-consistency` | All shared-destination writing skills (hard-coded in the command) |
| `/myna-improve` | All feature skills + `agents/main.md` (excludes steering) |

### Command-specific targeting flags

| Flag | Available in | Meaning |
|------|-------------|---------|
| `--include-steering` | `/myna-skills-polish`, `/myna-improve` | Also review steering skills |
| `--cycles N` | `/myna-improve` | Max Review/Fix/Verify cycles (default 3, range 1–10) |
| `--auto` | `/myna-fix` | Implement all recommendations without pushback |
| Issue IDs (e.g., `C01 I03`) | `/myna-fix` | Selective mode — only fix listed issues |
| Cycle number (e.g., `003`) | `/myna-verify` | Verify a specific cycle rather than the latest |
| Destination names | `/myna-consistency` | e.g., `timeline`, `contributions` — check only those destinations |

---

## Report System

### Storage location

All reports write to `docs/reviews/`. The directory is created automatically if it doesn't exist.

### Naming conventions

```
docs/reviews/
  review-001.md          # /myna-review or /myna-improve review phase
  fix-001.md             # /myna-fix or /myna-improve fix phase
  verify-001.md          # /myna-verify or /myna-improve verify phase
  review-002.md          # next cycle
  fix-002.md
  verify-002.md
  skills-polish-001.md   # /myna-skills-polish (own sequence)
  coverage-001.md        # /myna-coverage (own sequence)
  consistency-001.md     # /myna-consistency (own sequence)
```

### Cycle number sharing

The `review-{NNN}.md`, `fix-{NNN}.md`, and `verify-{NNN}.md` triplet shares a single cycle number. All three reports for a given cycle carry the same `{NNN}`. This creates an unambiguous audit trail: given any report, you can find the other two.

`skills-polish-{NNN}.md`, `coverage-{NNN}.md`, and `consistency-{NNN}.md` each have their own independent numbering sequence.

### Auto-incrementing

Each command determines the next cycle number by scanning `docs/reviews/` for the highest existing file with its prefix pattern, then adding 1. Starting value is `001`. Numbers are zero-padded to 3 digits.

`/myna-fix` and `/myna-verify` do not pick their own number — they derive it from the report they are responding to (`/myna-fix` uses the latest `review-{NNN}.md`; `/myna-verify` uses the latest `fix-{NNN}.md`).

### Guard against re-runs

`/myna-fix` stops with an error if `docs/reviews/fix-{NNN}.md` already exists for the current review cycle. This prevents accidental double-runs. The user must delete or rename the existing file to re-run.

---

## Severity Model

All review commands use a 4-level severity model. Issue IDs are severity-prefixed and numbered within each severity level per file.

| Severity | Code | Definition | Examples |
|----------|------|------------|---------|
| Critical | `[C01]` | Breaks functionality, safety violation, skill undiscoverable | Draft-never-send violated, description over 250 chars with no useful content, skill has fewer than 3 H2 sections or under 50 lines |
| Important | `[I01]` | Claude would struggle or produce wrong output | Sub-feature with no executable steps, significant format drift from foundations.md, vague instruction with no decision criterion |
| Minor | `[M01]` | Polish issue, no functional impact | Golden Rule violation (line Claude would follow by default), slight inconsistency, missing `argument-hint` |
| Nitpick | `[N01]` | Cosmetic only | Style preference, extra space, slightly different example phrasing |

**Issue ID rules:**
- Each severity level is numbered independently: C01, C02 … I01, I02 … M01, M02 …
- IDs are unique within a single file's findings
- `/myna-improve` assigns cross-skill global IDs after consolidating all subagent results

**Convergence signal:** a review with 0 Critical + 0 Important means CONVERGED. The pipeline can stop.

---

## Evaluation Dimensions

`/myna-review` (and the review phase of `/myna-improve`) evaluates every file against 8 dimensions. `/myna-skills-polish` uses 9 criteria. See each command for the full rubric — this is a summary.

### /myna-review — 8 dimensions

| # | Dimension | What it checks |
|---|-----------|----------------|
| 1 | Frontmatter correctness | Valid YAML, required fields, `description` under 250 chars, `user-invocable` correct, valid field names only |
| 2 | Description quality for auto-discovery | Trigger keywords present, differentiates from sibling skills, specific enough to avoid false loads |
| 3 | Instruction clarity | No vague verbs, every branch has a decision criterion, file paths specific, MCP tool calls named explicitly |
| 4 | Feature completeness | Every feature in architecture.md "Features covered:" line has executable steps (read → decide → write), not just a mention |
| 5 | Vault format correctness | Write paths match foundations.md, section names exact, entry formats match canonical, provenance markers correct |
| 6 | Safety | Draft-never-send, vault-only writes, no automatic skill chaining, external content wrapped in safety delimiters, bulk write confirmation, calendar three-layer protection |
| 7 | Output usefulness | Specific and actionable output (counts, file links, next steps), no AI filler phrases, follow-ups as text suggestions not auto-invocations |
| 8 | Steering duplication | Rules in feature skills that duplicate steering skill coverage — candidates for deletion |

### /myna-improve review phase — 10 dimensions

Adds two dimensions to the 8 above:

| # | Dimension | What it checks |
|---|-----------|----------------|
| 9 | Edge cases | First run, missing files, ambiguous entity resolution, empty MCP results, bulk operations, re-run idempotency, disabled feature toggles |
| 10 | Conciseness | Golden Rule — would Claude produce the same output without this line? Skills over 500 lines flagged. |

---

## Convergence and Oscillation

### Early exit conditions (`/myna-improve`)

The Review/Fix/Verify loop stops before reaching `--cycles N` if:

1. **After Review:** Critical + Important = 0. No fix needed. Skip Fix and Verify phases.
2. **After Verify:** Critical + Important remaining = 0. All blocking issues resolved.
3. **Oscillation guard triggers** (see below).

### Oscillation guard

Before each cycle after the first, `/myna-improve` counts remaining blocking issues (Critical + Important) from the previous verify report. If the count is **the same or higher** than the previous cycle, the pipeline stops immediately.

The guard prevents thrashing: if fixes are reverting themselves, introducing new issues, or if review and fix passes are contradicting each other, more cycles will not help. The pipeline halts and flags the situation for human review.

```
Oscillation detected — cycle {N} found {X} blocking issues,
same or worse than cycle {N-1} ({Y}). Pipeline halted.
```

### CONVERGED state

A system is CONVERGED when a `/myna-review` run finds 0 Critical + 0 Important issues. This means:
- All safety rules are intact
- All features have executable steps
- Instruction clarity is sufficient for Claude to execute without guessing
- Vault formats are correct

Minor and Nitpick issues may remain in a CONVERGED system — they do not block convergence.

---

## Relationship Between Commands

### When to use which command

| Situation | Use |
|-----------|-----|
| Quick per-skill quality pass with immediate fixes | `/myna-skills-polish` |
| Want to review before deciding what to fix | `/myna-review` → read report → `/myna-fix` |
| Fix everything in a review without judgment | `/myna-fix --auto` |
| Fix only specific issues | `/myna-fix C01 I03` |
| Confirm fixes landed correctly | `/myna-verify` |
| Full autonomous improvement run | `/myna-improve` |
| Audit feature spec coverage | `/myna-coverage` |
| Find cross-skill format drift | `/myna-consistency` |
| Pre-commit mechanical check | `bash scripts/lint-agents.sh` |

### Key distinctions

**`/myna-skills-polish` vs `/myna-review`:**
`/myna-skills-polish` reviews AND fixes in the same pass, scoped to feature skills only. `/myna-review` is broader (includes steering, main agent, config examples), does not fix anything, and produces a structured report with options for every issue. Use `/myna-skills-polish` when you want fast results on skills. Use the review/fix/verify triplet when you want deliberate control over what gets changed.

**`/myna-review` vs `/myna-coverage` vs `/myna-consistency`:**
`/myna-review` is the general quality gate — it covers all 8 dimensions across all artifact types. `/myna-coverage` is purpose-built to answer one question: "does every feature from the spec have executable steps in its skill?" `/myna-consistency` is purpose-built to answer: "do all skills writing to the same vault destination agree on format?" Both specialized audits go deeper on their specific question than `/myna-review` does.

**`/myna-fix` default vs `--auto`:**
Default mode evaluates each issue against project context and can push back with documented reasoning. `--auto` implements everything without judgment. Use default mode when the review may have false positives. Use `--auto` when you trust the review and want speed.

**`/myna-improve` vs manual pipeline:**
`/myna-improve` is the same pipeline executed autonomously — it runs lint, then review, fix, and verify phases in sequence, with oscillation detection and early exit. Use it when you want hands-off improvement. Use the manual pipeline when you want to inspect or modify the review report before fixes are applied.

### Lint as a gate

`scripts/lint-agents.sh` is not a Claude Code command — it's a bash script that runs fast deterministic checks. `/myna-improve` runs it in Phase 0 and will not proceed to review cycles until lint passes. The manual pipeline expects the user to run lint first. `/myna-review`, `/myna-fix`, and `/myna-verify` each run lint at the end and record the result in their reports, but they don't block on lint failures.

Lint checks that shipped artifacts are self-contained (no references to `foundations.md`, `architecture.md`, `decisions.md`, `docs/` paths, or decision IDs that don't exist at runtime), structurally complete (minimum H2 sections, worked examples, frontmatter), and free of ambiguous safety keywords.
