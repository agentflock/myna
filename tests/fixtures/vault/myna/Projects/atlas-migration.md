---
created: 2026-01-06
---

#project #atlas-migration

## Overview

**Description:** Migrating the legacy auth service to the new internal OAuth2 platform
**Status:** active
**Key People:** [[sarah-carter]], [[alex-thompson]]
**Target launch:** 2026-05-01 (integration testing start)

## Timeline

> Append-only chronological log. Sorted by event date, not processing date.

- [2026-01-06 | user] Project scoped at eng leads sync — three waves: internal services, partners, customer-facing [User]
- [2026-01-15 | user] Kickoff with Platform and Payments — roles assigned, Sarah leads [User]
- [2026-01-22 | meeting Atlas kickoff] Decided to build on the internal OAuth2 platform instead of adopting an external IdP — long-term ownership trade-off [User]
- [2026-01-29 | slack #atlas-team] Sarah did code archaeology on the legacy token cache — found an undocumented fallback path that nobody currently alive wrote [Auto]
- [2026-02-03 | meeting Atlas kickoff part 2] Confirmed three-wave migration plan with Payments — Emily Parker agreed to be the Payments counterpart [User]
- [2026-02-12 | email from James] Compass v1 shipped on time, Sarah recognized by name in the company all-hands email [Auto]
- [2026-02-20 | email from Sarah Carter] OAuth provider shortlist narrowed to two: Auth0 and the new internal platform [Auto]
- [2026-02-28 | slack #atlas-team] Spike started on the internal platform integration — Alex volunteered to own it [Auto]

> [!info] Decision
> [2026-03-04 | meeting Architecture Review] Go with the internal OAuth platform — better long-term ownership, acceptable migration cost, better vendor-lock avoidance [Auto]

- [2026-03-08 | slack #atlas-team] Alex caught an OAuth refresh edge case during code review — would have caused a token refresh storm [Auto]
- [2026-03-10 | slack #atlas-team] Internal platform integration spike completed — 4 days actual vs 3 day estimate, considered successful [Auto]
- [2026-03-12 | meeting Incident postmortem] March 12 cache poisoning incident — legacy token cache race condition, Sarah identified root cause in 20 minutes [Auto]
- [2026-03-15 | email from James] Acknowledged Sarah's incident handling — filed to HR record [Auto]

> [!tip] Recognition
> [2026-03-15 | email from James] Sarah Carter for calm, methodical incident handling during the March 12 outage [Auto]

- [2026-03-20 | meeting 1:1 with Sarah] Documentation-alongside-code agreement for Atlas — growth-area feedback landed [User]
- [2026-03-22 | meeting 1:1 with Sarah] Sarah surfaced token cardinality concern — sampling suggests 45-55k active tokens at peak, not the 30k we assumed [Auto]
- [2026-03-27 | slack #atlas-team] Staging deployment of the OAuth2 platform — no regressions in Atlas integration tests [Auto]
- [2026-03-30 | slack #atlas-team] Provider selection finalized across Platform and Payments — Sarah drove the alignment [Inferred]

> [!info] Decision
> [2026-04-01 | meeting 1:1 with Sarah] Go with Option B for token caching — in-memory with TTL, LRU eviction at 50k cap [Auto]

- [2026-04-02 | email from Sarah Carter] Meeting recap email: caching decision logged, next steps confirmed [Auto]
- [2026-04-03 | email from Sarah Carter] API spec v2 ready for internal review — circulating to Platform and Payments [Auto]
- [2026-04-04 | slack #atlas-team] Emily Parker (Payments) sent first round of spec questions — token device-binding flow [Auto]
- [2026-04-05 | email from Alex Thompson] Alex proposed covering LRU eviction edge case in the design review [Auto]
- [2026-04-06 | slack #atlas-team] Sarah closed 4 tasks since last week — token refresh fix, spec draft, two integration tests [Auto]

> [!tip] Recognition
> [2026-04-06 | slack #atlas-team] Sarah caught the token cardinality risk before it could become a production memory issue [Auto]

- [2026-04-07 | email from Emily Parker] Emily Parker (Payments) confirmed first-wave migration list — 12 services identified [Auto]
- [2026-04-08 | slack #atlas-team] Alex's token refresh load tests surfaced the LRU eviction cascade — 200ms tail latency spike under bursty load [Auto]

> [!info] Decision
> [2026-04-09 | meeting Atlas Caching Design Review] Keep Option B as designed; note the LRU cascade as a known limitation to address in v2 [Auto]

- [2026-04-10 | slack #atlas-team] Sarah shared the updated caching design doc with Payments and Infra — feedback due Monday [Auto]

## Open Tasks

- [ ] Review updated caching design doc from Sarah 📅 2026-04-13 ⏫ [project:: Atlas Migration] [type:: task] [Auto] (slack, #atlas-team, 2026-04-10)
- [ ] Sarah to draft the v1.1 token refresh retry semantics note 📅 2026-04-15 [project:: Atlas Migration] [type:: delegation] [person:: Sarah Carter] [Auto] (meeting, Atlas Caching Design Review, 2026-04-09)
- [ ] Alex to integrate API spec into Phoenix client 📅 2026-04-15 [project:: Atlas Migration] [type:: delegation] [person:: Alex Thompson] [Auto] (email, Sarah, 2026-04-03)
- [ ] Confirm production token cardinality from telemetry 📅 2026-04-13 🔼 [project:: Atlas Migration] [type:: task] [review-status:: pending] [Inferred] — owner inferred from prior conversation
- [ ] Reply to Sarah Mitchell about Q2 dependencies 📅 2026-04-10 [project:: Atlas Migration] [type:: reply-needed] [review-status:: pending] [Inferred] (email, Sarah Mitchell, 2026-04-06) — needs reply
- [ ] Draft the Wave 1 migration communication for the 12 services 📅 2026-04-17 [project:: Atlas Migration] [type:: task] [User]
- [ ] Emily Parker to confirm Payments test environment access 📅 2026-04-14 [project:: Atlas Migration] [type:: delegation] [person:: Emily Parker] [Inferred] — implied in her April 7 email but no explicit commit

```dataview
TASK
FROM "myna/Projects/atlas-migration"
WHERE !completed
SORT priority DESC, due ASC
```

## Links

- [Atlas Migration RFC](https://docs.acme.io/rfc/atlas-001) — original architecture proposal [2026-01-15]
- [OAuth Platform API docs](https://platform.acme.io/oauth) — internal docs [2026-02-20]
- [Token Caching Design v1](https://docs.acme.io/atlas/caching-v1) — Sarah's design doc [2026-04-08]
- [March 12 Incident Postmortem](https://docs.acme.io/incidents/2026-03-12) — Chris's root cause writeup [2026-03-15]
- [Atlas API Spec v2](https://docs.acme.io/atlas/api-v2) — circulating for review [2026-04-03]

## Notes

> Free-form scratchpad. Every entry auto-dated with source.

- [2026-03-22 | capture] Need to schedule a load test session before integration testing — Alex has agreed to own this
- [2026-04-01 | capture] Caching TTL trade-off: longer = fewer hits to source, shorter = fresher tokens. Sarah preferred 5 min as starting point.
- [2026-04-04 | capture] Emily Parker is a strong Payments counterpart — keep her close on the wave 1 migration plan
- [2026-04-08 | capture] LRU cascade is a known limitation in v1. v2 fix should look at a probabilistic expiry strategy
- [2026-04-10 | capture] Need to figure out skip-level coverage with James while I'm over-indexed on Atlas
