---
type: recurring
project: Atlas Migration
---

#meeting #recurring

## 2026-04-06 Session

### Prep

- [x] **Your updates:** Reviewed Sarah's design template
- [x] **Team blockers:** None blocking the team this week

### Notes

**Discussion:**
- Sarah: API spec v2 going out for review later today
- Alex: integration with Phoenix client on track
- Marcus: still blocked on infra team (Phoenix, not Atlas — surfaced for awareness)

**Action Items:**
- None new

*[Processed 2026-04-06]*

## 2026-04-07 Session

### Prep

- [x] **Your updates:** API spec v2 went out
- [x] **From last standup:** Sarah's spec sent — confirmed

### Notes

**Discussion:**
- Sarah: started the caching design doc
- Alex: noticed an edge case in token refresh under load — investigating
- Marcus: fallback design started on Phoenix

**Action Items:**
- Alex to share token refresh test results tomorrow

*[Processed 2026-04-07]*

## 2026-04-08 Session

### Prep

- [x] **Your updates:** Reviewed Sarah's API spec v2 last night
- [x] **From last standup:** Alex's token refresh test results
- [x] **Team blockers:** Surface Phoenix blocker to broader team

### Notes

**Discussion:**
- Alex: token refresh load test results — LRU eviction cascade found, 200ms tail latency spike
- Sarah: will update the caching design to note the cascade
- Marcus: fallback design in progress, 60% done
- You: flagged that you'll be in the skip-level this afternoon, Marcus to cover if anything comes up

**Action Items:**
- Sarah to update caching design before Thursday's design review
- Alex to document the load test methodology

*[Processed 2026-04-08]*

## 2026-04-09 Session

### Prep

- [x] **Your updates:** Design review prep done
- [x] **From last standup:** Sarah's updated design

### Notes

**Discussion:**
- Sarah: caching design updated, circulated to Payments and Infra
- Alex: load test methodology documented
- Marcus: fallback design 80% done

**Action Items:**
- None new

*[Processed 2026-04-09]*

## 2026-04-10 Session

### Prep

- [ ] **Your updates:** Caching design review went well, decisions locked
- [ ] **From last standup:** Marcus's fallback design
- [ ] **Team blockers:** Bridge Integration timeline question

### Notes
