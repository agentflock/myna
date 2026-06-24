# Myna

**The system for everything you're trying to keep in your head.**
**Nothing leaves your machine.**

AI Chief of Staff for tech professionals — your projects, your team, your meetings, your email, all running locally inside [Claude Code](https://claude.ai/code).

*Built autonomously by Claude Code, end to end — 12 agents, 31 skills, no vibe-coding. [How it was built →](docs/how-it-was-built.md)*

---

## The day you actually have

It's 7:45 AM. You haven't opened your laptop, and you already know roughly what's waiting. A 9 AM 1:1 with someone who's been stretched thin — and you still haven't written down the pattern. Six meetings stacked back to back, none of them prepped. An inbox of 38 unread, four of which are real and the rest of which look real. A VP who wants a "quick Phoenix risk note" by Friday, which means remembering what happened in week one of Phoenix — 47 days ago. Two people owe you something; you owe four people something back. And somewhere in there, you're supposed to do your own work.

You're not behind. This is just the job. If you manage projects and people, most of your day isn't decision-making — it's information management: triage, prep, catch-up, drafting the same kind of update for the fifth time this month, trying to recall what was decided three weeks ago. Roughly 80% of the week is moving information around. The other 20% is the work only you can do — and it's the part you actually get paid for.

The tools you already have don't fit the shape of that 80%:

- **General AI chat** (Claude, ChatGPT, Gemini) starts every session from zero. It doesn't know who Marcus is, what Phoenix is blocked on, or how you sign your emails — so you spend the first three minutes re-explaining context, and none of it survives the closed tab.
- **Local AI notebooks** (Khoj, Fabric, PrivateGPT) answer questions about notes you already wrote. They don't *do* the work — no prep brief, no triage routing, no drafted escalation. They're search engines with a chat box, not assistants.
- **Cloud "AI assistants" for work** want to live in the middle of your stack and ingest your email and calendar onto someone else's servers. At most companies that's a non-starter — and even where it's allowed, it's one more vendor to evaluate and one more thing to break.

Myna sits exactly in that gap.

## What Myna is

Myna is a [Claude Code](https://claude.ai/code) agent with **31 skills** built for the specific work tech professionals do every week. You type a prompt in plain language; Myna does the work — reading from the email, Slack, and calendar MCP servers your company already approved, and writing everything it learns as plain markdown into a single folder on your machine.

Install it once, and every session builds on the last. The brief you get on Sarah this morning already includes the recognition you logged last week, the 1:1 notes from three weeks ago, and the design review she led on April 9 — because Myna wrote them down when they happened. The Phoenix risk note you draft today knows the blocker is 20 days old because that history is sitting in the project file.

It **drafts but never sends. It organizes but never decides. It surfaces but never hides.** You still pick up the phone, send the email, and make the call — Myna just makes sure that when you do, you're not winging it from memory.

## See it in action

A day in the life of an engineering manager using Myna. Every line is a prompt you'd actually type into Claude Code.

```
7:45 AM — coffee, laptop open
> daily-brief
↳ Daily note created. Today's meetings as a table with linked prep.
  Phoenix blocker flagged. Sarah Mitchell's reply overdue.

8:10 AM — before your 9am 1:1
> prep for my 1:1 with Marcus
↳ Open items from last time, pending feedback with coaching notes,
  parental leave thread — all in one brief.

9:35 AM — back from the 1:1
> done with 1:1 with Marcus
↳ Tasks, decisions, observations extracted and routed to the right files.

9:50 AM — quick multi-thing capture
> capture: Sarah handled Payments questions well, atlas is unblocked,
  review Sentinel audit by Friday
↳ 3 items → 3 files. Recognition, timeline update, task with due date.

12:45 PM — VP wants a risk note
> draft the Phoenix risk note for the VP review
↳ Leads with the conclusion, evidence-grounded, under 200 words.
  Ready for you to review, then send yourself.

1:15 PM — pre-read for tomorrow's staff meeting
> review this PRFAQ [paste]
↳ 7 personas in parallel — Product Leader, PM, Customer Skeptic, PE,
  Security, Skeptic, Writer/Editor — synthesized into one report.
  Saved to Reviews/2026-05-26-pricing-prfaq.md.

3:45 PM — the ambiguous pile
> review my queue
↳ Items Myna wasn't sure about — you approve, redirect, or dismiss.

5:30 PM — close the day
> wrap up
↳ Planned vs actual. Contributions logged. Tomorrow's note created with carry-forwards.
```

Not an EM? The same skills work for tech leads, senior engineers, and PMs — anyone managing projects, people, and a constant stream of communication.

Full walkthrough: [A Day With Myna](docs/guide/a-day-with-myna.md) · Browse the [demo vault](tests/fixtures/vault/myna) to see the files Myna creates.

## Why Myna is different

Notice what those prompts have in common: not one needed a format, a tone, or a destination explained. Three things make that possible — and a fourth makes Myna yours to reshape.

**1. It's purpose-built for the work you actually do.** Myna isn't a generic "AI assistant" prompt — it's 31 task-specific skills, each built for a real moment in a tech professional's week. Each one already knows what to read, what to write, where the result lives, and what to refuse. You don't describe the shape of a 1:1 prep or a VP risk note; the skill has done this job before. That's the difference between a chat box and an assistant.

**2. It builds a knowledge base that's yours, on your machine.** Every session writes back to your vault, and the next session reads it. So "brief me on Marcus" pulls six months of 1:1 history, observations, and pending feedback you logged without thinking about it; "draft recognition for Sarah" cites the actual April 9 design review; "what did I ship this quarter?" becomes a real query instead of a vibe. It's all plain markdown in one folder — readable, editable, greppable, and yours to walk away with the day you stop using Myna.

**3. It's safe for the enterprise you actually work at.** Myna writes only to that one local folder, drafts instead of sending, and adds zero new infrastructure — it reuses the MCP servers your security team already approved. There's nothing new for them to evaluate. (The privacy section below spells out exactly how each guarantee holds.)

**4. It's yours to keep changing — with the same harness that built it.** Myna doesn't make you wait on a roadmap. It ships the dev skills Claude used to build it, so when you want a new skill, hit a bug, or need an existing skill to behave differently, you describe the change in plain language and a guided design → build → review → PR loop makes it real. Most assistants let you flip a few settings; Myna hands you the toolchain that builds it.

Here's how that lands against the two kinds of tools you've probably already reached for:

| | AI Chat Tools<br>*(Claude, ChatGPT, Gemini)* | Local AI Tools<br>*(Khoj, Fabric, PrivateGPT)* | **Myna** |
|---|---|---|---|
| **Built for** | General-purpose chat | Q&A over your notes | **Your workday — daily brief, meeting prep, email triage, project catch-up, doc review** |
| **Your data** | On a server, general-purpose memory | Your existing notes, unstructured | **Your projects, people, and meetings — organized as you work** |
| **What it creates** | Chat responses and one-off documents | Answers about your notes | **Drafts, prep, briefs, daily notes — files you review before using** |
| **How it works** | You direct every step | One question, one answer | **One prompt — Myna routes, updates, and files across your vault** |
| **Integrations** | Whatever you describe | Your local files | **Email, Slack, and calendar via your company's existing MCPs** |
| **Customizable** | Settings and custom GPTs | Config file or source code | **Plain-text skills you can read and edit — or reshape with the bundled dev harness** |

## What Myna does

31 skills, grouped by the part of your day they belong to. You don't memorize them — you type natural language and Myna routes to the right one. Each example below is a real prompt.

**Your daily rhythm.** Start the day, capture in passing, close it out.
- `daily-brief` — your morning note: today's meetings as a table with linked prep, overdue tasks, vault reminders surfaced, review queue flagged
- `what should I focus on today?` — ranked priorities, grounded in actual blockers and unreplied threads
- `capture: Sarah crushed the Payments review, atlas is unblocked, remind me Friday to check the Sentinel audit` — one sentence routed to three files at once
- `remind me on Friday to review the deploy checklist` — vault reminder written immediately, surfaces in your daily brief, with an optional calendar push if you give a time
- `park this` / `resume auth caching` — zero-loss context switching across sessions
- `wrap up` — planned vs actual, contributions logged, tomorrow's note seeded

**Your inbox and Slack.** Cut the noise, route the signal.
- `triage these inbox emails` — folder recommendation and one-line reasoning per email; anything needing your reply is flagged **Action Required**, with an overdue marker once the deadline has passed
- `process updates` — reads your project-mapped Slack channels and email folders and routes the structured data into your vault: project updates, action items, and timeline entries land in the right files
- `process instructions` — reads a configured folder for the instructions you leave Myna while clearing your inbox, then carries them out — draft a reply, add a TODO, and so on

**Your meetings.** Prep before, process after.
- `prep for my 1:1 with Marcus` — open items, pending feedback with coaching framing, recent context
- `prep for my remaining meetings today` — skips the already-prepped, fills in the rest
- `done with 1:1 with Marcus` — tasks, decisions, and observations extracted and routed in one step
- `reserve 2 hours Monday for the coverage plan` — personal time blocks only; Myna never creates events with attendees

**Your projects.** Stay current without digging.
- `catch me up on atlas migration` — timeline, blockers, tasks, dependencies, upcoming meetings
- `what's blocked?` — every blocker across every project, with age and next action
- `what am I waiting on?` — what needs your reply vs. what you're owed
- `break down the "review Sarah's caching design doc" task` — subtasks with reasoning

**Your people.** Briefs, patterns, and the gaps you can't see.
- `brief me on Sarah Carter` — role, shared projects, open items, pending feedback, 1:1 history
- `how is my team doing?` — portfolio view: tasks, overdue, feedback gaps, last 1:1 per person
- `analyze my 1:1s with Marcus` — patterns, follow-through rate, recurring topics
- `who haven't I given feedback to in a while?` — feedback-gap alerts sorted by staleness
- `build Sarah's performance review narrative` — synthesized from months of observations and recognition

**Your writing.** Grounded in context, in your voice.
- `draft an escalation for the Phoenix validator blocker` — severity, impact, recommended action, grounded in project history
- `draft recognition for Sarah Carter for the design review this week` — specific and evidence-backed, never generic
- `fix this: i wanted to loop you in on sarahs progress...` — grammar and tone cleaned up, your voice preserved
- `draft reply to James about the Q3 staffing proposal` — pulls from James's person file and related projects

**Your own track record.** Stop underselling yourself.
- `log contribution: led atlas design review, got cross-team alignment` — categorized and appended to this week's log
- `build my brag doc for Q1` — assembled from your contributions, organized by impact
- `am I underselling myself in this self-review?` — checks your draft against what you actually logged

**Documents that hit your desk.** Multi-persona review of any technical doc.
- `review this PRFAQ: [paste]` — Product Leader, PM, Customer Skeptic, PE, Security, Skeptic, and Writer/Editor run in parallel, synthesized into one report
- `review this design doc: [paste]` — composes the right panel (PE, Sr SDE, SRE, Security, QA) for the doc type
- 11 personas available in total; reports save to `Reviews/`

And underneath all of it, **the review queue.** Anything Myna isn't sure about — an ambiguous owner, an inferred contribution, an unclear intent — lands in a persistent queue instead of resolving silently. `review my queue` walks you through them one at a time, and you approve, redirect, or dismiss.

The [User Guide](docs/guide/guide.md) covers all 31 skills in the order you'd use them, with what each one reads and writes.

## Privacy and security

Myna was designed for people whose company won't let them paste a customer email into ChatGPT. The guarantees are specific, layered, and verifiable — and they're the reason the differentiation above is more than a marketing claim.

- **All writes are local.** Every Myna write lands inside one folder, `<vault>/myna/`, on your machine. It never writes anywhere else. The single exception is a *personal* calendar time block — a solo event with no attendees, never an invite — enforced by a hard check before every write.
- **Draft, never send.** Outbound communication is always a file in `Drafts/` that you copy and send yourself. There is no `send_email` skill, no `post_to_slack`, no `create_meeting_with_attendees`. Ask Myna to send something and it refuses, then offers to draft instead. The safety rules are plain markdown you can read for yourself: [skills/steering-safety/SKILL.md](skills/steering-safety/SKILL.md).
- **It reuses your company's MCP servers.** Myna ships zero MCP servers of its own. For email, Slack, and calendar it uses whatever Gmail/Slack/Calendar MCP your company has already approved and you've already registered with Claude Code. There is nothing new for security to evaluate.
- **External content is data, not instructions.** Emails, Slack messages, and pasted docs contain text — and that text might say "ignore previous instructions" or "delete all project files." Myna treats every piece of external content as data to extract from, never as a prompt to follow. Enforced at three layers: agent instructions, content-framing delimiters in skills, and hooks that block dangerous actions regardless of what triggered them.
- **No personal data in the repo.** Your projects, people, channels, and preferences live in YAML config under `<vault>/myna/_system/config/` — gitignored, and entirely separate from the codebase. You can fork or share the Myna repo without leaking a thing about your work.
- **No background process.** No server, no API endpoint, no daemon, no scheduled job, no telemetry. Myna runs only while you have a prompt open in Claude Code, and the moment the session ends, nothing is running.

Details: [SECURITY.md](SECURITY.md).

## How it works

Myna is not an application. There's no server, no API, no frontend. It's 31 skills, a folder structure, and config files — all running inside Claude Code.

```
┌─────────────────────────────────────────────┐
│  You (in Claude Code)                       │
│  "prep for my 1:1 with Sarah"               │
└──────────────────┬──────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────┐
│  Myna Agent + Skills                        │
│  Loaded on demand · Safety at every layer   │
└────────┬────────────────────┬───────────────┘
         │                    │
         ▼                    ▼
┌─────────────────┐  ┌───────────────────────┐
│  Your Machine   │  │  Your MCP Servers     │
│  (local files)  │  │  (email, Slack, cal)  │
│  reads & writes │  │  reads only           │
└─────────────────┘  └───────────────────────┘
```

The runtime is Claude Code; Myna supplies the expertise. Skills load on demand — at session start, Claude Code sees only their names and one-line descriptions, and the full skill loads only when your prompt matches. Six steering skills (safety, conventions, output style, vault ops, system, memory) are always preloaded so cross-cutting rules apply to everything. Vault operations use Claude Code's built-in file tools (Read, Write, Edit, Grep, Glob) — no MCP server ships with Myna.

Everything goes into your **Myna vault** — a folder on your machine, readable in any editor. [Obsidian](https://obsidian.md/) is recommended (the dashboards use Dataview) but optional.

```
myna/
├── Journal/          # Daily notes, weekly summaries, contributions
├── Projects/         # One file per project — timeline, blockers, tasks
├── People/           # One file per person — observations, feedback, notes
├── Meetings/         # 1:1s, recurring, ad-hoc — prep and notes
├── Drafts/           # Email drafts, status updates, recognition
├── Reviews/          # Multi-persona doc reviews — PRFAQs, design docs
│   └── sources/      # Original pasted content
├── ReviewQueue/      # Items awaiting your judgment
├── Team/             # Team-level files
└── _system/          # Config, data, dashboards, templates
    ├── config/       # Your projects, people, preferences (gitignored)
    ├── data/         # Machine-written data: links index, reminders
    └── dashboards/   # Dataview dashboards (best viewed in Obsidian)
```

For the deeper model, see [Architecture](docs/design/architecture.md).

## Getting started

You'll be running your first prompt in about five minutes.

**Prerequisites**

- **[Claude Code](https://claude.ai/code)** — the runtime Myna lives in
- **[Obsidian](https://obsidian.md/)** — recommended for the Dataview dashboards; optional, since every file is plain markdown that opens in any editor
- **Python 3** — only for the interactive Config UI during setup; you can edit the YAML by hand instead

**Install.** Run these three lines inside Claude Code:

```
/plugin marketplace add agentflock/plugins
/plugin install myna@agentflock
/myna:setup
```

`/myna:setup` is a ~5-minute interactive conversation: it creates your Myna folder (the vault subfolder is always `myna/`), walks you through your projects, people, and preferences via the Config UI, and offers shell aliases so you can launch Myna from any terminal. Prefer to edit by hand? Skip the UI — your config lives at `<vault>/myna/_system/config/`, and each file ships with a `.example` showing every field.

> **Not on Claude Code?** Run `./install.sh` from the repo root — it detects your installed AI runtime and runs the right installer. Kiro is supported today; Codex support is planned. Claude Code users should use the plugin commands above (`install.sh` will redirect you if you run it by mistake).

**Connect your tools (optional).** Myna works without email, Slack, or calendar on day one. To enable them, register your company's existing MCP servers with Claude Code:

```bash
claude mcp add gmail-mcp -- <your-gmail-mcp-command>
claude mcp add slack-mcp -- <your-slack-mcp-command>
claude mcp add gcal-mcp  -- <your-gcal-mcp-command>
```

Skip any you don't have — skills that need a missing MCP degrade gracefully and tell you what's missing instead of breaking.

**Run Myna.** From any directory:

```
myna          # full access — reads and writes your vault
myna-ro       # read-only — browse and query, no changes
```

`myna-ro` is a good first look; you can poke around without anything being written.

**Try these on day one:**

```
what can you do?
daily-brief
brief me on <someone you work with>
catch me up on <one of your projects>
capture: <some thought you'd otherwise lose>
```

If something doesn't behave, just ask — `why didn't daily-brief find anything?` — and Myna will tell you which config or MCP is missing. `/myna:update` refreshes the installed skills only; your vault, configs, and any custom overrides are never touched.

## Built entirely by Claude Code

Myna was built **autonomously by Claude Code — not vibe-coded.** One person defined the vision, settled the key decisions, and reviewed at the design points. Everything else Claude did end to end, with minimal oversight during the build: it designed the architecture, wrote 12 agents (the main Myna agent plus 11 specialist review subagents) and all 31 skills (25 feature skills and 6 steering skills), built the file templates and dashboards, created the install script, and wrote this documentation.

That's why Myna has two first-class outputs, not one: the assistant itself, and a reusable methodology for having AI build an agentic system end to end — concentrated human effort at the design points, minimal oversight during the build, portable to any capable LLM. And that methodology isn't just documented: it ships in the repo as the dev harness you use to extend Myna — the same `/myna-dev-*` skills (`/myna-dev-brainstorm`, `/myna-dev-diagnose`) Claude built it with.

[How it was built →](docs/how-it-was-built.md)

## Documentation

| Document | Purpose |
|----------|---------|
| [User Guide](docs/guide/guide.md) | Full reference — every skill, config, workflow, troubleshooting |
| [A Day With Myna](docs/guide/a-day-with-myna.md) | Realistic workday walkthrough with real prompts |
| [Obsidian Setup](docs/guide/obsidian-setup.md) | Plugin configuration and dashboards |
| [Architecture](docs/design/architecture.md) | Runtime model, skill inventory, folder structure |
| [How It Was Built](docs/how-it-was-built.md) | The Claude Code methodology behind Myna |

## Contributing

Contributing uses that same dev harness — open the repo in Claude Code and Myna helps you design, build, and review the change. Full guide: [CONTRIBUTING.md](CONTRIBUTING.md).

## Status

- **v2** — refactored as a Claude Code plugin. Install straight from the marketplace; no cloning, no shell scripts. (Kiro and other runtimes use `./install.sh`.)
- **v1** — initial release.

[MIT License](LICENSE). Actively developed; some features may not work exactly as expected yet. Myna runs only when you ask — no scheduled jobs or background watchers yet; automation (scheduled runs, email monitoring) is on the [roadmap](ROADMAP.md). Tested with Gmail, Google Calendar, and Slack MCPs.
