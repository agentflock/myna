# Instructions: Requirements Phase

Read this when discussing or writing requirements.

## How to Work During Requirements

- **When a decision is made** → write it to `docs/decisions.md` immediately.
- **When an open question surfaces** → add it to `docs/open-questions.md` immediately.
- **When requirements are discussed** → write them to the appropriate `docs/requirements/*.md` file. Don't wait to be asked.
- **When the vision needs updating** → update `docs/vision.md` directly.
- **When something notable happens** → write to `docs/dev-journal.md`.

**The principle:** The user reviews your work, not your notes. If it was discussed and agreed upon, it should already be written to the right file.

## How to Write Requirements

Requirement files must be detailed enough for Claude to **autonomously design and build** the system without asking clarifying questions. Every requirement should answer: what does this do, how does the user trigger it, what happens step by step, where does data go, and how do we know it works?

### Structure for each feature/capability:

```markdown
### [Feature Name]

**What it does:** One sentence summary.

**How the user triggers it:** The natural language prompts that invoke this feature.
Example: "triage my inbox", "prep brief for my 1:1 with Sarah"

**Step-by-step behavior:**
1. What the agent reads (which files, which MCP data)
2. What the agent does with that data (extract, summarize, classify, etc.)
3. What the agent writes and where (which vault files, what format)
4. What the agent shows the user (inline output, confirmation, etc.)

**Output format:** What the output looks like — structure, sections, markdown format.

**Data flow:**
- Reads from: [sources — vault files, MCP tools, config]
- Writes to: [destinations — vault paths, review queue, inline output]
- Triggers: [other features or flows this connects to, if any]

**Edge cases:**
- What happens when data is missing (e.g. no emails, no person file)
- What happens when references are ambiguous
- What happens when an MCP is unavailable

**Acceptance criteria:**
- [ ] Specific, testable conditions that must be true when this feature works correctly
- [ ] Include both happy path and edge cases
- [ ] Include what must NOT happen (e.g. "never writes outside myna/")

**Dependencies:** Other features, config fields, or MCP tools this requires.
```

### Guidelines:
- **Be specific about file paths.** "Writes to the project file" is not enough. "Appends to `myna/Projects/{project-name}.md` under the Timeline section" is.
- **Be specific about formats.** Show the actual markdown format for tasks, timeline entries, observations, etc.
- **Be specific about config.** If a feature reads from config, name the config field.
- **Don't leave design decisions open.** If you're unsure about something, discuss it with the user and decide — don't write "TBD" or "to be determined."
- **Include the review queue flow** for any feature that stages items. Specify what goes to review queue vs. what gets written directly.
- **Cross-reference other domains.** If this feature creates data that another domain consumes, say so explicitly.
