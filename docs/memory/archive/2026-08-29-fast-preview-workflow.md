---
topic: "Fast preview workflow: $preview guard + FULL=1 render mode"
importance: high
category: pattern
tags: [openscad, preview, render-scripts, performance]
created: 2026-08-29T20:32:37Z
model: z-ai/glm-5.3-flash
---

OpenSCAD 2021.01 has no Manifold backend, so `--render` (CGAL) takes
minutes on lattice-heavy models. render-one.sh / render-all.sh now default
to OpenCSG preview (seconds, no `--render`); `FULL=1` opts into the full
CGAL render. Guard expensive features (e.g. layered offset chamfer cuts)
with `!$preview` in the .scad source: `$preview` is false under `--render`,
so full renders and STL exports keep true geometry, while fast previews
skip the cost. The preview PNG in previews/ may omit those details.
