---
name: myna-dev-execution-prompt
description: |
  Generate a self-contained execution prompt for Myna development — a fresh session can run it autonomously to implement changes, update docs, review its own work, and push to a feature branch. Use after /myna-dev-brainstorm or any design discussion. Triggers: "write the execution prompt", "create the build prompt", "crystallize this", "package this for implementation".
argument-hint: "[prompt name, e.g. customization-layer]"
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - Agent
  - AskUserQuestion
effort: max
---

# Myna Execution Prompt Generator

You are a senior Myna contributor who just watched a design session. Your job: write the implementation spec that a fresh Claude Code session can execute autonomously — no human involvement until the branch is ready for review.

The output is a markdown file at `docs/prompts/[name].md` that gets copy-pasted into a new session.

---

## Myna Context (baked in — don't re-read these docs every time)

### Architecture
- **Agent file** (`agents/main.md`): system prompt, survives context compaction. Routing rules, identity, session start, direct operations, and core rules live here.
- **Steering skills** (6 files, `myna-steering-*`): preloaded via agent frontmatter, loaded into conversation history — get dropped after compaction. Cross-cutting rules only.
- **Feature skills** (24 files, `myna-*/SKILL.md`): native Claude Code skills, auto-discovered, loaded on demand.
- **Install script** (`install.sh`): copies skills to `~/.claude/skills/`, generates agent file, creates vault structure.
- **Config** (`_system/config/*.yaml`): workspace, projects, people, meetings, communication-style, tags.

### Core Constraints
- Draft, never send. No external actions except personal calendar events with no attendees.
- Vault-only writes. All file writes under `{{VAULT_PATH}}/{{SUBFOLDER}}/`.
- Claude-first (D046). Targets Claude Code, no adapter layer.
- Agent file body = highest persistence. Critical logic goes here.
- Progressive disclosure. Feature skills load on demand via description matching.

### Git Conventions
- Conventional commits: `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`
- Never auto-commit — only when explicitly asked
- Never add Co-Authored-By lines
- Atomic commits — one logical change per commit
- Always commit to a new branch, never to main

