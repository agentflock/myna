# Cross-Domain Interactions — Requirements

> Draft. To be refined after individual domain requirements are closer to final.

**Scope:** How the 7 domains connect — data flows, shared concepts, dependencies between features.

---

## Key Interactions to Define

### Email/Messaging → Projects & Tasks
- Email processing extracts action items → tasks
- Email processing updates project timelines with decisions, blockers
- Folder/channel → project mapping drives routing

### Email/Messaging → People
- Messages from known people update interaction history
- Recognition and feedback signals extracted from messages

### Meetings → Projects & Tasks
- Meeting debriefs create tasks (own and delegated)
- Decisions from meetings → project timeline entries

### Meetings → People
- Meeting debriefs extract observations about attendees
- 1:1 notes feed into person files

### Daily Workflow → Everything
- Morning sync pulls from calendar, tasks, review queue
- Daily note links to all active domains
- Planning reads from tasks, meetings, projects

### Self Tracking → Email/Messaging + Meetings + Projects + People
- Contributions extracted passively as other domains process data
- Pulls from meeting notes, project timelines, email threads
- Feedback you gave (tracked in self) also surfaces in the recipient's person file

### Review Queue (shared concept)
- Multiple domains write to review queue (email, meetings, self-tracking, people)
- Daily workflow processes the review queue
- Approved items route to their final destination across domains

---

<!-- Detailed data flows and dependencies to be added as domain requirements solidify -->
