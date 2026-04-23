# Setup Skill — Interactive Configuration Workflow

You are building `/myna-setup`, an interactive configuration skill for Myna. This skill replaces the current "edit YAML files manually" onboarding with a guided, conversational workflow that users can run anytime — first-time setup, adding a project later, or reviewing their full config.

**You are a coordinator.** Delegate each task below to a subagent, review the output, and fix issues before moving on. Do NOT attempt all tasks yourself in one pass.

## Context

Myna is a Claude Code agent (Chief of Staff for tech professionals). Skills are SKILL.md files in `~/.claude/skills/myna-*/`. The agent file is at `~/.claude/agents/myna.md`. The install script (`install.sh`) copies skills from the repo to `~/.claude/skills/` and creates the vault structure with config files at `{{VAULT_PATH}}/{{SUBFOLDER}}/_system/config/`.

There are 6 config files:
- `workspace.yaml` — user identity, role, timezone, MCP server names, feature toggles
- `projects.yaml` — active projects with aliases, email/Slack mappings, key people
- `people.yaml` — people with roles, relationship tiers, contact info
- `communication-style.yaml` — writing style presets per audience tier
- `meetings.yaml` — optional meeting type overrides (most meetings need no entry)
- `tags.yaml` — auto-tagging rules

Currently, users must edit these YAML files by hand before Myna is useful. This is too much upfront friction.

### Two paths to the same config

After this change, users have two ways to configure Myna:

1. **`/myna-setup`** — guided, conversational, resumable. The skill reads and writes the same YAML files.
2. **Edit YAML files directly** — for power users who prefer it.

Both paths produce the same config files. The skill is a convenience layer, not a gatekeeper.

## Design Principles

These are the core UX principles for the skill. The skill should describe the workflow and what to do at each step, but NOT script exact prompts or response templates — the LLM handles conversation naturally.

1. **Priority order.** Walk through sections in order of importance: identity first, communication style last. User can stop anytime; whatever is saved so far works.

2. **Options first, free text as escape hatch.** For structured choices (role, timezone, communication style), present numbered options with a final "other" option for custom input. Only use free text when the answer is genuinely open-ended (describing projects, listing people).

3. **Infer from data, confirm don't ask.** When possible, extract information from docs the user provides rather than interviewing. Show what was extracted with numbered items and ask for confirmation/corrections.

4. **Present options explicitly, then handle input naturally.** When there are multiple input modes (e.g., doc import vs batch list vs skip), always present them as numbered options so the user knows what's available — don't leave them guessing. The LLM handles the conversation within each mode naturally, but the user must see their choices upfront.

5. **Doc import is the primary path.** This is the most important input mode. Users share docs (paste text, give file paths, or drop links), and the skill extracts projects, people, timelines, and roles. The user then confirms/corrects instead of typing everything from scratch. If a link can't be accessed, ask the user to paste the content instead.

6. **Numbered inline corrections.** When showing extracted or entered data for review, number each item. User corrects by referencing the number (e.g., "3: remove", "4: she's tech lead").

7. **Batch input.** Let users enter multiple items at once — a list of projects, a list of people — rather than one-by-one interviews.

8. **Resumable.** On re-run, read existing config files and show what's there. Don't auto-skip sections — present options so the user decides what to do: "You have 3 projects configured. Want to add more, edit existing, or move on?" The user is always in control.

9. **Right level of detail in the SKILL.md.** The skill should describe each workflow section in 3-5 sentences: what data to collect, what options to present, what config file to write. It should NOT include scripted prompts, exact response templates, or conversation choreography. Here's what the right level looks like for one section:

    > **Identity.** Collect name (free text), email (free text), role (options: Engineering Manager, Tech Lead, Senior Engineer, PM, other), and timezone (options: common IANA zones + other). Write to `workspace.yaml` → `user` and `timezone` fields. These are the only fields that block Myna from working — complete this section before moving on.

    That's it — what to collect, what format (options vs free text), where to write. No "say this to the user" scripting.

10. **Never show YAML to the user.** All data is presented as human-readable numbered lists. YAML is written behind the scenes. YAML files exist for power users who choose to edit outside of setup — the setup flow itself is YAML-free.

11. **One instruction for repeated patterns.** Instead of repeating "skip if none" on every question, say it once at the start of a section (e.g., "Just type the MCP server name for each, or 'skip' to move on.").

## Workflow Sections (in order)

### Section 0: Resolve Vault Path

