---
name: myna-dev-task-add
description: |
  Add one or more tasks to the Myna dev queue (tmp/tasks.md) — drafts structured task entries from your description (or a settled brainstorm design), independently reviews them for autonomous-execution readiness, shows them for approval, then appends them to the queue. Use when: "add this to the queue", "queue this up", "add a task for X", or after /myna-dev-diagnose or /myna-dev-brainstorm. Creates tmp/tasks.md if it doesn't exist.
argument-hint: "[describe the task, bug fix, or change to queue]"
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Agent
  - AskUserQuestion
effort: medium
---

# Myna Add Task

Draft one or more structured task entries and append them to `tmp/tasks.md`. Show the draft(s) to the user before writing — they approve or adjust.

## Input

A single invocation can add **one or more** tasks — draft a separate entry per logical unit of work.

Check `$ARGUMENTS` and conversation context:
- **If a single task is described:** use it as the task description and proceed to Step 1.
- **If multiple changes are described, or a settled design from `/myna-dev-brainstorm` is being handed off:** decompose into logical task units (group by unit of work, not by file) and draft one entry per unit. Include a companion doc task if the changes update records (architecture/decisions/README).
- **If empty and coming from conversation context** (e.g., invoked after `/myna-dev-diagnose`): use the agreed option(s) from that conversation and proceed to Step 1.
- **If empty with no context:** ask the user: "What task do you want to add to the queue?"

---

## Step 1 — Read the Queue

Check if `tmp/tasks.md` exists:
```bash
ls tmp/tasks.md 2>/dev/null
```

If it exists, read it to:
- Get the current highest task number (for the next `#`)
- Understand the format already in use

If it doesn't exist, the next task number is 1.

---

## Step 2 — Draft the Task Entr(ies)

From `$ARGUMENTS` and any conversation context, draft one entry per logical task. Infer what you can — don't ask for information that's already clear. Number entries sequentially from the current highest task number (Step 1) — if the queue's highest is 3 and you're adding two tasks, they become Task 4 and Task 5.

Use this structure for each:

```markdown
## Task [N] — [Title]

**Problem:** [What's wrong or what's missing — and why it matters. 1-3 sentences.]

**Correct behavior:** [What Myna should do instead — described as behavior, not implementation. 1-3 sentences.]

**Context:** [Background the implementer needs. Relevant skill paths, related decisions, constraints. Skip if obvious.]

**Suggested files:** [Most likely files to change — paths only. Omit if unclear.]

**Done when:**
- [Specific, verifiable assertion — not "it works" but "the skill's frontmatter contains X" or "vault writes use path Y"]
- [Add as many as needed to fully define completion]

**changelog:** [yes | no]
**changelog-line:** [- [Added/Fixed/Changed] Description of what changed from the user's perspective.]
```

The `changelog` field defaults to `no`. Set to `yes` for any task that produces a change a user running Myna would notice: new behavior, new skill, fixed bug, changed output format. Set to `no` for internal refactors, dev tooling changes, and doc cleanup.

The `changelog-line` field is only required when `changelog: yes`. Format: `- [Added/Fixed/Changed] Description of what changed from the user's perspective.` Omit when `changelog: no`.

**Inferring changelog fields:** if the task clearly introduces new user-facing behavior (new skill, new output, behavior fix), set `changelog: yes` and draft a line. If it's purely internal (refactoring skill internals, updating dev tooling, fixing docs), set `changelog: no` and omit `changelog-line`. When unsure, default to `no` — the user can always change it before approving.

**Title:** imperative, concise (5-8 words). "Add base guard to calendar skill" not "Calendar skill base guard fix".

**Problem:** fact-based, not opinion. "The skill writes to `X/Y/Z` but foundations.md specifies `A/B/C`" not "the skill seems wrong."

**Correct behavior:** what the system does when working, not the implementation steps to get there.

**Context:** only what the implementer genuinely needs that they couldn't find from reading the skill file. Don't pad this.

