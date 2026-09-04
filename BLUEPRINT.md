# Blueprint: OpenSCAD Drawing Library

## System Goals

A version-controlled library of parametric OpenSCAD (.scad) drawings intended for 3D printing. Each drawing is a self-contained source file with preview images and metadata. The repository supports generation of preview PNGs and STL exports via the `openscad` CLI.

## Component Hierarchy

```
Repository Root
├── drawings/               # All OpenSCAD source files
│   └── <category>/        # Logical grouping (optional)
│       └── <name>.scad    # Single drawing file
├── previews/               # Generated preview PNGs (one per .scad)
│   └── <category>/
│       └── <name>.png
├── scripts/                # Build and utility scripts
│   ├── render-all.sh       # Batch-generate previews for all drawings
│   └── render-one.sh       # Generate preview for a single .scad file
├── lib/
│   └── BOSL2/              # Vendored BOSL2 OpenSCAD library (read-only)
├── docs/                   # Project documentation
├── BLUEPRINT.md            # This file
├── CODEBASE.md             # Physical file-to-component mapping
├── .gitignore              # Excludes previews/ and build artifacts
└── AGENTS.md               # Agent workflow rules
```

## Data Flow

```
User requests a drawing
        │
        ▼
Agent writes <name>.scad into drawings/<category>/
        │
        ▼
Agent runs openscad CLI to generate preview PNG
        │
        ▼
PNG saved to previews/<category>/<name>.png
        │
        ▼
Agent updates CODEBASE.md with new file paths
```

### Preview Guarding

Expensive geometry (e.g. offset sweeps with high vertex counts) is skipped
in fast previews. Guard such features with `$preview` in the source:
`$preview` is true in OpenCSG preview mode and false under `--render` and
STL export, so full renders and exports always produce true geometry.
Preview PNGs in `previews/` may omit guarded details.

## State Management

- Each drawing is a single `.scad` file. No shared state between drawings.
- Variables at the top of each file define all dimensions (parameters).
- Preview images are generated artifacts, not source. They are regenerated when the source changes.
- No database or persistent state. Git is the source of truth.

## Contracts

### Drawing File Contract (`.scad`)

Every `.scad` file must follow this structure:

1. **Header comment** — One-line description, purpose, and any notes.
2. **Parameters section** — All dimensions defined as named variables at the top of the file.
3. **Module definition** — The main geometry wrapped in a named module.
4. **Instantiation** — The module called once at the bottom of the file.

### Slide-in Plaque Interface Contract

Drawings providing removable identification plaques must satisfy:
- Lateral retention channels forming opposing C-profile guides: each channel contains a back wall, lateral boundary stop, and inward-projecting retention lip that constrains plaque translation and rotation.
- A lower bearing ledge transverse to the insertion axis that arrests insertion at the seated position.
- An upper entry funnel facilitating top-down insertion.
- Continuous boundary topology: when single-perimeter continuous fabrication (vase mode) is targeted, all retention guides and ledges must form a contiguous, non-self-intersecting loop without unprintable horizontal overhangs.

Drawings MAY include the vendored BOSL2 library via
`include <../../lib/BOSL2/std.scad>` (adjust the relative depth to the
drawing's directory depth). Library use is optional; drawings without
library needs remain builtin-only. Expensive library-generated features
MUST be guarded with `$preview` (see Preview Guarding below).

Example structure:

```
// <One-line description>
// Purpose: <what this part is for>

// ================= PARAMETERS =================
wall = 2.0;
width = 50;
height = 30;

// ================= MAIN MODULE =================
module <name>() {
    // geometry here
}

// ================= INSTANTIATION =================
<name>();
```

### Preview Image Contract

- Fast preview (default): `openscad --autocenter --viewall` without `--render`.
  OpenCSG preview, finishes in seconds. Details guarded by `$preview` in the
  source may be omitted.
- Full render (`FULL=1` in the scripts): `openscad --render --autocenter --viewall`.
  True geometry; use for the release preview of a finished drawing.
- Output path mirrors the source path under `previews/`.
- PNG format, minimum 1200x900 pixels.
- Camera angle: isometric or three-quarter view (default OpenSCAD perspective).

### CLI Generation Commands

Generate a fast preview:
```
openscad -o previews/<category>/<name>.png --autocenter --viewall --imgsize 1200,900 drawings/<category>/<name>.scad
```

Generate a full-geometry preview:
```
openscad -o previews/<category>/<name>.png --render --autocenter --viewall --imgsize 1200,900 drawings/<category>/<name>.scad
```

Generate an STL for 3D printing:
```
openscad -o drawings/<category>/<name>.stl --export-format binstl drawings/<category>/<name>.scad
```

## Persistence

No persistent storage. All drawings are plain text `.scad` files stored in Git.

## External Dependencies

- **OpenSCAD** — Available on the host system (`/usr/bin/openscad`). Used via CLI, no GUI.
- **BOSL2** — Vendored OpenSCAD library at `lib/BOSL2/`, included from drawings
  with a relative path (`include <../../lib/BOSL2/std.scad>`). Read-only:
  never modify library sources. Used for chamfers, rounding, offsets, and
  sweeps (`rounding.scad`, `masks.scad`, `shapes2d.scad`). Minimum host
  requirement: OpenSCAD 2021.01.
- **Reference documentation** — OpenSCAD User Manual: https://en.wikibooks.org/wiki/OpenSCAD_User_Manual
  - Language Reference: https://en.wikibooks.org/wiki/OpenSCAD_User_Manual#The_OpenSCAD_Language_Reference
  - CLI Usage: https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Using_OpenSCAD_in_a_command_line_environment
  - Primitive Solids: https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Primitive_Solids
  - Transformations: https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Transformations
  - CSG Modelling: https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/CSG_Modelling

## Error Boundaries

- If a `.scad` file has a syntax error, `openscad` exits with non-zero status. The agent must read the error output and fix the file.
- If preview generation fails, the agent retries with corrected source. No drawing is considered complete without a successful preview.
- Preview images are excluded from `.gitignore` — they are tracked in Git as reference artifacts.

## Naming Conventions

- File and directory names: `kebab-case` (e.g., `wall-mount-bracket.scad`, `cable-clip`).
- Categories are optional. Use them when a drawing belongs to a clear group (e.g., `fasteners/`, `mounts/`, `connectors/`).
- Preview PNG paths must mirror the source `.scad` path exactly.

## Build & Utility Scripts

### `scripts/render-one.sh`

Generates a preview PNG for a single `.scad` file.

**Arguments:**
- `$1` — Path to the `.scad` file relative to repository root.

**Usage:**
```
./scripts/render-one.sh drawings/brackets/wall-mount.scad
```

### `scripts/render-all.sh`

Generates preview PNGs for all `.scad` files in the repository.

**Usage:**
```
./scripts/render-all.sh
```
