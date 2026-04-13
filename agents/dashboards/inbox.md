---
dashboard: inbox
---
#dashboard

## Inbox

### Reply Needed
```dataview
TASK
FROM "myna"
WHERE !completed AND type = "reply-needed"
SORT due ASC
```

### Delegations Waiting
```dataview
TASK
FROM "myna"
WHERE !completed AND type = "delegation"
SORT due ASC
```

### Review Queue
```dataview
TASK
FROM "myna"
WHERE !completed AND type = "review"
SORT due ASC
```
