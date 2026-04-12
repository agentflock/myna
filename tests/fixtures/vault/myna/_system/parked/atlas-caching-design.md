---
parked: 2026-04-04 16:30
topic: Atlas Caching Design
---

## Summary

Designing the token caching layer for the Atlas Migration. Three approaches evaluated, leaning toward in-memory with TTL but waiting on Sarah's design doc to confirm cardinality assumptions before finalizing.

## Referenced Files

- [[atlas-migration]] — primary project, caching is on the critical path for May 1 launch
- [[sarah-carter]] — Sarah is drafting the caching design doc
- [[1-1s/sarah-carter]] — token cardinality discussion happened in April 1 session
- [[Adhoc/atlas-caching-design-review]] — upcoming design review meeting April 9
- [[alex-thompson]] — Alex raised the LRU eviction concern

## Discussion Summary

Evaluated three caching approaches for the Atlas auth token cache:

1. **Redis** — rejected. Adds infra overhead (a new service to run, monitor, and on-call). Sarah and Alex agreed the operational cost outweighs the benefit for a v1. Also: we just exited an incident caused by a caching service, don't want to pile on.
2. **Memcached** — considered. Marginal benefit over Redis, similar operational profile. Rejected for the same reason.
3. **In-memory with TTL** — preferred. Zero new dependencies. Natural token expiry aligns with TTL semantics. Concern: memory pressure if active token count exceeds ~50k. Mitigated by LRU eviction at the cap — worst case, some users re-auth, no functional regression.

Sarah surfaced a real risk: production token cardinality is unknown. We're guessing 50k as a reasonable cap but have no telemetry to confirm. Need to instrument before finalizing.

Alex raised a new concern about LRU eviction cascades under bursty load — he's running tests this week and will bring results to the design review.

## Current State

Decision direction is locked in (Option B: in-memory with TTL, LRU at 50k). Sarah is writing the design doc this week. Production telemetry hook hasn't been added yet — that's the next critical action before the design review on April 9. Alex is running load tests separately.

## Next Steps

1. Add the token cardinality telemetry to the production auth service (you, by April 9)
2. Sarah finishes the caching design doc draft (Sarah, by April 10)
3. Review Alex's load test results before the design review (April 8 standup)
4. Run the design review on April 9 — present the approach, the risk, and the data
5. After review: if cardinality is below 50k, ship as designed; if above, reconsider Memcached or shard the in-memory cache by user-id hash

## Open Questions

- What's the production token cardinality at peak right now? (still not answered)
- How does the caching behave when a password reset invalidates all of a user's tokens — is there a cache invalidation API or do we rely on TTL expiry?
- Do we need a cache hit rate metric in v1, or is that a v2 nice-to-have?
- Should Chris Wilson review the design as part of Sentinel Security scope?

## Key Constraints

- No external infrastructure dependencies in v1 — Redis is rejected, don't re-debate
- Must ship before May 1 launch — no time for a redesign if cardinality is way off
- Sarah is leading the design — defer to her on the doc structure and naming
- This is Sarah's first cross-team design review (she told me she "doesn't feel ready") — she needs space to lead, not me stepping in
