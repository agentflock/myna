---
dashboard: blockers
---
#dashboard

## Active Blockers

### By Project
```dataview
TASK
FROM "myna/Projects"
WHERE !completed AND type = "blocker"
GROUP BY file.link
SORT due ASC
```

### Dependencies Overdue
```dataview
TASK
FROM "myna"
WHERE !completed AND type = "dependency" AND due < date(today)
SORT due ASC
```