The skill must work from any Claude Code session, not just the `myna` agent. Resolve the vault path in this order:
1. If running inside the `myna` agent, the vault path is already in context from the agent file.
2. Otherwise, read `~/.myna/install-manifest.json` — the install script writes `vault_path` and `subfolder` there.
3. If neither exists, tell the user to run the install script first.

Once resolved, all config files are at `{vault_path}/{subfolder}/_system/config/`.

### Section 1: Status Summary

On every invocation, read all config files from `_system/config/`. Show a summary of what's configured and what's missing. If everything is populated, show the summary and offer edit/add/review options. If gaps exist, offer to fill them.

### Section 2: Identity and Preferences

Collect for `workspace.yaml`. Split into essential (ask first) and preferences (ask after):

**Essential (Myna can't work without these):**
- Name (free text)
- Email (free text)
- Role (options: Engineering Manager, Tech Lead, Senior Engineer, PM, other)
- Timezone (options: common IANA zones + other)

**Preferences (have sensible defaults, but worth asking):**
- Work hours — start/end time (options: 9-5, 10-6, 8-4, other)
- Feedback cycle — how often to flag feedback gaps (options: every 2 weeks, monthly, quarterly, other)
- Journal archival — how long to keep daily notes before archiving (options: 30 days, 60 days, 90 days, never)
- Email filing — how processed emails are organized (options: per-project folders, one shared folder)
- Feature areas — Myna can manage email, meetings, people/team, and personal tracking. Present these areas and let the user disable any they don't need. This covers the 17 individual feature toggles in `workspace.yaml` without asking about each one. Map the user's choices to the specific toggle fields.

Don't ask about internal plumbing: `timestamp_format`, `prompt_logging`, `ai_model`, `calendar_event_prefix`, `calendar_event_types`. These stay at defaults.

### Section 3: Integrations (MCP Servers)

Collect MCP server names for `workspace.yaml` → `mcp_servers`. Walk through the functions Myna supports. Set up with one instruction: "Just type the MCP server name for each, or 'skip' to move on."

Functions to ask about (one at a time, rapid-fire):
- Email
- Calendar
- Messaging (Slack, Teams, etc.)

Don't verify if the MCP works — trust what the user provides. Don't offer predefined product options (Gmail, Google Calendar, etc.) — Myna doesn't have built-in support for specific products. Just ask for the server name.

### Section 4: Projects and People (Discovery)

This is the most important section. Present the user with explicit options for how to provide this data:

1. **Share docs** — paste text, give file paths, or drop links. Myna reads the docs and extracts projects (name, status, timeline, key people, description) and people (name, role, relationship, team). Then shows numbered results for confirmation/correction. If a link can't be accessed, ask user to paste content instead.
2. **List them** — user types a batch description of projects and/or people in any format. Myna structures it and confirms.
3. **Skip for now** — come back later via `/myna-setup`.

The user must see these options — don't just ask an open-ended question and hope they know what's possible.

When extracting from docs or user input, populate both `projects.yaml` and `people.yaml`. Cross-reference: people mentioned in projects get added to people config, projects mentioned for people get linked.

Always show extracted data as a **human-readable numbered list**, never as YAML. The user should never see YAML during the setup flow.

For corrections, present two options:
1. **Inline corrections** — reference by number in chat (e.g., "3: remove", "5: she's tech lead not senior"). Multiple corrections in one message are fine. Best for small batches.
2. **Export to file** — write the extracted data to a human-readable file (not YAML) in the vault, let the user edit it in their editor, then read it back and confirm. Best when there are many items to review.

The skill writes YAML behind the scenes after the user confirms.

When the user provides timeline information (even rough like "Q3" or "end of May"), include it in the project description field.

### Section 5: Communication Style

Collect for `communication-style.yaml`. Present numbered options for each question (always include a "custom" option last):
- Default writing style — 7 presets: professional, conversational, executive, casual, coaching, diplomatic, concise + custom
- Sign-off preference — Best, Thanks, Cheers + custom
- Tone for difficult messages — direct-but-kind, diplomatic, straightforward + custom

Then offer per-tier overrides (upward/peer/direct/cross-team) as an optional step — present the option but don't push if they skip.

### Section 6: Optional Config

Briefly mention that `meetings.yaml` and `tags.yaml` exist for power users but most people don't need them. Don't walk through them — just note they can be edited directly or configured later via `/myna-setup`.

### Section 7: Wrap-Up

Show final summary of everything configured. Then show the defaults that were applied without asking — the internal plumbing fields (`timestamp_format: YYYY-MM-DD`, `prompt_logging: true`, `ai_model: claude-code`, `calendar_event_prefix: [Myna]`, `calendar_event_types: Focus/Task/Reminder`). Let the user know these exist and can be changed in `workspace.yaml` directly if needed. No hidden defaults.

Suggest next steps (e.g., "run `myna` and type 'sync' to start your day").

## Config Writing Rules

- Read the existing config file before writing. Preserve any fields the user didn't change.
- For `projects.yaml` and `people.yaml`: append new entries, don't overwrite existing ones.
- Write valid YAML. Use the schemas from the `.example` files in `_system/config/`.
- The `vault.path` and `vault.subfolder` fields in `workspace.yaml` are set by the install script — don't ask about them, don't overwrite them.
- These `workspace.yaml` fields are internal plumbing — don't ask, keep defaults: `timestamp_format`, `prompt_logging`, `ai_model`, `calendar_event_prefix`, `calendar_event_types`.
- `meetings.yaml` and `tags.yaml` are auto-generated based on projects and people if the user doesn't customize them. Don't include in the guided flow.

## Config File Schemas

The skill must write YAML that matches these schemas exactly.

### workspace.yaml

```yaml
user:
  name: ""
  email: ""
  role: ""   # engineering-manager | tech-lead | senior-engineer | pm

vault:
  path: ""          # Set by install script — don't change
  subfolder: myna   # Set by install script — don't change

timezone: ""        # IANA format, e.g. America/Los_Angeles

work_hours:
  start: "09:00"   # Asked during setup
  end: "17:00"

feedback_cycle_days: 30   # Asked during setup

journal:
  archive_after_days: 30  # Asked during setup

email:
  processed_folder: per-project  # Asked during setup: per-project | common
  common_folder: "Processed/"

mcp_servers:
  email: ""       # MCP server name for email, or empty
  slack: ""       # MCP server name for messaging, or empty
  calendar: ""    # MCP server name for calendar, or empty

features:              # Asked during setup as grouped feature areas
  email_processing: true
  messaging_processing: true
  email_triage: true
  meeting_prep: true
  process_meeting: true
  time_blocks: true
  calendar_reminders: true
  people_management: true
  self_tracking: true
  team_health: true
  attention_gap_detection: true
  feedback_gap_detection: true
  contribution_detection: true
  milestones: true
  weekly_summary: true
  monthly_updates: true
  park_resume: true

# Internal plumbing (don't ask): timestamp_format, prompt_logging, ai_model,
# calendar_event_prefix, calendar_event_types
```

### projects.yaml

```yaml
projects:
  - name: ""              # Display name
    aliases: []           # Short names
    status: active        # active | paused | complete
    email_folders: []     # Email folders mapped to this project
    slack_channels: []    # Slack channels mapped to this project
    description: ""       # Brief description, may include timeline
    key_people: []        # People involved (full names)
```

### people.yaml

```yaml
people:
  - display_name: ""        # How user refers to them
    full_name: ""           # Full name for matching
    aliases: []             # Short names
    email: ""               # Email address
    slack_handle: ""        # Slack username
    relationship_tier: ""   # direct | peer | upward | cross-team
    role: ""                # Their role/title
    team: ""                # Their team
```

### communication-style.yaml

```yaml
default_preset: professional  # professional | conversational | executive | casual | coaching | diplomatic | concise

presets_per_tier:
  upward: ""
  peer: ""
  direct: ""
  cross-team: ""

sign_off: ""
difficult_message_approach: ""  # direct-but-kind | diplomatic | straightforward

email_preferences:
  max_length: ""          # short | medium | long
  greeting_style: ""      # first-name | formal | none

messaging_preferences:
  formality: ""           # casual | professional
  emoji_usage: ""         # none | minimal | moderate
```

---

## How to execute

### Read context first

Before spawning any subagent, read these files yourself:
- `CLAUDE.md`
- `agents/main.md`
- `install.sh`
- `agents/config-examples/workspace.yaml.example`
- `agents/config-examples/projects.yaml.example`
- `agents/config-examples/people.yaml.example`
- `agents/config-examples/communication-style.yaml.example`
- One existing feature skill for format reference: `agents/skills/myna-capture/SKILL.md`

### Task 1: Create the `/myna-setup` skill

**File:** `agents/skills/myna-setup/SKILL.md`

Create the skill file following the format of existing skills (frontmatter with name, description, user-invocable, argument-hint, then markdown body).

The skill body should:
- Describe the workflow sections and what data to collect at each step
- Specify what config files to read and write
- Include the design principles (summarized, not the full text above)
- NOT include scripted prompts, exact wording, or conversation templates
- NOT include step-by-step conversation choreography
- Be concise — trust the LLM to handle natural conversation

The frontmatter should have:
- `name: myna-setup`
- `description:` — clear description covering: configure Myna, guided setup, add projects/people/integrations, review current config, resumable
- `user-invocable: true`
- `argument-hint:` — examples like "setup", "add a project", "review config"

**Review criteria:**
- [ ] Frontmatter is valid and matches existing skill format
- [ ] All 7 workflow sections are covered
- [ ] Each section is 3-5 sentences describing what to collect, what options to present, where to write — not scripted dialogue
- [ ] Config schemas are referenced (point to .example files, don't duplicate full schemas in the skill)
- [ ] Doc import flow is described clearly as the primary path for projects/people
- [ ] All choice points present explicit numbered options to the user
- [ ] Correction flow offers two options: inline by number (small batches) and export to human-readable file (large batches)
- [ ] Resumable behavior: reads existing config, shows what's there, asks user what to do (add/edit/move on) — never auto-skips
- [ ] Config writing rules are included (preserve existing, append don't overwrite, valid YAML)
- [ ] Vault path resolution is described — works from myna agent OR any Claude Code session via `~/.myna/install-manifest.json`
- [ ] Identity section includes both essentials (name, email, role, timezone) and preferences (work hours, feedback cycle, archive days)
- [ ] Internal plumbing fields are explicitly listed as "don't ask"

### Task 2: Update `install.sh`

Two changes to the install script:

**Change 1:** Update the starter config files to include a setup reference comment at the top.

For every config file created by the install script (workspace, projects, people, meetings, communication-style, tags), the first line should be:
```
# Run /myna-setup for guided configuration.
```

This replaces the current header comments in the starter configs. Keep the rest of the starter content (empty structures, vault path, etc.) but replace verbose header comments with just the one-liner.

For `workspace.yaml` specifically: keep the structural content (user fields, vault fields, etc.) since those are needed as placeholders, but replace the header comment.

**Change 2:** Update the "Next steps" output at the end of the install script.

Replace the current next steps (which tell users to edit config files manually) with:
```
Next steps:

  1. Launch Myna:
     myna  (after reloading your shell)
     claude --agent myna  (immediately)

  2. Run /myna-setup for guided configuration
     Or edit config files directly:
     $EDITOR $CONFIG_DIR/workspace.yaml

  The cloned repo is no longer needed at runtime.
  To update: git pull && ./install.sh --vault-path $VAULT_PATH
```

**Review criteria:**
- [ ] Every starter config file starts with `# Run /myna-setup for guided configuration.`
- [ ] `workspace.yaml` starter still has the structural content (user, vault, mcp_servers, features, etc.)
- [ ] Other starter configs still have their empty structures (e.g., `projects: []`)
- [ ] Next steps output is updated, concise, and mentions both paths (setup skill and manual edit)
- [ ] Script still passes `bash -n install.sh`
- [ ] No existing functionality broken

### Task 3: Update `agents/main.md` — Session Start

Update the session start behavior in `agents/main.md`. Currently step 3 says:

> Greet the user by name. If config files are missing, tell them to run the install script or create configs from the `.example` files.

Change this to:

> Greet the user by name. If `workspace.yaml` has empty identity fields (name, email, or role are blank), suggest running `/myna-setup` for guided configuration.

This is a minimal change — just update the one sentence about missing config behavior.

**Review criteria:**
- [ ] Only the missing-config sentence in step 3 was changed
- [ ] References `/myna-setup` not the install script for config
- [ ] Rest of `agents/main.md` is completely untouched

### Task 4: Update docs

Update `README.md` — find the setup/configuration section and mention `/myna-setup` as the recommended way to configure, with manual YAML editing as an alternative for power users. Brief — 2-3 sentences.

Update `docs/post-install-checklist.md` — replace references to manual YAML editing as the primary path with `/myna-setup`, keeping manual editing as an option.

**Review criteria:**
- [ ] README mentions `/myna-setup` in the right place
- [ ] Post-install checklist updated
- [ ] Both changes are brief and match existing tone
- [ ] No existing content accidentally removed

---

## Execution order

```
Phase 1: Read all context files
Phase 2: Task 1 (create skill) — this is the main deliverable
Review Task 1
Phase 3 (parallel): Task 2 (install.sh) + Task 3 (main.md) + Task 4 (docs)
Review Phase 3
Final: bash -n install.sh
```

## Commit and push

After all quality checks pass:

1. Create a new branch: `feat/myna-setup-skill`
2. Stage all changed files including `docs/prompts/setup-skill.md` (this prompt file)
3. Commit with message: `feat(setup): add /myna-setup skill for guided interactive configuration`
4. Push the branch to origin
