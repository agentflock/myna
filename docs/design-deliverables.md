# Design Deliverables

What the design phase must produce before build starts. Claude should not begin implementation until all items here are complete and approved.

---

## Vault Structure
- [ ] Complete folder tree under `myna/` (every path, every file)
- [ ] Template content for every file type (daily note, project, person, meeting, etc.)
- [ ] Dashboard files with Dataview queries
- [ ] Review queue file format and structure

## Config System
- [ ] Schema for each config file (workspace, registry, communication style)
- [ ] `.example` content for each config file
- [ ] Config validation rules (what's required vs optional, defaults)
- [ ] How config maps MCP connection names to domains

## Agent Instructions
- [ ] Architecture for how agent instructions are structured (single file? per-domain? per-feature?)
- [ ] Common instruction layer (shared across all AI models)
- [ ] Model-specific adaptation layer (how setup generates model-specific config)
- [ ] How agent instructions reference MCP tools and vault paths

## Obsidian CLI MCP
- [ ] Tool definitions (name, parameters, return format for each tool)
- [ ] Mapping from MCP tools to Obsidian CLI commands
- [ ] Fallback behavior when Obsidian isn't running
- [ ] Error handling for each tool

## Data Flows
- [ ] Cross-domain data flow diagram (what feeds into what)
- [ ] Review queue lifecycle (how items enter, get processed, and route to destinations)
- [ ] How batch triage works (inbox/channel → project sorting)

## Setup Flow
- [ ] Interactive setup conversation script (what questions, what order)
- [ ] What config gets written at each step
- [ ] Minimum viable setup (what's needed to start using Myna)
- [ ] Power user path (direct config file editing)

## Per-Domain Design
- [ ] Email & Messaging — processing pipeline, extraction logic
- [ ] Meetings & Calendar — note lifecycle, brief/debrief flows
- [ ] Projects & Tasks — task format, timeline format, context switching
- [ ] People Management — person file lifecycle, observation/feedback flow
- [ ] Daily Workflow — daily note lifecycle, planning logic, sync flow
- [ ] Writing & Drafts — draft storage, rewrite modes, style application
- [ ] Self Tracking — contribution extraction, brag doc generation
