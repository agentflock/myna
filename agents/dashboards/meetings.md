---
dashboard: meetings
---
#dashboard

## Meetings

### This Week
```dataview
TABLE file.link AS "Meeting", date AS "Date"
FROM "myna/Meetings"
WHERE date >= date(today) AND date <= date(today) + dur(7 days)
SORT date ASC
```

### Unprocessed (no notes written)
```dataview
TABLE file.link AS "Meeting", date AS "Date"
FROM "myna/Meetings"
WHERE date < date(today) AND !processed
SORT date DESC
```

### Recurring
```dataview
TABLE file.link AS "Meeting"
FROM "myna/Meetings/Recurring"
SORT file.name ASC
```
