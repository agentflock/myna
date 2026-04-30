---
dashboard: weekly
---
#dashboard

## Weekly View

### This Week's Tasks
```dataview
TASK
FROM "myna"
WHERE !completed AND due >= date(sow) AND due <= date(eow)
SORT due ASC
```

### Completed This Week
```dataview
TASK
FROM "myna"
WHERE completed AND completion >= date(sow)
SORT completion DESC
```

### Weekly Notes
```dataview
TABLE file.link AS "Week"
FROM "myna/Journal"
WHERE type = "weekly"
SORT file.name DESC
LIMIT 8
```
