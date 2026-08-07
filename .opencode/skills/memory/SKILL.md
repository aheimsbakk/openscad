---
name: memory
description: Load project context, conventions, preferences, and past decisions for the current session. Save decisions, patterns, warnings, and preferences for future sessions. Use before making architectural choices or when the user references past work.
compatibility: opencode
---

## When this loads

Read `docs/memory/INDEX.md`. Prune expired entries — delete the archive
file and remove the row for any entry whose `expires` has passed.

Find rows where `topic`, `tags`, or `category` match the current task.
If nothing matches on obvious keywords, try related terms once.

For any match, apply as context silently.

If nothing matches, proceed without memory.

## When to write

Write a memory entry when:
- The user states a preference or sets a rule
- A meaningful architectural decision is reached
- A non-obvious bug fix or pattern surfaces
- A footgun or deprecated path is discovered
- Before the session ends — save unfinished context

Skip if it's: single-session debug output, already captured in
`AGENTS.md` / `RULES.md` / `BLUEPRINT.md`, secrets, or prompt text.

---

## Memory file format

Path: `docs/memory/archive/YYYY-MM-DD-<short-slug>.md`

Required front matter: `topic`, `importance` (high/medium/low),
`category` (preference/decision/fact/pattern/warning),
`tags` (2–5 lowercase keywords; hyphens for multi-word),
`created` (ISO 8601 UTC), `model`. Optional: `expires` (ISO 8601 UTC).
Set `expires` only when the information has a known shelf life (e.g.
"this workaround applies until v2 ships"). Leave unset for permanent
decisions and preferences.

Body: 1–4 concrete, actionable sentences. Don't repeat front matter.

```markdown
---
topic: "Vitest preferred over Jest"
importance: high
category: preference
tags: [testing, vitest]
created: 2026-05-01T10:00:00Z
model: github-copilot/claude-sonnet-4.6
---

User prefers Vitest for all unit and integration tests. Run with
`--reporter=verbose`. Avoid snapshots unless explicitly requested.
```

---

## Writing a memory

1. **Check INDEX first.** Read `docs/memory/INDEX.md` (skip if already read
   this session). Look for an existing row on the same topic or overlapping
   subject.
   - Conflicts or supersedes existing → **update** (delete old file, remove
     its row, then write the new one).
   - Adds distinct context → write a new entry.
   - No match → write a new entry.

2. **Get timestamp:** `date -u +"%Y-%m-%dT%H:%M:%SZ"`. Use the date for
   the filename, full value for `created`.

3. **Write the file** to `docs/memory/archive/YYYY-MM-DD-<2–5-word-slug>.md`.

4. **Append a row to `docs/memory/INDEX.md`:**
   ```
   | <topic> | <category> | <importance> | <tags, comma-separated> | <expires or empty> | archive/<filename> |
   ```
   Without the INDEX row, the entry is invisible to future lookups.

Never overwrite in place — `created` must reflect the current version.
Never keep both versions of conflicting entries.

---

## Reading memory

When you need to look up a topic mid-session, follow the same steps as
"When this loads" above — read INDEX.md, prune expired entries, match by
topic/tags/category.

**Keyword search fallback** (when the index columns don't capture
what you need):

```
Grep pattern="<keyword>" include="docs/memory/archive/*.md"
```

---

## First-time setup

If `docs/memory/INDEX.md` doesn't exist, create the directory and seed
the index:

```bash
mkdir -p docs/memory/archive
```

```markdown
# Memory Index

| topic | category | importance | tags | expires | file |
|---|---|---|---|---|---|
```
