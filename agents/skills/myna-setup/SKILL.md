---
name: myna-setup
description: Configure Myna interactively — guided setup for identity, integrations, projects, people, and communication style. Add a project or person later, review current config, or walk through initial setup. Resumable at any point.
user-invocable: true
argument-hint: "setup | add a project | add people | review config | update communication style"
---

# myna-setup

Guided, conversational configuration for Myna. Reads and writes the same YAML files as direct editing — just a friendlier interface. Works equally well for first-time setup, adding a project later, or reviewing what's configured.

## Design Principles

1. **Priority order.** Walk through sections in order of importance: identity first, communication style last. User can stop anytime; whatever is saved so far works.
2. **Options first, free text as escape hatch.** For structured choices, present numbered options with a final "other" option for custom input. Use free text only when the answer is genuinely open-ended.
3. **Infer from data, confirm don't ask.** When users share docs, extract information from them. Show numbered results for confirmation/correction — don't interview them from scratch.
4. **Present options explicitly.** When there are multiple input modes, always show them as numbered options so the user knows what's available before choosing.
5. **Doc import is the primary path.** Users share docs (pasted text, file paths, or links); this skill extracts projects, people, timelines, and roles. If a link can't be accessed, ask the user to paste the content instead.
6. **Numbered inline corrections.** Show extracted or entered data as numbered lists. User corrects by referencing numbers ("3: remove", "4: she's tech lead not senior"). Multiple corrections in one message are fine.
7. **Batch input.** Accept multiple items at once — a list of projects, a list of people — rather than one-by-one interviews.
8. **Resumable.** On re-run, read existing config files and show what's there. Never auto-skip sections — present options so the user decides what to do: "You have 3 projects configured. Want to add more, edit existing, or move on?" The user is always in control.
9. **Never show YAML.** All data is presented as human-readable numbered lists. YAML is written behind the scenes.

---

## Section 0: Resolve Vault Path

Before anything else, resolve where config files live:

1. If running inside the `myna` agent, vault path is already in context from the agent file.
2. Otherwise, read `~/.myna/install-manifest.json` — the install script writes `vault_path` and `subfolder` there.
3. If neither exists, tell the user to run `./install.sh --vault-path <path>` first.

All config files are at `{vault_path}/{subfolder}/_system/config/`.

---

## Section 1: Status Summary

Read all six config files from `_system/config/`. Show a human-readable summary of what's configured and what's missing or blank. Always show this on every invocation, including re-runs.

If everything is populated, show the summary and offer: 1) add more projects/people, 2) edit existing config, 3) review applied defaults, 4) move on. If gaps exist, offer to fill them in priority order (identity first).

---

## Section 2: Identity and Preferences

Writes to `workspace.yaml`. Collect in two passes — essentials first, preferences after.

**Essential fields (Myna can't work without these):**
- Name (free text)
- Email (free text)
- Role (options: 1) Engineering Manager, 2) Tech Lead, 3) Senior Engineer, 4) PM, 5) Other)
- Timezone (options: list common IANA zones + "Other")

Complete essentials before moving to preferences.

**Preference fields:**
- Work hours: start/end time (options: 1) 9–5, 2) 10–6, 3) 8–4, 4) Other)
- Feedback cycle: how often to flag feedback gaps (options: 1) Every 2 weeks, 2) Monthly, 3) Quarterly, 4) Other)
- Journal archival: how long to keep daily notes before archiving (options: 1) 30 days, 2) 60 days, 3) 90 days, 4) Never)
- Email filing: how processed emails are organized (options: 1) Per-project folders, 2) One shared folder)
- Feature areas: present four areas and let the user disable any they don't need — 1) Email & messaging, 2) Meetings & calendar, 3) People & team management, 4) Personal tracking. Map the user's choices to the 17 individual toggle fields in `workspace.yaml`. Default is all enabled.

