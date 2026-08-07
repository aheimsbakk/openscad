---
name: todo-txt
description: Use to track tasks, todos, checklists, plans, a work log, or any task list. Manages tasks using todo.txt — a plain-text format with priorities, contexts, tags, and due dates.
compatibility: opencode
---

# todo.txt Skill

Default file: `todo.txt` in the workspace root. `done.txt` for archived completed tasks. Plain text only. Create the file if it does not exist.

## Format

One task per line. Keep each line short and atomic — one clear action. Split complex work into multiple tasks rather than writing a long description.

```
[priority] [creation-date] <description> [@context] [+tag] [key:value]
```

- **Priority** — `(A)`–`(Z)` at position 0, followed by a space. Lowercase, mid-line, or missing space disqualifies it.
- **Creation date** — `YYYY-MM-DD` immediately after priority+space, or at position 0 if no priority. Date elsewhere in the line is not a creation date.
- **Contexts** — `@word`, **Tags** — `+word`. Both preceded by a space; appear anywhere after the priority/date prefix.
- **key:value** — structured metadata; both key and value are non-whitespace, non-colon strings. Common: `due:YYYY-MM-DD`, `pri:A`, `t:YYYY-MM-DD`.

Completed tasks start with lowercase `x ` at position 0, followed by completion date, then creation date (if present), then the original description:

```
x 2026-05-20 2026-05-01 Fix login bug @frontend +bug pri:B
```

`X` (uppercase), `x` mid-line, or `x` without a trailing space do not mark completion.

## Sorting

The file MUST always be sorted. After every write, run:

```bash
sort todo.txt -o todo.txt
```

`-o` writes the result back in-place after reading is complete. Never use `> todo.txt` — it truncates the file before sort reads it. The format is designed so plain alphabetical sort produces the correct order: `(A)` < `(B)` < … < no-priority < `x` completed.

## Operations

Get today's date with `date +%Y-%m-%d` (portable; `date -I` is a GNU/Linux shorthand for the same).

**Add** — compose the new line with today's creation date, append it to the file, sort.

**Complete** — read the file, find the line, strip only the leading `(X) ` priority token if one is present (remove exactly `(X) ` — two characters plus a space — and nothing else), prepend `x YYYY-MM-DD ` (today). All remaining fields — creation date, description, contexts, tags, key:value pairs — stay in their original order. Optionally append `pri:X` to preserve the original priority. Write the file, sort.

**Edit / Delete** — read the file, modify or remove the line, write the file, sort.

**Archive** — run `grep '^x ' todo.txt >> done.txt && grep -v '^x ' todo.txt > todo.txt.tmp && mv todo.txt.tmp todo.txt` then sort `todo.txt`. The `^x ` pattern avoids false matches on words like `xylophone`.

**Filter** — grep for the token: `@context`, `+tag` (e.g. `grep '+tech-debt' todo.txt`), or `^(X) ` for a specific priority. To find tasks due on or before a date, grep for `due:` and compare values: `grep 'due:' todo.txt`; tasks are overdue if their `due:YYYY-MM-DD` value is earlier than today.

## Example

```
(A) 2026-05-19 Call insurance @phone +urgent +home-repair
(B) 2026-05-01 Write unit tests @backend +tech-debt due:2026-05-31
2026-05-18 Read chapter 4 +learning +book
x 2026-05-20 2026-05-18 Submit expense report @admin +finance pri:B
x 2026-05-19 Fix login redirect @frontend +bug
```
