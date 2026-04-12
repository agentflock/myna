---
type: status-update
audience_tier: upward
related_project: Atlas Migration
related_person: null
created: 2026-04-10
---

#draft #status-update

**Bottom line:** Atlas Migration is on track for May 1 integration testing. One open risk on token cardinality, with a known fallback. One known limitation (LRU cascade) accepted for v1.

**Progress this month:**
- API spec v2 complete and reviewed end-to-end
- Caching approach decided (Option B: in-memory with TTL, LRU at 50k)
- Caching design reviewed cross-team with Payments (Sarah led her first cross-team design review)
- OAuth provider integration spike landed and deployed to staging
- March 12 cache poisoning incident resolved and postmortem complete

**Risks:**
- Production token cardinality not yet measured. Confirming this week. If above 50k, the LRU cap kicks in — no user-visible impact, but worth knowing.
- LRU eviction cascade under bursty load — 200ms tail latency spike on evicted requests. Documented as a v1 known limitation, v2 will address.

**Next steps:**
- Finalize caching design doc with Payments and Infra feedback
- Draft Wave 1 migration communication for the 12 services Emily identified
- Coordinate Atlas wave 1 handoff with Bridge Integration phase 1
- Start Wave 1 internal service migrations week of April 20

---
*Source: Monthly status update for David Clark and James*
