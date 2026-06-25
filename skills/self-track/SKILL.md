---
name: self-track
description: Log your contributions to the vault and query them by category, project, or date range. YOUR contributions only.
user-invocable: true
argument-hint: "log contribution: [description] | what did I do this quarter | what decisions did I make in March | how much feedback did I give this month | what did I do on [project]"
---

# myna-self-track

If vault_path is not in context, read `~/.myna/config.yaml` first. If the file does not exist, tell the user to run `/myna:setup` and stop.

Logs your contributions and lets you query them. Log what you did; query it later by category, project, or date range.

## 📋 Before You Start

Read at session start:
- `_system/config/workspace.yaml` — for `user.name` and `user.role` (context only — used to disambiguate ambiguous contributions, does not select categories)
- `_system/config/projects.yaml` — for cross-referencing project-level impact

**Contributions log path:** `Journal/contributions-{YYYY-W\d\d}.md` (ISO week, e.g. `contributions-2026-W18.md`).

---

## 📂 Contribution Categories

Five universal categories — role-agnostic. A junior IC and a VP both log in the same buckets.

- `delivery` — things you built, shipped, or completed: features, designs, documents, processes
- `decisions` — calls you made when a direction was needed: architecture, scope, escalations resolved
- `feedback` — developmental input you gave to others: code reviews, written feedback, growth conversations
- `people` — helping, growing, or unblocking others: mentoring, coaching, unblocking teammates, onboarding
- `quality` — making things more reliable, maintainable, or efficient: documentation, process improvements, risk mitigation, issue prevention

---

## ✍️ Log Contribution

**Trigger:** "log contribution: [description]", "I just [did something worth logging]"

**Entry format** (content-first, newest-first within the week):
```
- **{category}:** {description} [; result: {result}] ({source}, {user.name}, {YYYY-MM-DD})
```
`result` captures what changed because of this contribution. Include it when stated or confidently inferable. Omit when genuinely unknown — do not fabricate.

**How:**
1. Parse the contribution. Extract: description, date (today if not specified), source. Infer category from the description using the five universal categories above; use `user.role` as context when the description is ambiguous.
2. Infer `result` from the description if possible:
   - "resolved the P1 blocker" → result: P1 unblocked
   - "gave feedback on Sarah's API spec" → result: not inferable, omit
   - "shipped the auth migration" → result: auth migration live
3. Determine the ISO week number → `Journal/contributions-{YYYY-W\d\d}.md`.
   If file doesn't exist, create it:
```markdown
---
week: {YYYY-W\d\d}
---

#contributions

## Contributions — {YYYY-W\d\d}

> Newest-first. Each entry: category, description, result (if known), source, date.
```
4. **Write the entry immediately** — result or not. The entry is never held pending enrichment.
5. If `result` is missing or low-confidence: **also** add to `ReviewQueue/review-self.md`:
```
- [ ] Enrich contribution: "{description}"
  Logged: {YYYY-MM-DD} · {category}
  Inferred result: {inferred result, or "none inferred"}
  → confirm result | rewrite | skip (process as-is)
  ---
```
6. Confirm: "Logged: [{category}] {description}" — mention review queue only if an entry was added.

**The entry is written to the vault in step 4 regardless of what happens next.** The review queue is additive — it can improve the entry but never gates it.

Infer the category from the description. When ambiguous, pick the primary action — don't ask unless genuinely unclear.

**Worked example:**

User: "log contribution: led the auth migration design review and made the final call on the caching architecture"

1. Category: `decisions` (made the call).
2. Result: inferable — "caching architecture direction set, team unblocked."
3. ISO week: 2026-W14.
4. Prepend to `Journal/contributions-2026-W14.md`:
   `- **decisions:** Led auth migration design review and made final call on caching architecture; result: caching direction set, team unblocked (self-track, {user.name}, 2026-04-05)`
5. Result was inferred with reasonable confidence — no review queue entry needed.

Output: "Logged: [decisions] Led auth migration design review — caching direction set."

---

**Worked example (result missing):**

User: "log contribution: gave feedback to Sarah on her API spec"

1. Category: `feedback`.
2. Result: not inferable from description alone — omit.
3. Prepend to `Journal/contributions-2026-W14.md`:
   `- **feedback:** Gave feedback to Sarah on her API spec (self-track, {user.name}, 2026-04-05)`
4. Add to `ReviewQueue/review-self.md`:
```
- [ ] Enrich contribution: "Gave feedback to Sarah on her API spec"
  Logged: 2026-04-05 · feedback
  Inferred result: none inferred
  → confirm result | rewrite | skip (process as-is)
  ---
```

Output: "Logged: [feedback] Gave feedback to Sarah — added to review queue for result context (say 'skip' when reviewing to process as-is)."

---

## ⚠️ Edge Cases

**No contributions logged:** "No contributions found for that period. You can log them now with 'log contribution: [description]', or contributions are captured automatically during daily wrap-up."

**Uncertain contributions:** If a contribution can't be confirmed from explicit source data, note it once at the end in plain English — e.g., "2 entries couldn't be verified from source notes."

**Append-only:** Never overwrite or truncate an existing contributions file. New entries always prepend (newest-first). If the file header is missing, create it first, then prepend — never rewrite existing entries.
