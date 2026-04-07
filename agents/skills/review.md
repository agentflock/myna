# Review

## Purpose

Process review queue items — the last-resort bucket for entries the agent couldn't confidently write directly. Most vault writes skip the queue entirely; this skill handles the few that need human judgment.

## Triggers

- "review my queue", "what's in my queue?"
- "process review queue", "process approved items", "process my queue"
- "show me review items", "anything to review?"

## Inputs

- `ReviewQueue/review-work.md` — ambiguous tasks, decisions, blockers, delegations, timeline entries
- `ReviewQueue/review-people.md` — ambiguous observations, recognition
- `ReviewQueue/review-self.md` — uncertain contribution candidates
- Destination files referenced in each queue entry's "Proposed destination" field

## Procedure

### 1. Read and Count

Read all three queue files. Count pending items (unchecked entries) per file. If all queues are empty, tell the user and stop.

### 2. Determine Interaction Mode

Two modes based on how the user invokes:

**Chat mode** — user says "review my queue", "what's in my queue?", or similar:

1. Present a summary: "{N} items across {M} queues. review-work: {n}, review-people: {n}, review-self: {n}."
2. Present items one at a time or in small batches. For each item show:
   - The proposed action (bold heading from the entry)
   - Source reference
   - What's ambiguous and why
   - Proposed destination
3. For each item, accept one of four actions:
   - **Approve** — write to the proposed destination with [Verified] tag
   - **Edit** — user modifies the content or destination, then approve
   - **Skip** — leave in the queue for later
   - **Discard** — remove without writing anywhere
4. After the user responds (e.g., "approve 1, discard 2, skip the rest"), execute all actions in batch.

**File mode** — user says "process my queue", "process approved items":

1. Read queue files looking for checked items (entries where `- [ ]` has been changed to `- [x]`).
2. For each checked item, use the content as-is — the user may have edited the text or destination in Obsidian before checking. The checked version is authoritative.
3. Write each checked item to its proposed destination with [Verified] tag.
4. Leave unchecked items in the queue untouched.

### 3. Write Approved Items

For each approved or checked item:

1. Read the destination file to confirm it exists. If the file doesn't exist, report it and skip the item.
2. Append the entry to the appropriate section in the destination file, using the entry's content with [Verified] replacing the original provenance marker.
3. Remove the entry from the active queue file.
4. Append an audit record to `ReviewQueue/processed-{YYYY-MM-DD}.md` (today's date) with the original entry text, the action taken, and the destination.

### 4. Report

Summarize what was done: "{N} items approved and written, {M} discarded, {K} remaining in queue." Include file links for each destination written to.

## Output

- Destination vault files receive new entries with [Verified] tag
- `ReviewQueue/processed-{YYYY-MM-DD}.md` — audit trail of all processed items
- Active queue files have processed entries removed
- Inline summary to the user

## Rules

- **review-triage is NOT handled by this skill.** Triage queue processing is part of the triage skill. This skill only processes review-work, review-people, and review-self.
- **Never auto-approve.** Every item requires explicit user action (check in Obsidian, or approve in chat).
- **[Verified] replaces the original marker.** An item that was [Inferred] becomes [Verified] after approval. Include a note: `(was Inferred, confirmed {date})`.
- **Append-only at destinations.** When writing to a destination file, append to the correct section. Never modify existing content in the destination.
- **Discarded items still get audit records.** Log discards to the processed file with action "discarded" so there's a trail.
- **If a queue file doesn't exist,** skip it silently — the user may not have any items in that category.
- **Check `features.self_tracking`** before processing review-self items. If disabled, skip review-self and note it.

## Examples

### Chat Mode

User: "review my queue"

Read queues: review-work has 3 items, review-people has 1, review-self has 1.

Output:
> 5 items across 3 queues. review-work: 3, review-people: 1, review-self: 1.
>
> **review-work (1/3):** Task "review caching approach" — can't determine owner.
> Source: email from Alex, 2026-04-03.
> Ambiguity: Email says "we should review this" — unclear if assigned to you or Alex.
> Proposed destination: Projects/platform-api.md, Open Tasks section.
>
> **review-work (2/3):** Timeline entry — conflicting signals on auth migration status.
> Source: email from Sarah, 2026-04-04.
> Ambiguity: Subject says "on track" but body mentions two unresolved blockers.
> Proposed destination: Projects/auth-migration.md, Timeline section.
>
> (3 more items in review-people and review-self.)
>
> Approve, edit, skip, or discard each?

User: "approve 1, assign to me. discard 2. show me the rest."

Action: Write task to platform-api.md with [Verified], owner set to user. Discard item 2 (logged to processed file). Present remaining items.

### File Mode

User checks 3 of 5 items in review-work.md in Obsidian, then says "process my queue."

Read all queues. Find 3 checked items in review-work. Write each to its proposed destination with [Verified]. Remove from review-work.md. Append to processed-2026-04-06.md.

Output:
> 3 items processed from review-work. 2 items remain. Destinations: [[auth-migration]] (1 timeline entry), [[platform-api]] (2 tasks).