Do not ask about: `timestamp_format`, `prompt_logging`, `ai_model`, `calendar_event_prefix`, `calendar_event_types`. These are internal plumbing — keep at defaults.

---

## Section 3: Integrations

Writes to `workspace.yaml` → `mcp_servers`. Walk through the three functions Myna supports, one at a time:
- Email MCP server name
- Calendar MCP server name
- Messaging (Slack, Teams, etc.) MCP server name

Say once upfront: "Just type the MCP server name for each, or 'skip' to move on." Don't verify the server works. Don't suggest product names — just ask for the server name the user registered with Claude Code.

---

## Section 4: Projects and People

The most important section. Always present three explicit options upfront before asking anything:

1. **Share docs** — paste text, give file paths, or share links. This skill extracts projects (name, status, timeline, key people, description) and people (name, role, relationship, team). If a link can't be accessed, ask the user to paste content instead.
2. **List them** — type a batch description of projects and/or people in any format. This skill structures it and confirms.
3. **Skip for now** — come back later via `/myna-setup`.

When extracting from docs or user input, populate both `projects.yaml` and `people.yaml`. Cross-reference: people mentioned in projects get added to people config; projects mentioned for people get linked.

Show all extracted data as a **numbered human-readable list** — never as YAML. For corrections, present two options:
1. **Inline corrections** — reference by number in chat (e.g., "3: remove", "5: she's tech lead not senior"). Multiple corrections in one message are fine. Best for small batches.
2. **Export to file** — write extracted data to a human-readable file (not YAML) in the vault, let the user edit it in their editor, then read it back and confirm. Best for large batches.

Write YAML only after the user confirms. When the user provides timeline information (even rough like "Q3" or "end of May"), include it in the project description field.

Schema references: `_system/config/projects.yaml.example`, `_system/config/people.yaml.example`.

---

## Section 5: Communication Style

Writes to `communication-style.yaml`. Present numbered options for each question — always include a custom option last.

- Default writing style (options: 1) Professional, 2) Conversational, 3) Executive, 4) Casual, 5) Coaching, 6) Diplomatic, 7) Concise, 8) Custom)
- Sign-off preference (options: 1) Best, 2) Thanks, 3) Cheers, 4) Custom)
- Tone for difficult messages (options: 1) Direct-but-kind, 2) Diplomatic, 3) Straightforward, 4) Custom)

Then offer per-tier overrides (upward / peer / direct / cross-team) as an optional step — present the option but don't push if they skip.

Schema reference: `_system/config/communication-style.yaml.example`.

---

## Section 6: Optional Config

Briefly mention that `meetings.yaml` and `tags.yaml` exist for power users but most people don't need them. They can be edited directly or revisited via `/myna-setup`. Don't walk through them.

---

## Section 7: Wrap-Up

Show a final summary of everything configured in this session. Then show the defaults that were applied silently — the internal plumbing fields: `timestamp_format: YYYY-MM-DD`, `prompt_logging: true`, `ai_model: claude-code`, `calendar_event_prefix: [Myna]`, `calendar_event_types: Focus/Task/Reminder`. Let the user know these can be changed directly in `workspace.yaml` if needed. No hidden defaults.

Suggest next steps: run `myna` and type `sync` to start the day.

---

## Config Writing Rules

- Read the existing config file before writing. Preserve any fields the user didn't change.
- For `projects.yaml` and `people.yaml`: append new entries — never overwrite existing ones.
- Write valid YAML matching the schemas in `_system/config/*.yaml.example`.
- `vault.path` and `vault.subfolder` in `workspace.yaml` are set by the install script — don't ask about them, don't overwrite them.
- Internal plumbing fields — keep at defaults, never ask: `timestamp_format`, `prompt_logging`, `ai_model`, `calendar_event_prefix`, `calendar_event_types`.
- `meetings.yaml` and `tags.yaml` are not part of the guided flow — don't write them unless the user explicitly asks.
