# Changelog

All notable user-facing changes to Myna will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- Added: vault-native day-level reminders via /myna:reminder — "remind me on [day] about [X]" surfaces in the daily brief, with an optional calendar notification
- Added: process-instructions skill — send instructions to Myna via email or Slack and they're executed automatically
- `daily-brief` now reads email and Slack during morning setup — spawns parallel subagents to fetch and classify inbox items into Action Required, FYI, and not-surfaced tiers. Results appear in new `### Emails` and `### Slack` subsections within the daily note's Sync block, with urgent items surfaced in `### Briefing` as well. Requires email and Slack MCPs; degrades gracefully if unavailable.
- `review-doc` skill — multi-persona doc review with Chief-of-Staff context layer; supports PRFAQ, design doc/RFC, HLD, LLD, one-pager, and generic doc types. Results saved to `Reviews/`.
- Reviewer subagent primitives — 11 input-agnostic persona subagents at `agents/myna-reviewer-*.md` (PE, Sr SDE, SRE, Security, QA, Product Leader, PM, Customer Skeptic, Skeptic, Decision-Maker, Writer/Editor). Available for cross-skill orchestration via the Task tool.
- `Reviews/` and `Reviews/sources/` vault folders — created by the install script. `Reviews/` holds doc review reports; `Reviews/sources/` preserves verbatim source text for paste-type reviews.
- [Added] process-meeting now handles meetings without prep — pass rough notes directly or process a meeting file that has no Prep section
- Install script for Kiro (`install/kiro.sh` + `install/lib.sh`). Ports Myna's skills to
  Kiro by transforming frontmatter and scaffolding the vault. Refactors `install/claude.sh`
  to share vault setup logic via `install/lib.sh`.

### Changed

- [Changed] Email triage now flags emails with past deadlines (⚠️ Deadline passed) and uses "Action Required" instead of "Reply" as the default folder name
- `daily-brief` now renders Today's Meetings as a table with a dedicated, linked Prep column (meeting-file wikilink) instead of inline checkbox bullets, and surfaces the day's largest free block as a Briefing line when meetings fragment the day.

### Removed

- Learn skill (`/myna:learn`) and emergent memory system. Memory routing now defers to Claude's native memory — say "remember this" and Claude handles it directly without a vault skill.

### Fixed

- Fixed Config UI edits not taking effect until session restart — config now reloads automatically after setup and on "reload config"

### Changed

- Changed: process-messages renamed to process-updates for clarity
- Changed: draft-replies replaced by process-instructions; config key triage.draft_replies_folder replaced by instructions.email_folder and instructions.slack_channel
- Changed: Slack dedup moved from _system/logs/processed-channels.md to _system/state/slack-sync.yaml
- `sync` skill renamed to `daily-brief` (`/myna:daily-brief`). Routing triggers updated; "daily brief" added as a new trigger phrase. Skill behavior is unchanged for vault-scan, calendar, and task data.
- [Changed] process-meeting normalizes grammar and expands shorthand in tasks and decisions; preserves close-to-verbatim wording for observations and personal notes
- Weekly summary output now opens with a narrative summary lead-in synthesizing the week's headline before the breakdown sections. Cleaned up several stale UI and doc references to removed features (prompt logging, delegation/dependency task types, worked examples).
- Removed prompt_logging config — redundant with Claude Code conversation history and unreliable as a steering-skill instruction
- Removed the feature-toggle system. Myna now ships an always-on skill set; the `features:` block in workspace.yaml, the Features tab in the Config UI, and the agent's pre-dispatch toggle check are gone. Explicit invocation controls what runs; MCP and data availability drive degradation.
- Journal folder now shows only the current daily, weekly, and monthly note — older notes move to archive automatically when new ones are created
- [Fixed] Team health is now available to any role with direct reports — no longer restricted to Engineering Manager
- Customization override model: per-skill overrides now live at `~/.myna/overrides/skills/myna-{skill-name}.md` and routing overrides at `~/.myna/overrides/routing.md`, replacing the `CUSTOM.md` and `custom-routing.md` files from v1.0.0. Users who set up customizations under the old model will need to migrate their files to the new paths.

## [1.0.0] — 2026-04-25

### Added

- 24 feature skills covering the full Chief of Staff workflow: email triage, message processing, draft replies, meeting prep and processing, project and person briefings, team health, 1:1 analysis, unreplied thread tracking, blocker scanning, performance narrative, drafting, rewriting, quick capture, calendar time blocks, self-tracking, context parking, and review queue processing.
- 6 steering skills loaded at session start: safety and containment, data conventions, output quality, system behavior, memory model, and vault operations. These enforce cross-cutting rules (draft-never-send, vault-only writes, provenance markers, append-only discipline) without repeating them in every feature skill.
- Install script (`install.sh`) that copies skills to `~/.claude/skills/`, generates the agent file at `~/.claude/agents/myna.md`, and creates the vault folder structure with config stubs.
- Vault templates for all entity types: daily note, weekly note, project, person, 1:1 meeting, recurring meeting, ad-hoc meeting, draft, review queue, contributions, and dashboard.
- Config file system: `workspace.yaml` (identity, preferences, feature toggles), `projects.yaml`, `people.yaml`, `meetings.yaml`, `communication-style.yaml`, `tags.yaml`. All config is human-editable YAML; `.example` files ship with the repo.
- Customization layer: `CUSTOM.md` in the vault for user-specific routing overrides and behavior tweaks without editing core skill files. Custom skill namespacing so user-built skills coexist with Myna skills without naming conflicts.
- Config UI skill (`myna-config-ui`) for visual setup of workspace.yaml and related config files — guided prompts, validation, and inline explanations.
- Guided onboarding skill (`myna-setup`) that walks new users through vault creation, config file setup, and a first sync — zero manual file editing required to get started.
