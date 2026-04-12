---
created: 2026-01-20
---

#project #aurora-dashboard

## Overview

**Description:** Internal analytics dashboard for engineering leadership
**Status:** active
**Key People:** [[nate-brooks]], [[laura-hayes]]
**Notes:** Nate's first lead project — small scope, high learning value

## Timeline

> Append-only chronological log. Sorted by event date, not processing date.

- [2026-01-20 | user] Project created — Nate assigned as first lead [User]
- [2026-02-04 | meeting 1:1 with Nate] Nate to own scope, reviewers, timeline — first real lead role [User]
- [2026-02-18 | slack #aurora-dashboard] First tile shipped — PR count by team [Auto]
- [2026-03-03 | slack #aurora-dashboard] Nate completed the dashboard skeleton — header, nav, placeholder tiles [Auto]
- [2026-03-11 | slack #aurora-dashboard] Aurora filter refactor landed — 600 lines of tangled logic cleaned up [Auto]

> [!tip] Recognition
> [2026-03-11 | slack #aurora-dashboard] Nate Brooks for the clean filter refactor — thoughtful tests, readable code [Auto]

- [2026-03-25 | meeting 1:1 with Nate] Nate is officially leading the project — scope locked, timeline agreed [User]
- [2026-04-02 | slack #aurora-dashboard] Laura's team-velocity tile integrated — cross-team collaboration [Auto]
- [2026-04-06 | slack #aurora-dashboard] David Clark previewed the dashboard — positive feedback, two scope requests added [Auto]
- [2026-04-08 | meeting 1:1 with Nate] Nate brought written Aurora status doc to 1:1 — clean format [User]

## Open Tasks

- [ ] Nate to implement the incidents-by-severity tile 📅 2026-04-17 [project:: Aurora Dashboard] [type:: delegation] [person:: Nate Brooks] [Auto] (slack, #aurora-dashboard, 2026-04-06)
- [ ] Nate to add David Clark's scope requests to the backlog 📅 2026-04-14 [project:: Aurora Dashboard] [type:: delegation] [person:: Nate Brooks] [User]
- [ ] Review Aurora dashboard before Platform all-hands demo 📅 2026-04-23 [project:: Aurora Dashboard] [type:: task] [User]
- [ ] Laura to wire the second velocity tile 📅 2026-04-21 [project:: Aurora Dashboard] [type:: delegation] [person:: Laura Hayes] [User]

```dataview
TASK
FROM "myna/Projects/aurora-dashboard"
WHERE !completed
SORT priority DESC, due ASC
```

## Links

- [Aurora Dashboard wireframes](https://docs.acme.io/aurora/wireframes) — [2026-02-04]
- [Aurora repo](https://github.com/acme/aurora-dashboard) — [2026-02-10]

## Notes

> Free-form scratchpad. Every entry auto-dated with source.

- [2026-02-04 | capture] Aurora is the right project for Nate's first lead role — small scope, clear users, low criticality if it slips
- [2026-04-06 | capture] David Clark's scope requests are reasonable — but watch that we don't let Nate's first lead project turn into a leadership dashboard race