### Docs That May Need Updating
When making changes, check if these need updates (don't always include all — only the ones affected):
- `docs/architecture.md` — when structural changes are made
- `docs/decisions.md` — when new decisions are settled (use next D-number in sequence)
- `docs/open-questions.md` — when new questions surface
- `README.md` — when user-facing behavior changes
- `docs/post-install-checklist.md` — when setup/install changes

---

## Phase 1: Extract and Clarify

Read the conversation, extract what you need, and resolve ambiguity before doing anything else.

### 1a. Design Decisions
What was settled? List each as a clear statement. These go into the prompt as "already decided — do not re-debate."

### 1b. Tasks
What needs to change? Identify every file that needs creating, editing, or updating. Group by logical unit of work, not by file.

### 1c. Verify against reality
Read the actual files that will be edited. Check whether the brainstorm's assumptions about file structure, naming, and current state are correct.

### 1d. Open Questions
What wasn't settled? What assumptions from the brainstorm don't match what you read in 1c?

### 1e. Clarify with the user

Check which of the docs listed above need updating based on the changes. Flag any task too ambiguous for autonomous execution. Present everything in one shot:

```
Here's what I extracted. Confirm or adjust:

**Tasks:** [numbered list]

**Open questions** (if any):
1. [Question] — [why it matters]
   - Option A: [description] | Option B: [description]
   - Recommendation: [A or B] because [reason]

**Doc updates I plan to include:** [list]

Say "agreed" to accept all recommendations, or specify what to change.
```

**Only ask questions that would actually block autonomous execution.** Zero questions is fine if the brainstorm was thorough.

---

## Phase 2: Assess

### Scope
- **Small (1-2 tasks):** Simple direct prompt. Inline review checklist.
- **Medium (3-4 tasks):** Sequential tasks with review after each.
- **Large (5+ tasks):** Coordinator with subagent delegation, parallel phases, per-task review.

### Task Dependencies
Map parallel vs sequential. Parallel only when tasks touch different files.

### Risk Assessment
- **High risk:** `agents/main.md` (routing), `install.sh` (user-facing), skill files with complex logic → stricter review.
- **Low risk:** doc updates, config changes, new files → lighter review.

### Review Persona
Match reviewer lens to the work. Specify in the generated prompt: "Review as [role] looking for [what matters]."

### Model Selection
Default to Sonnet. Use Opus only for ambiguous requirements or complex existing code.

### Session Splitting
Split into multiple prompts if 8+ tasks spanning unrelated domains, or tasks have commit-level dependencies. Each prompt is self-contained; later prompts check out the branch from the first.

---

## Phase 3: Generate

Write the prompt to `docs/prompts/[name].md`. The name is either specified by the user or derived from the feature name.

### Prompt Structure

Adapt to scope — Small prompts skip coordinator blocks and review manifesto.

```markdown
# [Title]

[1-2 sentence description.]

[Only for Medium/Large:]
**You are a coordinator.** [delegation instructions]

[Only for Medium/Large:]
**Quality over speed.** Take the time to do each task well. A longer session with high-quality output is better than rushing to finish. Read files thoroughly before editing, review your own work, and don't cut corners on later tasks.

[Only for Medium/Large:]
**Goal: zero human rework.** After you commit, the user should be able to merge without changes. Run review → fix cycles until the review comes back clean. Maximum 3 cycles — if issues persist after 3 rounds, stop and document what's unresolved. But most work should converge in 1-2 cycles.

## Context
[What the executing session needs to know.]

## Design Decisions (already settled — do not re-debate)
[Numbered decisions from the brainstorm + clarifications.]

## What to read first
[Specific file list. Include CLAUDE.md — it has git conventions.]

## Changes to make

### Task 1: [Title]
[Specific instructions. File paths. What to change, what NOT to change.]

#### Review criteria [Review as [role]]
- [ ] [Specific assertion]
- [ ] [Specific assertion]

### Task 2: [Title]
...

[Only for Medium/Large:]
## Review discipline
Only flag issues that would cause real problems — execution failures, wrong output, broken functionality. Don't flag stylistic preferences or theoretical concerns. A clean review is valid. Test: "would this actually break something?" If no, skip it.

## Quality checks
[Concrete verification — syntax checks, grep assertions, counts]

## Commit and push
1. Create a new branch: `feat/[feature-name]` (or `fix/` or `docs/` per conventional commits)
2. Stage all changed files — include this prompt file (`docs/prompts/[name].md`)
3. Commit: `[type]: [description]` — no Co-Authored-By
4. Push to origin
```

### Writing Principles

**Self-contained.** A fresh session must execute without asking anything. Test: "If a stranger pasted this, would they succeed?"

**Specific over general.** "Check YAML frontmatter has exactly 6 entries" beats "verify frontmatter looks correct."

**Right-sized.** Match structure to complexity. A 2-line doc update doesn't need a subagent.

**No meta-instructions.** Everything in the file is for the executing model.

**Coordinator discipline.** Each subagent prompt is self-contained. Parallel only when files don't overlap. Review between phases.

**Doc updates are real tasks.** Same treatment as code changes — instructions, review criteria, quality checks.

---

## Phase 4: Review (1 cycle only)

Spawn a review subagent. One cycle — the prompt is a document, not implementation.

The reviewer checks:
1. **Autonomy** — will it run without asking the user anything?
2. **Completeness** — every task and doc update present?
3. **Accuracy** — file paths correct? Files exist?
4. **Dependencies** — parallel phases truly independent?
5. **Review criteria** — specific enough to catch real issues?

**Review discipline:** Only flag real problems. Don't manufacture findings. Clean review is valid.

---

## Phase 5: Fix and Summarize

Fix valid issues. Then present:

```
## Execution Summary

**Prompt:** docs/prompts/[name].md
**Model:** [Sonnet/Opus] — [why]
**Sessions:** [1 or N]
**Branch:** [type]/[name]

### Tasks
1. [Task] — [description] | Review: [persona]
2. [Task] — [description] | Review: [persona]
...

### Execution Plan
[Parallel/sequential structure]

### Key Decisions
- [Decisions the user should be aware of]

### Concerns
- [Trade-offs or risks before running]
```
