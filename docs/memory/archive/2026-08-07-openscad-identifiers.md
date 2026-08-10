---
topic: "OpenSCAD identifiers cannot use hyphens"
importance: high
category: warning
tags: [openscad, syntax, identifiers]
created: 2026-08-07T16:20:00Z
model: kompis/qwen-3.6-think-coding
---

OpenSCAD module names, variable names, and function names cannot contain hyphens. Hyphens are parsed as the subtraction operator. Use underscores instead (e.g., `isometric_grid_plate` not `isometric-grid-plate`). This applies to all identifiers in .scad files.
