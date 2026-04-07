# System

## Feature Toggle Checking

Every feature has a toggle in `workspace.yaml` under the `features` map. Before any feature-specific behavior, check its toggle.

- Disabled features are **silently skipped** — not mentioned, not suggested, not included in output (daily notes, dashboards, briefings).
- Skills that cover multiple features check each feature's toggle independently. A skill can have some features active and others inactive.
- If a feature toggle is missing from config, treat it as enabled (default on).

## Config Loading

Six YAML config files under `_system/config/` are read at session start:

- `workspace.yaml` — user identity, preferences, feature toggles, MCP server names
- `projects.yaml` — project registry, email/Slack mappings, triage config
- `people.yaml` — person registry, relationship tiers, aliases
- `meetings.yaml` — meeting type overrides
- `communication-style.yaml` — writing style preferences per audience tier
- `tags.yaml` — auto-tagging rules

Config files are read once at session start, not on every prompt. Manual edits by the user take effect next session.

If a config file is missing, degrade gracefully — use defaults where possible, inform the user what's missing if a feature requires it.

## Graceful Degradation

External MCP servers (email, Slack, calendar) may not be configured or may be unavailable. When an external MCP is unavailable:

- Skip features that depend on it.
- Inform the user which data source was unavailable and what was excluded.
- Continue processing with whatever sources are accessible — never fail entirely because one source is missing.
- Features that work without external MCPs (vault queries, capture, park, calendar task breakdown) remain fully functional.

## Error Recovery

When a multi-step operation partially fails, report what succeeded and what failed. If the failure is something the user would want to retry, create a retry TODO:

```
- [ ] 🔄 Retry: {what failed and why} [type:: retry] [created:: {date}]
```

Retry TODOs surface in the daily note Immediate Attention section so they are not lost.

Never silently swallow errors. If an email fails to move, a file fails to write, or an MCP call times out, report it explicitly.

## Relative Date Resolution

"By Friday", "next week", "in 3 days", "tomorrow" — resolve to actual dates using the `timezone` field from `workspace.yaml`. Always store the resolved absolute date in vault entries, never the relative reference.

If `timezone` is not configured, fall back to the system timezone.

## Prompt Logging

If `prompt_logging` is enabled in `workspace.yaml` (default: true), append each user prompt to `_system/logs/prompts.md` with a timestamp. Format:

```
- [{YYYY-MM-DD HH:MM}] {user prompt text}
```

If `prompt_logging` is disabled, skip logging silently.

## Fuzzy Name Resolution

When the user references a project, person, or meeting by a partial or informal name, resolve using this cascade:

1. Exact match against names in config
2. Alias match against configured aliases
3. Case-insensitive match
4. Prefix match
5. Fuzzy/partial match

**Outcomes:**
- Single match: proceed silently.
- Multiple matches: list options, ask the user to pick. Never guess.
- No match: ask for clarification, suggest closest matches.
