---
dashboard: reminders
---
#dashboard

## Reminders

> Reminders live in `_system/data/reminders.md`. Each is a typed checkbox with a 📅 due date.
> Fire-once: check off a reminder in Obsidian (or via "daily brief") when it has been surfaced.

### Due Today

```dataview
TASK
FROM "myna/_system/data/reminders"
WHERE !completed AND type = "reminder" AND due = date(today)
SORT time ASC
```

### Overdue (Missed)

```dataview
TASK
FROM "myna/_system/data/reminders"
WHERE !completed AND type = "reminder" AND due < date(today)
SORT due ASC
```

### Upcoming (Next 7 Days)

```dataview
TASK
FROM "myna/_system/data/reminders"
WHERE !completed AND type = "reminder" AND due > date(today) AND due <= date(today) + dur(7 days)
SORT due ASC
```

### All Pending

```dataview
TASK
FROM "myna/_system/data/reminders"
WHERE !completed AND type = "reminder"
SORT due ASC
```

### Delivered (Recent)

```dataview
TASK
FROM "myna/_system/data/reminders"
WHERE completed AND type = "reminder" AND due >= date(today) - dur(7 days)
SORT due DESC
```
