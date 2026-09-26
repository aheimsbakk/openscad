---
topic: "Displacement terms gate by face via paired point lists"
importance: medium
category: pattern
tags: [openscad, displacement, skin, normals]
created: 2026-09-26T23:52:49Z
model: z-ai/glm-5.3-flash
---

In displacement-based skin() walls, per-point terms must apply to one
face only, or a feature (e.g. the plaque pocket) silently cuts other
walls too. stackable-box.scad gates by construction: it builds
face-specific [point, normal] point lists (front_l/front_r with normal
[0, -1]) instead of a shared face-test function. Debug trap: STL
probes on flat wall regions can miss geometry because the CGAL export
merges coplanar slices, leaving vertices only at fold boundaries —
probe those boundaries or use echo() on the outline function instead.
