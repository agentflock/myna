---
type: 1-1
person: [[sarah-carter]]
---

#meeting #1-1

## 2026-02-24 Session

### Prep

- [x] **Follow-through:** You reviewed Sarah's Atlas provider shortlist draft — done
- [x] **Recent work:** Sarah mentored Marcus through his first on-call rotation
- [x] **Carry-forward:** Documentation discipline — continue
- [x] **Personal:** Marathon training — check in

### Notes

**Discussion:**
- Sarah's happy with the Atlas pace. Feels sustainable.
- Brought up the tech lead growth plan — she wants more cross-team visibility but isn't sure where to start.
- Marathon training going well. Not sure about the Big Sur race yet.

**Action Items:**
- You to introduce Sarah to the Payments tech lead at next portfolio review
- Sarah to share her Atlas provider shortlist doc externally

**Decisions:**
- None

*[Processed 2026-02-24]*

## 2026-03-18 Session

### Prep

- [x] **Follow-through:** You introduced Sarah to the Payments tech lead — done
- [x] **Recent work:** Sarah landed the OAuth provider spike
- [ ] **Pending feedback:** Documentation discipline — draft alongside code
- [x] **Carry-forward:** Tech lead growth plan — next step

### Notes

**Discussion:**
- Sarah is enjoying the Atlas work, feels pace is sustainable
- Talked about her tech lead growth plan — she wants more cross-team visibility
- Agreed that the Atlas caching design review (upcoming) is a natural place for her to lead

**Action Items:**
- Sarah to share draft OAuth provider comparison
- You to introduce Sarah to the Payments tech lead (done before this session actually)

**Decisions:**
- Sarah will lead the next architecture conversation on Atlas caching

*[Processed 2026-03-18]*

## 2026-03-25 Session

### Prep

- [x] **Follow-through:** You sent the design review template — done
- [ ] **Carry-forward:** Documentation discipline (still pending feedback)
- [x] **Recent work:** Sarah's incident handling on March 12 — Chris cited her in the postmortem
- [ ] **Career development:** Tech lead growth plan — next concrete step
- [x] **Personal:** Adopted a rescue dog named Pepper

### Notes

**Discussion:**
- Brought up the incident and praised her calm handling — she was touched, mentioned it was the first time someone called her out publicly for the *process* not just the outcome
- Sarah wants more design review experience — agreed she'll lead the caching design review
- She opened up about feeling like she "hasn't earned" the room with more senior cross-team engineers yet

**Action Items:**
- Sarah to lead the Atlas caching design review
- You to send her the design review template

**Decisions:**
- Sarah will lead the next architecture conversation on Atlas

*[Processed 2026-03-25]*

## 2026-04-01 Session

### Prep

- [x] **Follow-through:** You sent the design review template — done
- [x] **Carry-forward:** Documentation discipline — open with the Atlas spec gap example
- [ ] **Recent work:** Sarah closed 3 tasks on Atlas since last session
- [x] **Pending feedback:** Documentation discipline — discussed
- [ ] **Career development:** No career topic logged in 6 weeks
- [x] **Personal:** Marathon training continues, Big Sur in May

### Notes

**Discussion:**
- Sarah surfaced concern about token cardinality — we may exceed 50k tokens at peak. She brought sampling data, not just a gut feel.
- Discussed caching options: Redis (rejected — infra overhead), Memcached (considered), in-memory with TTL (preferred)
- Gave the documentation discipline feedback. Sarah was receptive — agreed to draft alongside code on Atlas going forward
- Career: she wants to try leading the Bridge Integration kickoff too — said yes, will add her to the invite

**Action Items:**
- Sarah to draft the caching design doc by April 10
- You to confirm token cardinality numbers from production telemetry
- You to add Sarah as co-lead on Bridge Integration kickoff
- Carry forward: follow up on design review experience

**Decisions:**
- Go with Option B: in-memory caching with TTL, LRU eviction at 50k

*[Processed 2026-04-01]*
