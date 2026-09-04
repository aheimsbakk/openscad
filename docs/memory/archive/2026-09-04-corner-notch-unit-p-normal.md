---
topic: "stackable-box corner notch: unit(p) is not the surface normal (fixed)"
importance: medium
category: warning
tags: [openscad, displacement, normals, skin, stacking]
created: 2026-09-04T08:12:00Z
model: z-ai/glm-5.3-flash
---

In stackable-box.scad, deriving displacement normals from point position
(unit(p), direction from the origin) cut a ~0.22 mm notch where the corner
arcs meet the front wall: stacking inset stepped at top/bottom and the
pattern wave creased vertically. Fixed by carrying true per-point outward
normals ([point, normal] pairs; arcs radial from their own centers, walls
axis-aligned, pocket [0,-1]) and exposing them via outline_raw(z) for
testing. Pattern: in displacement-based skin() walls, never derive normals
from origin distance on off-center rounded rects; pair points with normals
at construction time. Regression probe lives in .handoff/probe-tail.scad
(gitignored): asserts max normal turn <= one arc step and no protrusion
past the inset front plane.
