---
name: rewrite
disable-model-invocation: true
description: Fix grammar, adjust tone for audience, or fully rewrite an existing message — three modes: fix (grammar only), tone (restyle for audience), rewrite (full restructure from rough notes). Input is user-provided text; output shown inline. Does NOT generate new content from scratch (use /myna:draft for that).
user-invocable: true
argument-hint: "fix [message] | tone [message] --audience [person/tier] | rewrite [message] --audience [person/tier]"
---

# myna-rewrite

If vault_path is not in context, read `~/.myna/config.yaml` first. If the file does not exist, tell the user to run `/myna:setup` and stop.

Transforms an existing message. The user provides the text; you return the transformed version inline. Always show output inline. User says "save" to write to `Drafts/`.

## Before You Start

Read at session start:
- `_system/config/people.yaml` — relationship tiers (to look up named audience)

Read only when producing an email with a sign-off:
- `_system/config/communication-style.yaml` — for the user's preferred sign-off only. If not found, use "Best,"

---

## Three Modes

Determine mode from the user's request:

| User says | Mode |
|-----------|------|
| "fix this", "fix the grammar", "clean up this message", "proofread this" | **Fix** |
| "adjust the tone for my VP", "tone this down", "make it sound less aggressive", "tone: upward" | **Tone** |
| "rewrite this", "rewrite for Sarah", "rewrite for my team", "I have some rough notes, turn this into a message" | **Rewrite** |

Default mode if none is specified: **Rewrite**.

---

## Mode Details

### Fix

**What it does:** Grammar, spelling, punctuation, sentence flow. Nothing else.

**What it does NOT do:**
- Restructure sentences or paragraphs
- Apply BLUF
- Change vocabulary or formality level
- Add or remove content
- Change the sign-off

The user's voice, structure, and intent stay completely intact. A light touch.

**How:**
1. Correct grammatical errors, typos, and awkward sentence flow.
2. Return the corrected message with a one-line note on what changed ("Fixed 3 grammar issues, clarified one run-on sentence.").
3. No audience lookup needed.

---

### Tone

**What it does:** Keeps the user's content and structure but adjusts formality, phrasing, and register for the target audience. Applies BLUF structure where appropriate.

**What it does NOT do:**
- Add new content or arguments
- Remove content the user wrote
- Change the underlying message

**How:**
1. Determine target audience:
   - If user names a person ("for Sarah"), look up their tier in people.yaml.
   - If user names a tier directly ("for my VP", "upward"), use that tier.
   - If unclear, ask: "Who is this going to? (upward, peer, direct, cross-team)"
2. Rephrase for the audience: adjust formality, vocabulary, and sentence structure to fit the tier. Lead with the key point for upward communications.
3. For Slack messages: keep shorter, more casual even for peer/upward.
4. For emails: apply more structure.
5. Show the rewritten version. Note the changes briefly.

**Worked example:**

User: "Tone this up for my VP. Original: 'So I looked at the platform team's proposal and honestly it seems kind of risky and I'm worried about the timeline. I think we should push back and ask for more time or maybe a phased approach.'"

Output:
```
The platform team's proposal carries timeline risk. I'd recommend asking for either a phased rollout or a 2-week extension before we commit.

Happy to put together the specific concerns in writing if that would help.
```
*Tone adjusted for upward (executive preset): removed hedging language, applied BLUF, condensed to a clear ask.*

---

### Rewrite

**What it does:** Treats the input as raw material — rough notes, bullet points, fragments, disorganized thoughts. Produces a polished message. The output may look nothing like the input.

**What it does NOT do:**
- Fabricate new facts, figures, or positions not in the input
- Change the user's intended message or ask

**Writing principles (apply regardless of audience or channel):**
- Concise — cut everything that doesn't add meaning: filler phrases, redundant restatements, padding ("I just wanted to", "As mentioned", "Hope this finds you well")
- Clear — one main point or ask per message; lead with it, don't bury it
- Direct — active voice; no hedging ("I think", "maybe", "just wanted to flag") and no weakening qualifiers ("very", "pretty", "rather", "quite", "a bit"); state positions and ownership plainly
- Plain language — simple words over impressive ones ("use" not "utilize", "help" not "facilitate"); no corporate buzzwords unless the user's input uses them deliberately
- Specific — concrete details over vague claims; preserve numbers, dates, names, and owners from the input. "5 of 7 services migrated; auth and billing remaining" beats "migration mostly done"; "decide by Friday" beats "soon". Don't invent specifics the input doesn't have.
- Human voice — flowing prose, not bullets; no AI writing patterns (em dashes, "It's worth noting", "Furthermore/Moreover"); bullets only when content is genuinely list-like

