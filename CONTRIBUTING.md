# Contributing to Myna

Myna is a local-first Chief of Staff for tech professionals — AI agent instructions that turn Claude Code into an assistant that reads from your email, Slack, and calendar, and writes exclusively to your local Obsidian vault. It drafts and organizes; it never sends or decides on your behalf.

The project ships a suite of contributor-facing dev skills under `.claude/skills/myna-dev-*/` that automate the full contribution workflow inside Claude Code. These are only available in the Myna repo; they are not installed to user machines.

---

## Getting Started

Clone the repo and open it in Claude Code:

```bash
git clone https://github.com/agentflock/myna.git
cd myna
claude
```

All `/myna-dev-*` skills become available immediately. No additional setup is required to start contributing.

---

## Two Contribution Paths

Contributions fall into one of two workflows depending on whether you have a settled design or a known fix.

---

### Feature / Design Path

Use this path when proposing a new skill, rethinking existing behavior, or any change where the right approach needs to be worked out before writing code.

**Step 1 — Design session:**

```
/myna-dev-brainstorm [describe your idea or problem]
```

This starts an interactive design session. It reads the relevant skill files, checks your idea against vision fit, architecture constraints, and settled decisions, then presents options with trade-offs and a recommendation. The session converges on a settled design — every design decision recorded explicitly before any implementation begins.

At any point once the design is settled, say **"generate prompt"** to move to implementation.

**Step 2 — Generate an execution prompt:**

When you say "generate prompt", the brainstorm skill invokes `/myna-dev-build-prompt`, which writes a self-contained execution prompt to `tmp/[name]/[prefix]-prompt.md`. This file contains the full task breakdown, context, done-when criteria, and orchestration instructions for a fresh session to run autonomously.

**Step 3 — Run the prompt in a new session:**

Paste the prompt file contents into a new Claude Code session. The session runs without human involvement: it implements the changes, reviews its own work up to three rounds, fixes Critical and Important issues between rounds, and pushes a feature branch. You review the diff and open a PR.

**Alternative — queue instead of running immediately:**

Say **"add to queue"** instead of "generate prompt" to defer implementation. The brainstorm skill calls `/myna-dev-task-add`, which drafts a structured task entry and appends it to `tmp/tasks.md`. When you are ready to build, run `/myna-dev-execute-tasks` to process the queued tasks in one automated pass.

---

### Fix / Bug Path

Use this path for known bugs, small targeted changes, or anything where the problem is clearly understood.

**Step 1 — Validate and diagnose:**

```
/myna-dev-diagnose [describe the problem or proposed change]
```

This evaluates whether the problem is real and the fix is valid — checking vision fit, architecture constraints, settled decisions, and whether the behavior is already handled by an existing skill. It then generates two to four options with a recommendation. Say **"add this"** to queue the chosen option directly, or proceed manually to Step 2.

**Step 2 — Queue the task:**

```
/myna-dev-task-add [describe the task]
```

Drafts a structured task entry with a problem statement, correct behavior description, and verifiable done-when criteria. Shows you the draft before writing anything — you approve or adjust, then confirm. Appends to `tmp/tasks.md` on confirmation.

You can invoke `/myna-dev-task-add` directly for any task without going through diagnose first.

**Step 3 — Execute the queue:**

```
/myna-dev-execute-tasks
```

Reads all pending tasks from `tmp/tasks.md` and runs them sequentially on a single `fix/[date]` branch. Each task runs in its own subagent: the subagent implements the change, commits it, then runs the review loop — up to three rounds, fixing Critical and Important issues between rounds. When all tasks finish, the branch is pushed and results are reported. Completed tasks are archived out of `tmp/tasks.md`; failed tasks remain in the queue.

PR creation is always your decision.

---

## Bug Reporting

To file a bug from the current session:

```
/myna-dev-bug
```

The skill infers the prompt, Myna's output, the skill involved, and the model from conversation context. It auto-redacts private content — names, email addresses, and project names — before writing a filled GitHub issue template to `tmp/bugs/`. Review the file, then open the issue on GitHub manually.

You can also pass a description inline:

```
/myna-dev-bug [describe the bug or what the output should have been]
```

---

## Periodic QA

These skills run independent of any specific change. Use them to check the overall health of the skills at any time:

| Skill | What it does |
|---|---|
| `/myna-dev-improve` | Full quality pipeline — lint until clean, then review → fix → verify cycles until no Critical or Important issues remain |
| `/myna-dev-review` | Deep technical review of agent artifacts against 8 dimensions: frontmatter, description quality, instruction clarity, feature completeness, vault format correctness, safety, output usefulness, and steering duplication |
| `/myna-dev-consistency` | Cross-skill vault format audit — finds skills that write to the same vault destination with diverging formats |
| `/myna-dev-coverage` | Feature coverage audit — checks whether every feature in `docs/features/` has executable read → decide → write steps in its owning skill |

---

## Skill Reference

| Skill | User-invocable | Purpose |
|---|---|---|
| `/myna-dev-brainstorm` | yes | Interactive design session — validity-first, then options, then hand-off to build |
| `/myna-dev-bug` | yes | File a bug report from the current session to `tmp/bugs/` |
| `/myna-dev-build-prompt` | yes | Package a settled design into a self-contained autonomous execution prompt |
| `/myna-dev-consistency` | yes | Cross-skill vault format audit — report only, does not fix |
| `/myna-dev-coverage` | yes | Feature spec vs skill coverage audit — report only, does not fix |
| `/myna-dev-diagnose` | yes | Validate a problem and generate fix options with a recommendation |
| `/myna-dev-execute-tasks` | yes | Run the task queue on a fix branch, push the branch, report results |
| `/myna-dev-improve` | yes | Full quality pipeline: lint, then review → fix → verify cycles |
| `/myna-dev-review` | yes | Deep review of agent artifacts against 8 dimensions — report only, does not fix |
| `/myna-dev-task-add` | yes | Draft and queue a structured task entry in `tmp/tasks.md` |
| `/myna-dev-task-protocol` | no (internal) | Shared commit → review → fix protocol called by task subagents; not for direct use |

---

## Git Conventions

- **Conventional commits:** `feat:`, `fix:`, `docs:`, `chore:`, `refactor:` — scope is the skill or area being changed, such as `fix(capture):` or `feat(email-triage):`. Never use task IDs or queue numbers as scope.
- **Never auto-commit** — only commit when explicitly asked.
- **Atomic commits** — one logical change per commit.
- **No Co-Authored-By lines.**
- **No merge commits** — all merges must be fast-forward. If a fast-forward is not possible, rebase first.
- **Commit messages describe what was accomplished**, not which files changed. Lead with the most important change; explain decisions made and problems solved in the body.

---

## Key Documents

| File | Purpose |
|---|---|
| [`docs/vision.md`](docs/vision.md) | North star — what Myna is and is not |
| [`docs/design/product-decisions.md`](docs/design/product-decisions.md) | Product and behavior decisions (settled — do not re-debate) |
| [`docs/design/architecture-decisions.md`](docs/design/architecture-decisions.md) | Runtime and install decisions (settled — do not re-debate) |
| [`docs/design/architecture.md`](docs/design/architecture.md) | Runtime model, skill inventory, vault structure |
| [`docs/design/foundations.md`](docs/design/foundations.md) | Vault folder structure, canonical file formats |
| [`docs/features/`](docs/features) | Approved features per domain — the authoritative source for what is being built |
