---
type: escalation
audience_tier: upward
related_project: Phoenix Platform
related_person: David Clark
created: 2026-04-08
---

#draft #escalation

**Bottom line:** Phoenix Platform v1 ingestion path has been blocked on the Infrastructure team's schema validator upgrade for 16 days, with no ETA. I'm asking you to raise this with their team lead directly.

**What's blocked:**
Phoenix v1 ingestion path depends on a schema validator service owned by the Infrastructure team. The current version fails under load (surfaced March 5). Without the upgrade, we cannot proceed to integration testing.

**What we've tried:**
- Three Slack pings from Marcus to their team channel (March 18, March 22, March 30)
- One email to the team alias (April 2)
- Raised at Platform Weekly twice
- Marcus has started a fallback design using a stub validator (schema-shape checks only, no semantic validation) that gives us forward motion, but is not a v1-launchable solution

**Impact if not resolved:**
- Phoenix v1 launch slips past Q2
- Marcus is out on parental leave starting May 18 (12 weeks) — if the blocker extends past May, we lose our ingestion-path owner
- Every week of delay extends our staffing gap

**Ask:**
Can you speak to the Infra team lead directly this week? Ideally we'd get either: (1) a firm ETA for the validator upgrade, or (2) agreement to let Platform team members contribute to the upgrade directly.

**Context:**
Full timeline and Slack threads in [[phoenix-platform]]. Happy to walk through on a call if useful.

Thanks,
Sam

---
*Source: Phoenix blocker reached 16 days with no response from infra team*
