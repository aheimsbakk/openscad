---
name: wrap-up
description: Apply end-of-task ceremony for changelog, version bumping, and git commits. Use when a task is complete and ready for finalization — after the user says "wrap up", "commit", or "done", or when the Builder hands off to QA.
---

## What this skill does

Defines the shared end-of-task procedure: prepend a changelog entry, bump the
version, and commit with strict staging rules. Every agent that finalizes work
uses this same process.

---

## 1. Changelog entry (CHANGELOG.md)

**Format:** [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
— the most common changelog format on GitHub. Entries are in reverse
chronological order with versioned sections. Each version section uses
category headings for types of changes.

### Category headings

| Heading     | When to use                              |
|-------------|------------------------------------------|
| **Added**   | New features, files, public APIs         |
| **Changed** | Changes to existing functionality        |
| **Fixed**   | Bug fixes                                |
| **Removed** | Removed features, deprecated APIs        |
| **Security**| Vulnerability fixes                      |

### Changelog metadata

Each version entry includes changelog metadata in a bullet or inline block at
the top of the section. The metadata captures **why** (reason), **model**
(AI model identifier), and **tags** (categorization).

### Example entry

```markdown
# Changelog

## [0.2.1] - 2026-06-07

- **why:** Add user authentication to meet security requirements
- **model:** anthropic/claude-sonnet-4-20250514
- **tags:** auth, security, login

### Added

- Login endpoint with JWT token generation (`POST /api/auth/login`)
- Password hashing using bcrypt

### Changed

- User model now requires email verification before activation

### Fixed

- Session timeout not clearing on logout
```

Refer to the [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) spec
for the full format rules.

### Prepending rules

1. If `CHANGELOG.md` does not exist at the repository root, create it with a
   single `# Changelog` heading followed by the new entry.
2. If `CHANGELOG.md` already exists, insert the new version entry directly
   after the `# Changelog` heading (and any introductory paragraph, if
   present) — i.e. at the top of the version list.
3. Use the **exact bumped version** from Section 2 as the version header.
4. Use today's date in `YYYY-MM-DD` format (use the `date` command to get the
   current UTC date).
5. Include **why**, **model**, and **tags** as bullet points at the top of the
   version entry.
6. Write 1-4 bullet points under each category heading. Be specific: mention
   file paths, function names, or endpoints when relevant.
7. Use the clear-language skill to write changelog bullet points: active voice,
   short sentences, no filler.
8. **Safety:** No secrets, API keys, or prompt text.

---

## 2. Version bumping

Every finalized feature or bugfix MUST bump the version exactly once per task.

| Change type | Bump | Example |
|---|---|---|
| Bug fix, refactor | Patch (`0.0.x`) | `scripts/bump-version.sh patch` |
| New feature, enhancement | Minor (`0.x.0`) | `scripts/bump-version.sh minor` |
| Breaking change | Major (`x.0.0`) | `scripts/bump-version.sh major` |

**Tool:** Run `scripts/bump-version.sh [patch|minor|major]`.
If the script does not exist, the agent is authorized to create it.

**Rule:** Do NOT bump again when fixing QA failures in the same task. Bump
once only.

**Mention the new version in the changelog entry header.**

---

## 3. Workspace hygiene

Before committing, ensure the repository is clean:

- Add temporary build artifacts, dependency caches, and error logs (e.g.
  `.qa-error.log`) to `.gitignore`.
- **Never** add source code, configuration files (including `VERSION`), or
  documentation directories (including `docs/worklogs/` if present) to
  `.gitignore`. These must remain tracked by Git.

---

## 4. Git commit protocol

### Staging rules

- **Targeted staging only.** Use `git add <path/to/file1> <path/to/file2>`.
- **Forbidden:** `git add .`, `git commit -a`, and any wildcard staging.
- Stage only the specific files modified in this task, plus architecture
  files (`BLUEPRINT.md`, `CHANGELOG.md`) if they show as modified in `git status`.

### Pre-commit verification

1. Run `git status` and inspect the output.
2. If temporary files (e.g. `.qa-error.log`) are staged, run `git reset`
   to unstage them.
3. Confirm the staging area contains exactly the intended files.

### Commit message

Use the clear-language skill for commit messages. Follow Conventional Commits
format with a plain-language description that fits 50 characters or fewer and
uses imperative mood:

```
<type>(<scope>): <short summary in present tense, imperative>
```

Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `perf`

See the clear-language skill's "Commit messages" section for detailed rules on
summary line length, tense, and body format.

---

## 5. Execution sequence

Run these steps in order:

1. Workspace hygiene (update `.gitignore`)
2. Version bump (`scripts/bump-version.sh`)
3. Prepend the changelog entry to `CHANGELOG.md`
4. Run validation (`scripts/validate-changelog.sh`). If the script does not
   exist, the agent is authorized to create it.
5. Stage files explicitly (`git add <file> ...`)
6. Verify staging (`git status`)
7. Commit (`git commit -m "<message>"`)
