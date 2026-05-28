# Writing & Drafts — Features

**Scope:** Email drafts, message rewrites, structured drafts (status updates, escalations), recognition drafts, document review, pre-read prep, difficult conversation prep, "help me say no."

---

## Features

> **Note on F3 (Note & Draft Creation):** The mechanics of draft file creation (folder routing, frontmatter, linked TODOs) are system behaviors that apply to all drafts below — not a separate user-facing feature. Each feature below inherits: drafts saved to appropriate `Drafts/` subfolder, auto-created TODO for tracking, proper frontmatter and tags. MBR/MTR/QBR narrative generation is handled by Monthly Update Generation in daily-workflow.
> **Note on F42:** Blocker detection is in projects-and-tasks. Escalation drafting is covered by Structured Draft (escalation mode) below.

### Draft Lifecycle Tracking

One-line summary: Track the state of all your drafts — what's in progress, what's been sent, what needs revision — so nothing falls through.

- Every draft in `Drafts/` has a lifecycle state in its frontmatter: `draft`, `ready`, `sent`, `needs-revision`, `approved`, `archived`
- State transitions via natural language: "I sent the auth migration update" → marks that draft as `sent`. "Sarah has feedback on my MBR" → marks as `needs-revision`.
- Queryable: "what drafts are waiting on someone?" → all drafts in `sent` state. "What do I need to revise?" → all drafts in `needs-revision`. "What's ready to send?" → all drafts in `ready`.
- Surfaced in Unified Dashboard as "Current Drafts" section showing count by state
- Linked TODOs auto-update when draft state changes (e.g., TODO "send reply to James" completed when draft marked `sent`)
- **Why this is needed:** PMs and managers routinely have 5-15 active drafts: status updates waiting for data, email replies waiting for review, doc revisions waiting for feedback. Without lifecycle tracking, you lose track of which drafts are actually done vs. sitting in limbo. The Drafts folder becomes a graveyard of files in unknown states.

### Email Draft Reply

One-line summary: Draft a reply to an email, triggered from the agent conversation OR from a DraftReplies email folder.

- **Two trigger paths:**
  - **Agent conversation:** "Draft reply to [email/thread]" → agent reads the thread, drafts a reply inline
  - **DraftReplies folder:** user configures a DraftReplies email folder. To request a draft, the user forwards an email (or replies to self/an alias) into this folder, including instructions in their message: rough bullet points, intent (escalate, praise, decline, follow up, congratulate, criticize), tone override, audience, what to cover. The agent processes this folder as part of "process my email" — original thread = context, user's reply = instructions. Draft created in `Drafts/Email/`, TODO created to review it, email moved to `DraftReplies/Processed/`.
- **When no instructions provided** (email just forwarded without notes): agent creates a default draft addressing open questions in the thread, using audience tier from registry
- **Multiple intents in one reply:** "Draft a reply to Sarah praising the incident handling AND draft an escalation to her manager about the timeline" → two separate drafts created
- Reads the full thread; addresses all open questions and requests
- Uses sender's audience tier and communication preferences from registry
- BLUF structure by default (D016): lead with the answer or ask, then context
- Tier-aware shaping built in: BLUF for upward, conversational for peer; sign-off from `communication-style.yaml`
- For agent conversation trigger: output shown inline; saved to `Drafts/Email/` if user asks
- Auto-creates linked TODO ("review and send reply to [person] about [topic]")

### Follow-Up Email

One-line summary: Draft a recap or follow-up email from meeting notes with action items and decisions.

- "Draft follow-up email for [meeting]" → creates email draft
- Includes: what was discussed (summary), decisions made, action items with owners, next steps
- Uses communication style for the audience tier of the attendees
- Saved to `Drafts/Email/`, auto-creates linked TODO
- User reviews, copies to email client, sends manually (D003)

### Message Rewriting

One-line summary: Rewrite any Slack message or email for the right tone and audience with three modes.

- Three modes:
  - **Fix:** grammar, spelling, sentence flow — preserves the user's structure, wording, and intent. Minimal touch. Does NOT restructure or apply BLUF. The user's voice stays intact.
  - **Tone:** keeps the user's content and structure but adjusts tone for the target audience — rephrases where needed, applies BLUF structure (D016). The message stays recognizably theirs.
  - **Rewrite:** treats the input as a rough mental model — bullet points, fragments, half-formed thoughts. Rewords, reorders, restructures into a polished message. Applies BLUF structure (D016). The output may look nothing like the input.
- Default mode: rewrite
- Audience tiers from registry: upward, peer, direct, cross-team
- Channel-specific rules: Slack messages are shorter and more casual; emails are more structured
- Reads from `communication-style.yaml` for sign-off only; tier-aware shaping is built in
- Output shown inline

### Structured Draft

One-line summary: Generate status updates or escalation messages from project data.

- Two modes:
  - **Status Update:** pulls from open tasks, recent decisions, timeline entries, blockers → generates progress / blockers / next steps format
  - **Escalation:** drafts professional escalation message → issue, impact, what's been tried, specific ask. Flags long-standing blockers from project timeline.
