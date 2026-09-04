---
topic: "Per-point wall displacement terms must be face-gated"
importance: medium
category: warning
tags: [openscad, displacement, skin, cgal, debugging]
created: 2026-09-03T18:57:52Z
model: z-ai/glm-5.3-flash
---

In displacement-based skin() walls (stackable-box.scad), a cut term gated
only by x/z windows applies to EVERY face those windows touch — the plaque
pocket cut silently applied to the box back too. Gate face-specific terms
with an explicit face test (is_front(p)). Debug trap: STL probes for flat
wall regions can miss geometry because the CGAL export merges coplanar
slices, leaving vertices only at fold boundaries — probe those boundaries
or use echo() on the outline function instead.