**Suggested files:** paths, not descriptions. If you don't know, omit — don't guess.

**Done when:** specific and verifiable. These become the `--criteria` for the review subagent. "The skill correctly handles X" is not verifiable. "The skill's Step 3 reads `_system/config/workspace.yaml` before writing" is verifiable.

---

## Step 3 — Review the Draft(s)

Two lenses, in order — *intent* (does this capture what was asked?) and *autonomy* (can a stranger execute it?). Each alone leaves a blind spot.

### 3a. Same-context review (up to 2 passes)

You drafted these from the conversation — use that vantage, because only you can check it. Re-read each entry and fix:
- **Intent fidelity** — captures what the user actually asked for or the brainstorm settled; nothing dropped or distorted.
- **Correct decomposition** — one logical unit per entry; no entry bundles two changes; no two entries collide on the same edit.
- Any obvious gaps against the autonomous bar you can already see.

Fix what you find, then re-read — up to 2 passes, stopping early once a pass finds nothing.

### 3b. Independent review (subagent, up to 2 rounds)

Now test self-containment — you can't judge it yourself, because you have the conversation in your head. Each round, spawn a review subagent that receives **only the drafted entries**, no conversation context, and judges whether each is executable on its own. Fix valid findings yourself, then re-spawn for the next round. Loop up to 2 rounds, stopping early once a round is clean. Only then proceed to Step 4.

Spawn with the Agent tool. Prompt:

> You are reviewing draft task entries for a Myna dev queue. You have no prior context — that is deliberate. Each entry will later be handed verbatim to a subagent that must implement it with **no chance to ask questions**, so judge each purely on what it contains plus the files it names.
>
> [paste the drafted entries verbatim]
>
> Check each against the autonomous-execution bar:
> 1. Self-contained context — implementable without guessing? Flag anything that assumes knowledge not written here.
> 2. Verifiable Done-when — every criterion specific and checkable, not "it works".
> 3. Concrete, real file paths — read the named files to confirm they exist and are the right ones.
> 4. Correct decomposition — one logical unit per entry; no entry bundles two changes; no two entries collide on the same edit.
> 5. Accurate changelog fields — match whether the change is user-facing.
>
> Report concrete issues per task, or "clean" if none. Do not rewrite the tasks — just report.

---

## Step 4 — Show and Confirm

Present the draft(s) — one block per task:

```
Here's the task draft:

---
## Task [N] — [Title]

**Problem:** [...]

**Correct behavior:** [...]

**Context:** [...] *(omit section if empty)*

**Suggested files:** [...] *(omit section if empty)*

**Done when:**
- [...]

**changelog:** [yes | no]
**changelog-line:** [...] *(omit if changelog: no)*
---
```

When adding multiple, show every entry, then: "Say "add them" to append all to the queue, or tell me what to change." For a single task: "Say "add it" to append to the queue, or tell me what to change."

Wait for the user's response. Apply any adjustments. Do not write to the file until the user approves.

---

## Step 5 — Write to Queue

Write every approved entry — one table row and one task body each.

### If tmp/tasks.md does not exist

Create it with all entries (one row per task in the table, one body per task below):
```markdown
# Myna Task Queue

| # | Title | Status | Branch | Review rounds | Reports |
|---|---|---|---|---|---|
| 1 | [Title] | pending | — | — | — |

---

## Task 1 — [Title]

[task body]
```

### If tmp/tasks.md exists

Append a new table row per task:
```
| [N] | [Title] | pending | — | — | — |
```

Append each task body after the last existing task section, in order.

---

## Step 6 — Confirm

For a single task:
```
Added Task [N] — [Title] to tmp/tasks.md.
Run /myna-dev-execute-tasks to process the queue.
```

For multiple:
```
Added Tasks [N]–[M] to tmp/tasks.md ([count] tasks).
Run /myna-dev-execute-tasks to process the queue.
```
