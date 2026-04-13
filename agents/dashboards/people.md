---
dashboard: people
---
#dashboard

## People

### All People
```dataview
TABLE role AS "Role", team AS "Team", relationship AS "Relationship"
FROM "myna/People"
SORT file.name ASC
```

### Pending Feedback
```dataview
TABLE file.link AS "Person"
FROM "myna/People"
WHERE pending-feedback
SORT file.name ASC
```

### Open Items by Person
```dataview
TASK
FROM "myna/People"
WHERE !completed
GROUP BY file.link
```
