# Sources — Atlas Migration

> Verbatim source text appended chronologically. One file per project.

## 2026-03-15 — email: James Miller, "Sarah's incident handling"

> Wanted to flag for you — Sarah was outstanding during the March 12 cache poisoning incident. She kept the bridge calm, identified the root cause within 20 minutes, and walked the team through the rollback methodically. This is the kind of incident response I want everyone modeling. Please make sure this lands in her record.

Referenced by: [[sarah-carter]] — Recognition (March 12 incident handling), [[atlas-migration]] — Timeline (March 12 incident acknowledgment)

## 2026-04-01 — meeting: 1:1 with Sarah Carter

> Discussion (raw): Sarah brought up token cardinality. We've been assuming ~30k active tokens but she pulled some sampling data and it looks closer to 45-55k. Walked through three caching options. Sarah preferred in-memory with TTL — said the operational cost of Redis isn't worth it for v1. Agreed to go with Option B and put an LRU cap at 50k as a safety net.
>
> Documentation feedback delivered. Sarah took it well and committed to drafting alongside code on Atlas.
>
> Also agreed she'll lead the Bridge Integration kickoff as co-lead — stretch opportunity.

Referenced by: [[sarah-carter]] — Observations (token cardinality strength, documentation growth-area), [[atlas-migration]] — Timeline (Decision: Option B caching)

## 2026-04-03 — email: Sarah Carter, "API spec v2 ready for review"

> Hi Sam,
>
> The API spec v2 is finalized. I've addressed the feedback from the design sync and added the token refresh flow we talked about.
>
> Couple things to flag:
> - I'm targeting Alex to integrate this into the Phoenix client by April 15. Already pinged him.
> - Going with Option B for caching — in-memory with TTL, LRU at 50k. Will draft the design doc this week.
> - We should run a load test before integration testing — happy to set it up.
>
> Great work from the whole team getting this across the line.
>
> Sarah

Referenced by: [[atlas-migration]] — Timeline (API spec v2 ready), Open Tasks (Alex integration delegation), [[sarah-carter]] — Recognition

## 2026-04-06 — slack: #atlas-team, Sarah Carter

> Closed a bunch this week — token refresh fix is in, two integration tests landed, spec v2 is out. Caching design doc starts tomorrow.

Referenced by: [[atlas-migration]] — Timeline (Sarah closed 4 tasks)

## 2026-04-08 — slack: #atlas-team, Alex Thompson

> Token refresh test results are in. Under bursty load (10x baseline) the LRU eviction storm I mentioned does happen — about a 200ms tail latency spike for the affected requests. Not catastrophic but worth designing around. Will write up the test methodology and post here later today.

Referenced by: [[atlas-migration]] — Timeline (LRU cascade), [[alex-thompson]] — Recognition

## 2026-04-08 — email: Sarah Carter, "RE: Atlas API spec v2 — questions on token refresh"

> Sam — got a few questions on the spec from the Payments team. They're asking whether the token refresh path will support the new device-binding flow they're rolling out in Q3. I don't think it does today, and adding it would require restructuring the refresh endpoint.
>
> Wanted to check with you before answering. Will forward the thread once you confirm the approach is what we discussed.

Referenced by: [[review-triage]] — pending triage entry, [[atlas-migration]] — Open Tasks (review updated spec)

## 2026-04-09 — meeting: Atlas Caching Design Review

> Discussion (raw): Sarah walked through the design cleanly. Alex presented the LRU cascade findings. Emily Parker asked about password reset interaction — TTL expiry handles it. Team agreed to accept the LRU cascade as a v1 limitation, documented for v2. Decision locked: go with Option B as designed.

Referenced by: [[atlas-migration]] — Timeline (Decision), [[sarah-carter]] — Observations (design review strength)
