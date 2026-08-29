# Codebase: OpenSCAD Drawing Library

## Annotated Directory Tree

```
.
├── drawings/                      # OpenSCAD source files (kebab-case)
│   └── frames/                    # category: frames
│       └── rod-cage.scad          # interlocking rod-based enclosure frame
├── previews/                      # Generated preview PNGs (mirrors drawings/)
│   └── frames/
│       ├── rod-cage.png
│       └── skadis-generator.png
├── scripts/                       # Build and utility scripts
│   ├── render-one.sh              # Blueprint component: Render Script (single)
│   ├── render-all.sh              # Blueprint component: Render Script (batch)
│   └── verify_codebase_sync.sh    # Synchronization verification
├── docs/                          # Project documentation
├── BLUEPRINT.md                   # Language-agnostic architecture spec
├── CODEBASE.md                    # This file — physical path mappings
├── .gitignore                     # Excludes build artifacts and temp files
└── AGENTS.md                      # Agent workflow rules
```

## Physical Path Mappings

| Blueprint Component       | Physical Path                  |
|---------------------------|--------------------------------|
| Drawing (source)          | drawings/<category>/<name>.scad |
| Drawing (preview)         | previews/<category>/<name>.png  |
| Render Script (single)    | scripts/render-one.sh           |
| Render Script (batch)     | scripts/render-all.sh           |
| Architecture Spec         | BLUEPRINT.md                    |
| File Mapping              | CODEBASE.md                     |

## Specs

- **Language:** OpenSCAD (`.scad`)
- **Tool:** OpenSCAD CLI (`/usr/bin/openscad`)
- **Output formats:** PNG (preview), STL (3D print, binary)
- **Naming:** `kebab-case` for all files and directories
- **Dimensions:** Millimeters (OpenSCAD default, standard for 3D printing)

## Entry Points

- **Fast preview (default, seconds):** `./scripts/render-one.sh drawings/<category>/<name>.scad`
- **Full-geometry preview (`FULL=1`, minutes):** `FULL=1 ./scripts/render-one.sh drawings/<category>/<name>.scad`
- **Rendering all drawings:** `./scripts/render-all.sh` (same `FULL=1` option)
- **Generating STL:** `openscad -o drawings/<category>/<name>.stl --export-format binstl drawings/<category>/<name>.scad`

## Language Rationale

- OpenSCAD is a declarative, programmatic CAD tool. Drawings are source code, not binary files.
- Parameters at the top of each file make every drawing configurable without editing geometry code.
- The CLI supports headless preview and STL export, enabling fully automated generation.
- No build system or package manager required — plain text files in Git.

## Current Drawings

| Name | Category | Source Path | Preview Path |
|---|---|---|---|
| Rod Cage | frames | drawings/frames/rod-cage.scad | previews/frames/rod-cage.png |
| Skadis Generator | frames | drawings/frames/skadis-generator.scad | previews/frames/skadis-generator.png |
