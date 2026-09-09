# Master Project Rules

> **Conflict resolution:** When rules conflict, prioritize in this order: **Security (II) > Scoping (I.2) > Architecture (III) > Development (IV) > Documentation (V).**

## I. Workflow & Scoping
1. **English-Only Artifacts:** All code, variables, comments, commits, and documentation MUST be in professional English, regardless of the chat language used.
2. **Strict Scoping:** Make surgical edits only. Do NOT perform "drive-by" refactoring or change existing logic outside the immediate scope of the task.
3. **Verify Before Acting:** Always read a file before editing it. Never import packages, modules, or APIs without first verifying they exist in the project's dependencies. Never fabricate function signatures, class definitions, or assume code structure without reading the source.

## II. Security & Data Hygiene
4. **Secrets & Logging:** Always use environment variables for secrets; never hardcode them. Do not log sensitive user data or tokens. Use obviously fake data (e.g., `test-token-123`) for tests.
5. **Safe Execution & Input Validation:** Validate and sanitize external inputs. Use parameterized queries to prevent injection. Always use safe, statically-analyzable code execution; `eval()` and dynamic string execution are forbidden.
6. **Authorization:** Assume all endpoints are private by default. Always verify ownership/authorization, not just authentication. Store sensitive state exclusively in encrypted or access-controlled storage.
7. **System & Dependency Isolation:** Always isolate dependencies using project-level virtual environments, containers, or local `node_modules`. Never install dependencies globally or modify the host OS (e.g., `--break-system-packages`, `npm install -g`).
8. **Commit Consent:** Never commit, push, or create PRs unless the user explicitly requests it. Task completion, workflow documents, or skill steps are not consent — ask first. Never force-push or rewrite shared history.

## III. Architecture & Reliability
9. **Layer Boundaries:** Each file MUST serve exactly one layer — input/output (handlers, CLI parsing), business logic, or presentation (rendering, formatting) — never a mix. Handlers delegate to services without embedding business rules; services never import web frameworks or UI libraries; presentation never opens database connections or network sockets. Different business domains and client/server code MUST live in separate files.
10. **Naming Conventions:** Use `kebab-case` for file and directory names unless the project's `AGENTS.md` or `BLUEPRINT.md` specifies a different convention (e.g., `PascalCase` for React components). Be consistent within each module.
11. **Error Handling:** Every `catch` block must either handle the error meaningfully or re-throw it; empty `catch` blocks are forbidden. Isolate faults to prevent app-wide crashes. Provide clear, user-facing fallback behavior when external dependencies fail.
12. **Network & Async Resilience:** Apply timeouts to all network requests and external API calls. Use debouncing or throttling for user-triggered async operations. Validate asynchronous state to prevent race conditions.
13. **Resource Cleanup:** Always close database connections, file streams, and network sockets explicitly, or use automatic context managers (e.g., `with`, `using`, `try-with-resources`). Implement teardown logic for event listeners, background tasks, and intervals.
14. **Bounded Caches & Memory:** Never use unbounded in-memory caches or endlessly append to global collections. Always enforce size limits or TTLs (Time-To-Live) on caches and buffers.
15. **State Ownership & Concurrency:** Shared mutable state (module-level variables, caches, singletons, connection pools) MUST have one owning module through which all writes pass; other modules read via its interface. Read-modify-write sequences on state shared across async contexts (handlers, background jobs, event listeners) MUST be guarded by a lock, queue, or atomic primitive. Assume operations will interleave.
16. **Modular File Structure:** If a file reaches 200 lines, it MUST be reviewed for splitting into smaller focused modules with proper imports/exports before further changes are made. Any file that exceeds 300 lines MUST be split immediately. Exception: data schemas, test suites, and configuration files.
17. **DRY & Reusability:** If the same logic appears twice, extract it into a reusable helper, utility module, or shared component. Do not copy-paste blocks of code across files.

## IV. Development & Maintenance
18. **Test-Driven Fixes:** When fixing bugs, reproduce → regression test → fix. If no test framework exists, state that explicitly and skip. Documentation-only or trivial formatting changes do not require a test.
19. **Verification Gate:** Before completion, run the project's lint, typecheck, and test commands — discovered from configuration, never assumed. Fix or report failures; never finish with failing or skipped checks. If tooling is absent, say so.
20. **Workspace Hygiene & Gitignore:** The repository MUST remain clean. All temporary AI-generated workflow files (e.g., `.handoff/`), build artifacts, dependency caches, environment files (e.g., `.env`), and virtual environment directories (e.g., `venv/`, `.venv/`) MUST be declared in `.gitignore`. The agent generating the files is responsible for updating `.gitignore` before task completion.
21. **Explicit Registry & Asset Tracking:** Whenever you create, rename, or delete files, immediately update any central registries, manifests, index exports, or cache lists that depend on them (e.g., service worker arrays, `__init__.py` exports, router definitions). Never leave orphaned references.
22. **Backward Compatibility:** Do not break existing callers; use fallbacks for changed signatures. Flag major component replacements with `@deprecated` instead of instant deletion.
23. **Dependencies:** Use explicit, stable package versions (no `latest` or wildcards). Always sync manifests and lockfiles. Prefer native code over adding small, unnecessary dependencies.
24. **Automation & Scripting:** When creating utility scripts (e.g., in `scripts/`), ensure they are executable (`chmod +x <path>`). Document each script's purpose, required arguments, and usage examples in `README.md`.

## V. Documentation & Formatting
25. **Strict Templating:** Strictly adhere to required formats (e.g., YAML front-matter in worklogs). Do not invent new fields, change key casing, or exceed length limits.
26. **Synchronized Docs:** Code and docs must match. Immediately update inline comments, `README.md`, api and protocol documentation, developer guides, and `.env.example` when changing logic or adding variables.
27. **Intent-Based Commenting:** Comments must explain the architectural decisions, edge cases, and business logic context (the "why"), rather than reiterating the syntax or mechanics (the "what"). Implement standard documentation blocks (e.g., JSDoc, PEP-257 docstrings) for all public APIs, class definitions, and shared utility functions. Commented-out source code is strictly prohibited; rely on version control for historical reference.