- Audience-adaptive depth: "write a status update for my VP" → concise, 3-5 bullet executive summary. "Write a status update for the team" → detailed with task-level breakdown. Audience tier from registry determines default depth; user can override.
- Format matches communication style config
- Output shown inline; saved to `Drafts/` if user asks
- Connects to blocker detection (projects-and-tasks): user can say "escalate this blocker" and the escalation mode pulls context from the detected blocker

### Recognition Draft

One-line summary: Draft a specific, genuine recognition message for a team member, optionally in multiple formats.

- "Draft recognition for Sarah" → creates recognition message
- Pulls from person file: recent contributions, observations, recognition entries
- Generates specific, non-generic message grounded in real examples
- Can produce multiple formats: team channel post, manager note, peer shoutout, all-hands mention
- Each format adapted for its audience and channel
- All drafted — nothing sent (D003)
- **Why this is here instead of people-management:** Recognition tracking (collecting the data) is in people-management. Recognition drafting (producing the message) is a writing concern. The data flows from people → writing.

### Help Me Say No

One-line summary: Draft a professional, diplomatic decline that maintains the relationship.

- "Help me say no to [describe the request]" → drafts a decline message
- Preserves the relationship: acknowledges the request, explains constraints without over-apologizing
- Suggests an alternative or path forward when possible
- Uses communication style for the audience tier
- Output shown inline

### Difficult Conversation Prep

One-line summary: Prepare for a hard conversation with a structured guide covering what to say, what to avoid, and how to close.

- "Help me prepare for [describe the conversation]" → generates prep guide
- Sections: suggested opening, key points to cover (prioritized), things to avoid saying, how to close constructively
- Flags if the conversation likely requires follow-up documentation (e.g., performance concerns → document afterwards)
- Tone calibrated to tier (coaching for direct reports, measured for peer, concise for upward)
- Output shown inline or saved as a note

### Document Processing

One-line summary: Extract structured data from any document and route it to the vault — same pipeline as email processing.

- "Process this doc: [paste or describe]" → decomposes into: updates, action items, decisions, blockers, risks
- Same routing and provenance marker system as email processing:
  - Each extracted entry tagged `[Auto]` (explicit in source), `[Inferred]` (agent interpreted), or routed to review queue (genuinely ambiguous)
- Works with any source: pasted text, linked document, email attachment description, Slack message
- Particularly useful for: design docs shared via email, PR/FAQ documents, Zoom meeting summaries forwarded via email

### Pre-Read Preparation

One-line summary: Prepare you to engage intelligently with a document before a review or meeting.

- "Prep me for this doc: [paste or link]" → generates a prep note
- Sections:
  - **TL;DR** — what this doc is about (2-3 sentences)
  - **Key Decisions Being Asked** — what the author wants you to decide or approve
  - **Risks and Concerns** — what could go wrong, missing pieces, shaky assumptions
  - **Questions You Should Ask** — based on gaps, unclear sections, missing data
  - **How It Relates to Your Projects** — connections to your project timelines and open items
  - **Stakeholder Impact** — who's affected, who should have been consulted
- Written to meeting prep file if tied to a meeting, or standalone note
- Different from Document Processing: processing extracts data for the vault, pre-read prepares YOU to engage with the content

### Document Review

One-line summary: Multi-persona critique of any technical document — PRFAQ, design doc/RFC, HLD, LLD, one-pager, or generic — synthesized by Myna as Chief of Staff.

- **Six doc types supported:** PRFAQ, design doc/RFC, HLD (high-level design), LLD (low-level design), one-pager, generic. Type detected automatically from filename, headings, or user-stated type.
- **Panel composition:** each doc type has a default reviewer panel selected from 11 input-agnostic persona subagents (Principal Engineer, Sr SDE, SRE, Security, QA, Product Leader, PM, Customer Skeptic, Skeptic, Decision-Maker, Writer/Editor). User can override: "skip writing feedback", "focus on security", "add the skeptic".
- **Three modes:**
  - **Full review** — all assigned personas run in parallel; synthesized multi-section report. Default.
  - **Quick CoS read** — Myna reads as Chief of Staff only, no subagents; 5-bullet executive summary. Invoked with "quick" or "compact" in the prompt.
  - **Targeted review** — subset of personas specified by user; same synthesis as full review.
- **Chief-of-Staff context layer:** Myna layers vault evidence before subagents run (project links, audience tier from `people.yaml`, communication style from `communication-style.yaml`). This context is injected into every subagent's input as a "Myna context" block.
- **Save by default:** review report written to `Reviews/{YYYY-MM-DD}-{doc-slug}.md` with `type: review` frontmatter. For paste-type reviews, source text preserved at `Reviews/sources/{YYYY-MM-DD}-{doc-slug}.md`. User can say "don't save" to skip.
- **Input modes:** paste content directly, provide a file path, or provide a URL.
- **Persona override examples:** "review my PRFAQ", "review this design doc with security focus", "review this LLD, skip writing feedback", "have the PE look at this", "compact review of this one-pager"

