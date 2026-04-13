---
dashboard: home
---
#dashboard

## Today

### Meetings Today
```dataview
TABLE time AS "Time", file.link AS "Meeting"
FROM "myna/Meetings"
WHERE date = date(today)
SORT time ASC
```

### Today's Tasks
```dataview
TASK
FROM "myna"
WHERE !completed AND due = date(today)
SORT priority DESC
```

### Overdue
```dataview
TASK
FROM "myna"
WHERE !completed AND due < date(today)
SORT due ASC
```

### Active Blockers
```dataview
TASK
FROM "myna/Projects"
WHERE !completed AND type = "blocker"
GROUP BY file.link
```
