# OpenSCAD Drawing Library

My personal collection of parametric OpenSCAD drawings for 3D printing.

## Repo layout

```
drawings/               # OpenSCAD source files (.scad)
└── <category>/         # Logical grouping
    └── <name>.scad     # Single drawing file

previews/               # Generated preview PNGs (mirrors drawings/)
└── <category>/
    └── <name>.png
```

Each `.scad` file is a self-contained parametric drawing. Preview PNGs are generated artifacts that update when the source changes.

## Quick start

1. Install OpenSCAD: https://openscad.org/downloads.html
2. Open a `.scad` file in OpenSCAD
3. Press F5 to preview or F6 to render
4. Export to STL: File → Export → Export as STL

## Usage

Dimensions are defined as variables at the top of each file. Edit them to change the size.

Open a file and press F5 in OpenSCAD to see the current dimensions.

## Build scripts

```bash
# Fast preview of a single drawing (seconds)
./scripts/render-one.sh drawings/<category>/<name>.scad

# Fast preview of all drawings
./scripts/render-all.sh

# True-geometry render of a single drawing (minutes; use for finished parts)
FULL=1 ./scripts/render-one.sh drawings/<category>/<name>.scad
```

Fast previews skip expensive details guarded by `$preview` in the `.scad`
source (for example lattice bevels). `FULL=1` renders the exact geometry.

## Notes

- All dimensions are in millimeters (OpenSCAD default)
- Preview PNGs are generated artifacts. Regenerate them if the source changes.
