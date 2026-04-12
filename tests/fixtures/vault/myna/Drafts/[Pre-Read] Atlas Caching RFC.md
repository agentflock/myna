---
type: pre-read
audience_tier: peer
related_project: Atlas Migration
related_person: null
created: 2026-04-08
---

#draft #pre-read

## Pre-Read: Atlas Caching Design (v1.0 draft)

**TL;DR:** Sarah's design proposes in-memory caching with TTL for Atlas auth tokens, LRU eviction at 50k, replacing the current no-cache approach. Known limitation: LRU eviction cascade under bursty load (discovered yesterday by Alex's load tests).

**Key Decisions Being Asked:**
- Approve in-memory over Redis (final sign-off)
- Agree on TTL duration (Sarah's starting proposal: 5 min)
- Accept the 50k cardinality cap with LRU as the safety net
- Accept the LRU cascade latency spike as a v1 limitation

**Risks and Concerns:**
- Memory pressure above 50k concurrent tokens (mitigated by LRU, but untested in production)
- No cache warming on restart — first requests after deploy will miss
- Single point of failure if the cache process dies
- LRU eviction cascade under bursty load: 200ms tail latency spike on evicted requests. Hit rate stays ~94%, but the eviction storms are non-trivial.
- Production token cardinality is still unknown — we're guessing 50k is the right cap

**Questions to Ask:**
- What's the production token cardinality today? (Still outstanding — I committed to confirming this)
- How does the caching behave when a password reset invalidates all of a user's tokens — TTL expiry only?
- Are we measuring cache hit rate in v1?
- What's the eviction behavior under sustained burst (not just spike)?

**How It Relates to Your Projects:**
- Atlas Migration integration testing starts May 1 — this design needs to land by Monday
- Bridge Integration phase 1 depends on Atlas wave 1 auth — any Atlas delay propagates
- Sentinel Security audit will touch this code path — Chris should review the design

**Stakeholder Impact:**
- Infrastructure team was not consulted on memory requirements — add to the design review
- SRE team needs to approve monitoring before production rollout
- Payments team (Emily) needs to see this before Bridge phase 1 implementation starts

---
*Source: Pre-read preparation for the April 9 Atlas Caching Design Review*
