---
dashboard: delegations
---
#dashboard

## Delegations

### All Open
```dataview
TASK
FROM "myna"
WHERE !completed AND type = "delegation"
SORT due ASC
```

### Overdue
```dataview
TASK
FROM "myna"
WHERE !completed AND type = "delegation" AND due < date(today)
SORT due ASC
```

### By Person
```dataview
TASK
FROM "myna"
WHERE !completed AND type = "delegation"
GROUP BY person
SORT due ASC
```
