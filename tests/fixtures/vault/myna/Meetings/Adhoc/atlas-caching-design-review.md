---
type: adhoc
project: Atlas Migration
---

#meeting #adhoc

## 2026-04-09 Session

### Prep

- [x] **Open action items:** API spec v2 review feedback (yours, due today)
- [x] **Recent decision:** Token caching approach — Option B with in-memory TTL (2026-04-01)
- [x] **Open blocker:** None on Atlas this week

### Pre-Read

- [x] **TL;DR:** Proposes in-memory caching with TTL for auth tokens, replacing the current no-cache approach
- [x] **Key Decisions Being Asked:** Approve in-memory over Redis; agree on TTL duration; accept the 50k cardinality cap with LRU
- [x] **Risks and Concerns:** Memory pressure above 50k concurrent tokens; no cache warming on restart; single point of failure if the box dies; Alex flagged LRU eviction cascade under bursty load
- [x] **Questions to Ask:** What's the production token cardinality today? How does this interact with password resets? Are we measuring cache hit rate? What's the eviction behavior under burst?
- [x] **How It Relates to Your Projects:** Atlas Migration timeline depends on this — delayed approval pushes integration testing past May 1
- [x] **Stakeholder Impact:** Infra team not consulted on memory requirements; SRE team needs to approve monitoring

### Notes

**Discussion:**
- Sarah walked through the design. Clear presentation. Owned the room.
- Alex presented the LRU cascade findings from his load tests
- Emily Parker asked about password reset interaction — discussed TTL expiry as the invalidation mechanism
- Payments team agreed with the phased approach
- Concern about cache warming on restart — decided to accept it as a v1 limitation, document clearly

**Action Items:**
- Sarah to finalize the design doc with Alex's LRU cascade notes
- Sarah to draft the v1.1 token refresh retry semantics note
- You to confirm production token cardinality from telemetry
- Emily to coordinate the Payments testing environment

**Decisions:**
- Go with Option B as designed. Known limitations (LRU cascade, cold start) documented for v2.
- Sarah owns the final design doc.

*[Processed 2026-04-09]*
