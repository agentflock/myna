---
name: links
disable-model-invocation: true
description: Save and find links in the vault. Saves to the entity's Links section and the central index. Use for any link management request: "save link: [url] for [entity]", "find link for [topic]", "do I have a link for [project]?"
user-invocable: true
argument-hint: "save link: [url] for [entity] | find link: [query]"
---

If vault_path is not in context, read `~/.myna/config.yaml` first. If the file does not exist, tell the user to run `/myna:setup` and stop.

# links

Save and find links associated with projects or people. Every save writes to two places — the entity's file and the central index.

---

## Save Link

**Triggers:** "save link: [url] for [entity]", "save this link: [url]", "save link: [context] [url]"

**How:**
1. Extract the URL and any context the user provided.
2. Resolve the entity (project, person, meeting) from the context using fuzzy name resolution.
   - If entity is explicit ("for auth migration") → match to project.
   - If context clues exist ("save this dashboard — we use it for incident reviews") → infer entity.
   - If no context and no match → save to `_system/data/links.md` only (general reference).
3. Infer a title from the URL or ask the user if unclear.
4. Write to all relevant destinations:
   a. Each resolved entity's `## Links` section (one or more — a link can belong to both a project and a person)
   b. `_system/data/links.md` → central index (always)

**Entity Links section entry:**
```
- [{YYYY-MM-DD}] [{title}]({url}) — {description}
```

**Central index entry** (`_system/data/links.md`):
```
- [{YYYY-MM-DD}] [{title}]({url}) — {description} — {entity: [[Projects/project-slug]] or [[People/person-slug]] or general}
```

**Worked example:**

User: "save link: https://runbook.internal/auth-migration for auth migration"

1. Resolve: auth migration → `Projects/auth-migration.md`
2. Infer title: "Auth Migration Runbook"
3. Write to `Projects/auth-migration.md` Links section:
   `- [2026-04-05] [Auth Migration Runbook](https://runbook.internal/auth-migration) — runbook`
4. Write to `_system/data/links.md`:
   `- [2026-04-05] [Auth Migration Runbook](https://runbook.internal/auth-migration) — runbook — [[Projects/auth-migration]]`

Output: "Saved link to [[Projects/auth-migration]] and central index [[_system/data/links]]."

---

## Find Link

**Triggers:** "find link: [query]", "do I have a link for [entity]?"

**How:**
1. Search `_system/data/links.md` for entries matching the query (title, description, or entity).
2. Also search the `## Links` section of the resolved entity file (if entity is named).
3. Return matching entries inline. If no matches: "No saved links found for '[query]'."

---

## Edge Cases

**No entity match:** Save to central index only as a general reference. Note: "Saved to central index — no matching project or person found."

**URL title unclear:** Ask: "What's a good title for this link?"

**Duplicate URL:** Check central index before writing. If the URL already exists: "This link is already saved — [[existing entry]]. Want to update the description?"
