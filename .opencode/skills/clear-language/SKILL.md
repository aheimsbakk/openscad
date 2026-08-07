---
name: clear-language
description: Write documentation, error messages, API responses, commit messages, comments, and README files using plain language principles (ISO 24495-1:2023). Focuses on readability, scannability, and removing buzzwords so readers understand text quickly.
license: MIT
compatibility: opencode
metadata:
  standard: ISO 24495-1:2023
  audience: developers, technical writers
  applies-to: docs, errors, api, commits, comments, readme
---

## What this skill does

Apply plain language principles to any text written for a human reader. This
covers documentation, error messages, API responses, commit messages, inline
comments, and README files.

The goal: a reader understands the text on the first read without guessing.

---

## Core principles (ISO 24495-1:2023)

### 1. Know your reader

Before writing, ask:
- Who will read this? (end user, developer, ops engineer, first-time visitor)
- What do they already know?
- What do they need to do next?

Write for that specific reader. Do not write for every possible reader at once.

### 2. Serve the reader's purpose

Every sentence must help the reader do something or understand something.
Cut anything that exists only to sound thorough or professional.

### 3. Structure for scanning

Readers scan before they read. Help them find what they need fast.

- Put the most important information first (inverted pyramid)
- Use short paragraphs (3–5 lines maximum)
- Use headings that describe the content, not just label it
- Use numbered lists for steps, bullet lists for options or facts
- Use bold sparingly to highlight truly critical words or phrases
- Leave white space — dense walls of text get skipped

### 4. Use plain words

Choose the shorter, more common word when both are accurate. Flag and replace
these on every pass:

| Instead of                  | Use                          |
|-----------------------------|------------------------------|
| utilize / leverage          | use                          |
| implement / facilitate      | build, add, set up, help     |
| initiate / terminate        | start / stop                 |
| subsequently / aforementioned | then, next / (name it again) |
| in order to                 | to                           |
| due to the fact that        | because                      |
| functionality               | feature, behavior            |
| robust / performant         | (say what it handles / how fast) |
| scalable / seamless / intuitive | (explain specifically)   |
| synergy / paradigm / holistic / empower / streamline | (cut or rewrite) |
| solution / ecosystem / innovative / cutting-edge | (be specific) |

When a technical term is the right word, use it. Define it on first use if the
reader may not know it.

### 5. Write short, active sentences

- Prefer subject → verb → object order
- Use active voice: "The function returns an error" not "An error is returned"
- One idea per sentence
- Target 15–20 words per sentence on average; rarely exceed 30
- If a sentence needs a semicolon, consider splitting it

### 6. Be direct

- State the action, condition, or result plainly
- Do not hedge unless genuine uncertainty exists ("may" vs "will")
- Do not soften errors into mysteries ("something went wrong" → tell them what)
- Do not add filler: "Please note that…", "It is important to mention…", "As you can see…"

---

## Applying the skill by text type

### Error messages

A good error message answers three questions:
1. What happened?
2. Why did it happen?
3. What should the reader do next?

```
Bad:  An error occurred while processing your request.
Good: Could not connect to the database. Check that DATABASE_URL is set and
      the server is reachable, then try again.
```

Rules:
- Name the thing that failed specifically
- Give the cause if it is known
- Give one clear next step
- Use "you" and active voice
- Do not blame the user; describe the situation

### API responses

Error response bodies must be human-readable, not just machine-parseable.

```json
Bad:
{ "error": "ERR_VALIDATION_FAILED" }

Good:
{
  "error": "validation_failed",
  "message": "The 'email' field must be a valid email address.",
  "field": "email",
  "docs": "https://example.com/api/users#create"
}
```

Rules:
- `message` must be a complete, plain-language sentence
- Name the field or parameter that caused the problem
- Link to relevant documentation when helpful
- Do not expose stack traces or internal paths in production responses

### Commit messages

Follow Conventional Commits format with plain-language descriptions.

Structure:
```
<type>(<scope>): <short summary in present tense, imperative>

<optional body: why this change was made, not what changed>

<optional footer: breaking changes, issue refs>
```

Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `perf`

```
Bad:  fix: resolved the issue with the authentication module
Good: fix(auth): redirect to login when session token expires

Bad:  feat: implemented new functionality for user management
Good: feat(users): add bulk-delete endpoint for admin users
```

Rules:
- Summary line: 50 characters or fewer, no period at the end
- Use imperative mood: "add", "fix", "remove" — not "added", "fixed", "removed"
- Body explains *why*, not *what* (the diff shows what)
- Wrap body lines at 72 characters

### Inline comments

Comments explain *why*, not *what*. The code shows what.

```
Bad:  // increment i by 1
      i++

Good: // Retry up to 3 times because the upstream API occasionally drops the
      // first connection after an idle period.
      for (let i = 0; i < 3; i++) {
```

Rules:
- Only comment when the code is not self-explanatory
- Explain intent, edge cases, and non-obvious decisions
- Keep comments current — a stale comment is worse than none
- Use full sentences with punctuation in block comments
- Use short phrases for end-of-line comments

### README files

Structure every README in this order:

1. **What it is** — one sentence describing the tool or library
2. **What it does** — 2–4 bullet points of key capabilities
3. **Quick start** — the minimum steps to get something working
4. **Usage** — common examples with real, runnable code
5. **Configuration** — options, defaults, and environment variables
6. **Contributing** — how to report issues or submit changes

Rules:
- Put the quick start above the fold (before any badges, long descriptions, or philosophy)
- Use fenced code blocks with language tags for all code samples
- Show real commands with real output, not pseudocode
- Every heading must describe its content, not just label a section ("Install" is fine; "Installation Instructions for Various Operating Systems" is not)

### Documentation pages and guides

- Open with what the reader will be able to do after reading
- Use second person ("you") consistently
- Number sequential steps; do not use bullets for steps
- Put warnings and prerequisites before the steps they apply to, not after
- Provide a working example for every concept introduced
- End with common problems and their fixes if the topic is complex

---

## Revision checklist

Run through this before finalizing any text:

- [ ] First sentence tells the reader what this is or what to do
- [ ] Every word is necessary — nothing exists to sound thorough
- [ ] Sentences average under 25 words; voice is active
- [ ] Buzzwords and filler phrases are replaced with specific language
- [ ] A scanner can find the key point in under 5 seconds
- [ ] Errors state the cause and next step clearly
- [ ] Commit summary fits 50 characters and uses imperative mood
- [ ] README quick start is reachable without scrolling
