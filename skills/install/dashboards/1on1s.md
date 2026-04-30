---
dashboard: 1on1s
---
#dashboard

## 1:1s

### All Direct Reports
```dataview
TABLE file.mtime AS "Last 1:1", person AS "Person"
FROM "myna/Meetings/1-1s"
SORT file.mtime DESC
```

### Open Action Items from 1:1s

#### Assigned to me
```dataview
TASK
FROM "myna/Meetings/1-1s"
WHERE !completed AND (type != "delegation")
SORT due ASC
```

#### Assigned to others
```dataview
TASK
FROM "myna/Meetings/1-1s"
WHERE !completed AND type = "delegation"
SORT due ASC
```

### Overdue Action Items

#### Assigned to me
```dataview
TASK
FROM "myna/Meetings/1-1s"
WHERE !completed AND due < date(today) AND (type != "delegation")
SORT due ASC
```

#### Assigned to others
```dataview
TASK
FROM "myna/Meetings/1-1s"
WHERE !completed AND due < date(today) AND type = "delegation"
SORT due ASC
```
