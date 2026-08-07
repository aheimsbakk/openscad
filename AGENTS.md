# Master Rules
- **Dependency:** Co-read:
    - `.opencode/RULES.md` - project‑specific constraints
    - `BLUEPRINT.md` - language‑agnostic architecture specification
    - `CODEBASE.md` - concrete file‑to‑component mapping
- **Workflow:** architecture -> implementation -> testing -> synchronization -> zero problems -> wrap-up

## General Constraints
- **CI/CD:** No `.github` workflows.
- **Commits:** Conventional Commits (`<type>(<scope>): <summary>`). Use `docs(sync):` for documentation updates.

## Blueprint Generation (Architecture)
Create a deterministic, language-agnostic specification.
- **Core:** Define System Goals, Component Hierarchy, Data Flow, and State Management.
- **Contracts:** Specify entry points, strict payload schemas, and error boundaries.
- **Persistence:** Define abstract schemas, memory layouts, and state trees.
- **External:** Detail env configs, auth flows, and hardware/service dependencies.
- **Prohibited:** No executable code, framework configs, or language-specific structures/pseudocode. Allow generic state machine logic.

## Codebase Generation (Mapping)
Map abstract architecture to concrete physical files.
- **Structure:** Annotated directory tree and physical path mappings for Blueprint components.
- **Specs:** Declare target languages, frameworks, dependency managers, and naming conventions.
- **Entry Points:** Provide exact paths for main loops, servers, or CLI scripts.
- **Language Rationale:** Document specific implementation choices, idioms, or structural adaptations required by the chosen language or framework.
- **Prohibited:** No abstract architectural design rationale. Limit rationale strictly to language/framework implementation mapping.

## Synchronization Protocol
- **Trigger:** Code changes altering system goals, hierarchy, state, or directory structure.
- **Action:** Update Blueprint architecture/contracts and Codebase repository maps/paths. Remove orphaned paths.
- **Verification:** Execute `scripts/verify_codebase_sync.sh` to validate `CODEBASE.md` physical paths.
- **Requirement:** Synchronization commits must precede final feature/fix commits.
