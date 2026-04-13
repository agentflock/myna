---
dashboard: projects
---
#dashboard

## Projects

### Active
```dataview
TABLE status AS "Status", file.mtime AS "Last Updated"
FROM "myna/Projects"
WHERE status = "active"
SORT file.mtime DESC
```

### Open Tasks by Project
```dataview
TASK
FROM "myna/Projects"
WHERE !completed
GROUP BY file.link
SORT due ASC
```

### Overdue Tasks
```dataview
TASK
FROM "myna/Projects"
WHERE !completed AND due < date(today)
SORT due ASC
```
