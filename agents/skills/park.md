# Park

## Purpose

Save your current working context so a new session can resume with zero context loss. The parked file must be detailed enough that a brand new agent session can pick up exactly where you left off.

## Triggers

- "park this", "park: auth migration discussion"
- "resume auth migration", "resume" (shows list of parked items)
- "switch to [project]" (parks current context, then loads project status)
- "what's parked?", "show parked items"

## Inputs

- Current conversation context (topics discussed, files referenced, decisions made)
- Vault files referenced during the conversation
- `_system/parked/` — existing parked context files
- Project files under `Projects/` (for "switch to" command)

## Procedure

### Park

1. Gather context from the current conversation:
   - **Topic:** determine a clear topic name and one-line summary
   - **Referenced files:** every vault file read or written during this conversation, with a note on why each was relevant
   - **Discussion summary:** what was explored, what was considered and rejected, what was decided and why. Be thorough — vague summaries defeat the purpose.
   - **Current state:** exactly where work stopped, what was in progress, what was half-done
   - **Next steps:** what was about to happen next, detailed enough to start immediately
   - **Open questions:** anything unresolved that needs user input
   - **Key constraints:** decisions or constraints that shaped the work, so the next session doesn't re-debate them

2. Generate the topic slug from the topic name (lowercase, hyphens for spaces).

3. Check if `_system/parked/{topic-slug}.md` already exists. If it does, ask the user: "A parked file for '{topic}' already exists. Update it, or park as a new topic?"

4. Write to `_system/parked/{topic-slug}.md`:
   ```
   ---
   parked: {YYYY-MM-DD HH:MM}
   topic: {topic name}
   ---

   ## Summary

   {One-line summary of what you were doing.}

   ## Referenced Files

   - [[{file-1}]] — {why relevant}
   - [[{file-2}]] — {why relevant}

   ## Discussion Summary

   {Full summary: what was explored, considered and rejected, decided and why.}

   ## Current State

   {Exactly where you stopped. What was in progress, half-done.}

   ## Next Steps

   {What you were about to do next, in enough detail to start immediately.}

   ## Open Questions

   {Anything unresolved.}

   ## Key Constraints

   {Decisions or constraints that shaped the work.}
   ```

5. Confirm: "Parked '{topic}'. Resume with 'resume {topic}'."

### Resume

1. If the user specifies a topic ("resume auth migration"): resolve the topic name against filenames in `_system/parked/` using prefix and fuzzy matching. If multiple matches, list them and ask the user to pick.

2. If the user says just "resume" with no topic: list all parked items with their topic name, one-line summary, and parked date. Wait for the user to pick one.

3. Read the parked file. Present a summary:
   - What you were working on (topic + summary)
   - Where you left off (current state)
   - What's next (next steps)
   - Any open questions

4. The session continues from the next steps. The parked file stays on disk until the user explicitly says to delete or archive it.

### Switch

"switch to [project]" combines parking with project loading:

1. Park the current conversation context (follow the Park procedure above).
2. Read the target project file under `Projects/` (resolve project name via fuzzy matching against projects.yaml).
3. Present a quick project summary: overview, last 3-5 timeline entries, open tasks count, any active blockers. This is a quick orientation — not a full project brief.
4. The session continues in the context of the new project.

### List

"what's parked?" or "show parked items":

1. Read all files in `_system/parked/`.
2. For each, show: topic name, one-line summary, parked date.
3. If no parked items exist, say so.

## Output

- `_system/parked/{topic-slug}.md` — parked context files (created or updated)
- Inline summary when resuming
- Inline list when showing parked items

## Rules

- **Detail is the point.** A parked file that says "we were discussing auth caching" is useless. The file must contain enough detail that a fresh agent session needs zero additional context from the user to continue.
- **Never auto-delete parked files.** Only remove when the user explicitly says "delete parked auth caching" or "clean up parked items." When work on a parked topic is complete, the user can archive or delete the file.
- **Multiple parked items are fine.** Users may have several concurrent threads of work.
- **Check `features.park_resume`** before acting. If disabled, inform the user and stop.
- **Wiki-links in Referenced Files must point to real files.** Verify each file exists before linking. If a file was discussed but doesn't exist in the vault, note the path without a wiki-link.

## Examples

### Park

User has been discussing auth caching design for 20 minutes. Says "park this."

Read conversation context: discussed 3 caching approaches (Redis, Memcached, in-memory with TTL), rejected Redis (too much infra overhead for v1), leaning toward in-memory with TTL. Referenced auth-migration project file and Sarah's person file (she's writing the spec). Waiting on Sarah's spec before finalizing.

Write to `_system/parked/auth-caching-design.md` with all sections filled:
- Summary: Designing the caching layer for auth migration service
- Referenced Files: [[auth-migration]] (API spec due Friday), [[sarah-chen]] (writing caching spec)
- Discussion Summary: Evaluated Redis (rejected — infra overhead), Memcached (considered — marginal benefit over Redis), in-memory with TTL (preferred — zero deps, natural token expiry). Concern: memory pressure at >50k unique tokens, mitigated by LRU.
- Current State: Approach selected but not finalized, waiting on Sarah's spec
- Next Steps: (1) Review Sarah's spec, (2) validate memory assumptions, (3) draft technical design, (4) share with Platform team
- Open Questions: Production token cardinality? Cache warming strategy?
- Key Constraints: No external infra in v1, must prevent stale cache hits

Output: "Parked 'Auth Caching Design'. Resume with 'resume auth caching'."

### Resume

User: "resume auth caching"

Match "auth caching" to `_system/parked/auth-caching-design.md`.

Output:
> **Resuming: Auth Caching Design**
>
> You were designing the caching layer for auth migration. Evaluated Redis (rejected — too much infra), Memcached (considered), and in-memory with TTL (preferred). Waiting on Sarah's caching spec (due Friday) before finalizing.
>
> **Next:** Review Sarah's spec, validate memory pressure assumptions, draft the technical design doc.
>
> **Open questions:** Production token cardinality numbers, cache warming strategy.
>
> Ready to continue.
