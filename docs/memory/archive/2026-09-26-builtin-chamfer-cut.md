---
topic: "Builtin 45-degree chamfer cuts via exact-hypotenuse prisms"
importance: medium
category: pattern
tags: [openscad, chamfer, csg, print-quality]
created: 2026-09-26T21:50:00Z
model: z-ai/glm-5.3-flash
---

To chamfer selected convex edges without BOSL2 masks, subtract a
triangular prism whose hypotenuse lies exactly on the 45-degree plane
through (c, 0) and (0, c): pad the prism legs outward by eps only, so
eps never shifts the chamfer plane itself. Center the linear_extrude,
then place one cut per edge with translate + mirror (z, y, and x axis
variants cover all edge directions). To chamfer a member that merges
into another (e.g. feet into a bar), chamfer it uniformly on all 12
edges and let the union refill the junction-side bevels: the visible
chamfer then terminates exactly at the mating face with no coplanar
seams, and the mating part's edges stay sharp. Prisms must overrun
shared corners so three-plane miters come out clean. Clamp the chamfer
size with the house echo warning so faces cannot degenerate.

Tried in pot-stand.scad (first tip-face only, then all foot edges) and
reverted both times after user review — the drawing is back to sharp
edges pending a new edge-treatment decision. Keep the technique for
future parts.
