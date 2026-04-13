---
dashboard: tasks
---
#dashboard

## Open Tasks

### Today
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

### Upcoming (next 7 days)
```dataview
TASK
FROM "myna"
WHERE !completed AND due > date(today) AND due <= date(today) + dur(7 days)
SORT due ASC
```

### Delegations
```dataview
TASK
FROM "myna"
WHERE !completed AND type = "delegation"
SORT due ASC
```