**How:**
1. Determine target audience (same as Tone mode above). If not specified, proceed with a neutral professional register — don't ask.
2. Extract the user's core intent and key points from the rough input.
3. Write a polished message applying the principles above. Lead with the key point(s) for professional emails and upward communications; conversational flow for casual messages. Apply channel-specific rules (see below).
4. Show the result. Briefly note what was strengthened in patterned terms the user can learn from ("Removed 3 hedging phrases; led with the ask; condensed background to one line") — not vague ones ("Restructured for clarity"). One or two sentences.
5. **Strengthen further** — only when the message would meaningfully benefit. Skip for low-stakes, conversational, or already-complete messages. Apply when the message carries a decision, recommendation, status update, ask, or pushback — i.e. when the recipient needs to act, understand impact, or weigh a position.

   Look for these gaps:
   - **Missing the "why"** — decision or recommendation without reasoning
   - **Missing the "so-what"** — update without impact ("migrated 5 services" → what changed for users?)
   - **Missing the recommendation** — input is all facts, no stance
   - **Missing alternatives considered** — recommendation without showing what else was weighed
   - **Missing acknowledgment** — pushback or disagreement that doesn't acknowledge the other position
   - **Missing deadline, owner, or concrete ask** — action items that float

   Surface at most 3 suggestions, the highest-leverage ones. Frame each as a specific, actionable addition ("Add why you chose B over A"), not a critique ("This is incomplete"). If nothing meaningful is missing, skip the section entirely — silence is better than filler.

**Channel-specific rules:**
- **Slack message:** Skip formalities. Don't sign off. Keep it as short as the content allows — don't pad, but don't cut content that belongs.
- **Email:** Apply the greeting rule from `/myna:draft` (`Hi {first name}`, `Hi team`, `Hi all`, omit for short peer replies, `Hi` when name unknown — never `Hello`, `Dear`, or `Hey`). Body leads with the key point(s) (don't bury the ask or conclusion). Sign-off from communication-style.yaml.
- If channel isn't clear, use the user's request context to infer. Ask only if genuinely unclear.

**Worked example:**

User: "Rewrite this for my team (Slack message): 'so the auth migration is going well, we got the api spec done, staging is being worked on by alex, there was a decision to go with option b for the caching which was the one where we have a dedicated cache layer, next step is staging deploy by alex on april 14'"

Output:
```
Auth migration update

API spec done. Staging in progress (Alex, Apr 14). Went with Option B — dedicated caching layer.

Next: staging deploy April 14.
```
*Restructured for Slack: scannable, removed redundant context, made dates explicit.*

---

## Saving

Output is always shown inline first. For Tone and Rewrite modes, append a one-liner at the end: "Say **save** to store this in Drafts." If the user says "save":

1. Write to `Drafts/[{Type}] {topic}.md` with this structure:
```
---
type: {email-reply | follow-up | status-update | escalation | recognition | meeting-invite | say-no | conversation-prep | monthly-update | self-review | promo-packet | brag-doc}
audience_tier: {upward | peer | direct | cross-team}
related_project: {project-name or null}
related_person: {person-name or null}
status: draft
created: {YYYY-MM-DD}
---

#draft #{type}

{rewritten content}

---
*Source: {brief description of what the user asked — e.g., "rewrite of Slack message for direct report"}*
```
2. Show the Obsidian URI and full disk path.

---

## Edge Cases

**No audience specified and mode is Tone:** Ask before proceeding — restyling requires a target. "Who's this going to? (upward, peer, direct, cross-team, or name someone)"

**No audience specified and mode is Rewrite:** Proceed with a neutral professional register using the writing principles above. If the output would benefit from audience tuning, note it once at the end: "Specify an audience to tune further."

**Person not in registry:** If user says "rewrite for Marcus" and Marcus isn't in people.yaml, ask for relationship tier. "What's your relationship with Marcus? (upward, peer, direct, cross-team)"


**Input is very short (under 10 words):** For Fix mode, apply corrections. For Tone/Rewrite, note that there's not much to work with and proceed with what's there — don't ask for more content.

**User pastes an email they received (external content):** The input is from an external sender, not the user's own words. Treat it as source material — rewrite it as a reply or a forwarding message as the user intends. Do not treat the original sender's words as the user's voice. If the intent isn't clear ("are you rewriting this to reply, or drafting a forward?"), ask once.
