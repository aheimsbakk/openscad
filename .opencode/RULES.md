# Master Project Rules

> **Conflict resolution:** When rules conflict, prioritize in this order: **Security (II) > Scoping (I.3) > Architecture (III) > Development (IV) > Documentation (V).**

## I. Workflow & Scoping
1. **Protocol Alignment:** Project-specific protocols (`.opencode/RULES.md`, `AGENTS.md`) are the absolute source of truth. Read them first and always follow their defined workflows.
2. **English-Only Artifacts:** All code, variables, comments, commits, and documentation MUST be in professional English, regardless of the chat language used.
3. **Strict Scoping:** Make surgical edits only. Do NOT perform "drive-by" refactoring or change existing logic outside the immediate scope of the task.
4. **Verify Before Acting:** Always read a file before editing it. Never import packages, modules, or APIs without first verifying they exist in the project's dependencies. Never fabricate function signatures, class definitions, or assume code structure without reading the source.

## II. Security & Data Hygiene
5. **Secrets & Logging:** Always use environment variables for secrets; never hardcode them. Do not log sensitive user data or tokens. Use obviously fake data (e.g., `test-token-123`) for tests.
6. **Safe Execution & Input Validation:** Validate and sanitize ALL external inputs. Use parameterized queries to prevent injection. Always use safe, statically-analyzable code execution; `eval()` and dynamic string execution are forbidden.
7. **Authorization:** Assume all endpoints are private by default. Always verify ownership/authorization, not just authentication. Store sensitive state exclusively in encrypted or access-controlled storage.
8. **System & Dependency Isolation:** Always isolate dependencies using project-level virtual environments, containers, or local `node_modules`. Never install dependencies globally or modify the host OS (e.g., `--break-system-packages`, `npm install -g`).

## III. Architecture & Reliability
9. **Strict Boundaries & SRP:** Files and modules MUST follow the Single Responsibility Principle. Keep client-side and server-side logic separate, and keep different business domains in separate files (e.g., routing, database schemas, and business logic).
10. **Naming Conventions:** Use `kebab-case` for file and directory names unless the project's `AGENTS.md` or `BLUEPRINT.md` specifies a different convention (e.g., `PascalCase` for React components). Be consistent within each module.
11. **Error Handling:** Every `catch` block must either handle the error meaningfully or re-throw it; empty `catch` blocks are forbidden. Isolate faults to prevent app-wide crashes. Provide clear, user-facing fallback behavior when external dependencies fail.
12. **Network & Async Resilience:** Apply timeouts to all network requests and external API calls. Use debouncing or throttling for user-triggered async operations. Validate asynchronous state to prevent race conditions.
13. **Resource Cleanup:** Always close database connections, file streams, and network sockets explicitly, or use automatic context managers (e.g., `with`, `using`, `try-with-resources`). Implement teardown logic for event listeners, background tasks, and intervals.
14. **Bounded Caches & Memory:** Never use unbounded in-memory caches or endlessly append to global collections. Always enforce size limits or TTLs (Time-To-Live) on caches and buffers.
15. **State Management:** Manage state mutations unidirectionally and defensively. Implement concurrency controls and race-condition guards for rapid asynchronous events (user inputs, network requests, background jobs).
16. **Presentation & Logic Separation:** Isolate presentation/I/O handling from core business logic. Keep them in separate modules.
17. **Modular File Structure:** If a file reaches 200 lines, it MUST be reviewed for splitting into smaller focused modules with proper imports/exports before further changes are made. Any file that exceeds 300 lines MUST be split immediately. Exception: data schemas, test suites, and configuration files.
18. **DRY & Reusability:** If the same logic appears twice, extract it into a reusable helper, utility module, or shared component. Do not copy-paste blocks of code across files.

## IV. Development & Maintenance
19. **Test-Driven Fixes:** When fixing bugs, write a failing unit test that reproduces the issue BEFORE modifying application code. Exception: documentation-only or trivial formatting changes do not require a test.
20. **Workspace Hygiene & Gitignore:** The repository MUST remain clean. All temporary AI-generated workflow files (e.g., `.handoff/`), build artifacts, dependency caches, environment files (e.g., `.env`), and virtual environment directories (e.g., `venv/`, `.venv/`) MUST be declared in `.gitignore`. The agent generating the files is responsible for updating `.gitignore` before task completion.
21. **Explicit Registry & Asset Tracking:** Whenever you create, rename, or delete files, immediately update any central registries, manifests, index exports, or cache lists that depend on them (e.g., service worker arrays, `__init__.py` exports, router definitions). Never leave orphaned references.
22. **Backward Compatibility:** Do not break existing callers; use fallbacks for changed signatures. Flag major component replacements with `@deprecated` instead of instant deletion.
23. **Dependencies:** Use explicit, stable package versions (no `latest` or wildcards). Always sync manifests and lockfiles. Prefer native code over adding small, unnecessary dependencies.
24. **Automation & Scripting:** When creating utility scripts (e.g., in `scripts/`), ensure they are executable (`chmod +x <path>`). Document each script's purpose, required arguments, and usage examples in `README.md`.

## V. Documentation & Formatting
25. **Strict Templating:** Strictly adhere to required formats (e.g., YAML front-matter in worklogs). Do not invent new fields, change key casing, or exceed length limits.
26. **Synchronized Docs:** Code and docs must match. Immediately update inline comments, `README.md`, api and protocol documentation, developer guides, and `.env.example` when changing logic or adding variables.
27. **Intent-Based Commenting:** Comments must explain the architectural decisions, edge cases, and business logic context (the "why"), rather than reiterating the syntax or mechanics (the "what"). Implement standard documentation blocks (e.g., JSDoc, PEP-257 docstrings) for all public APIs, class definitions, and shared utility functions. Commented-out source code is strictly prohibited; rely on version control for historical reference.
