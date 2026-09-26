---
topic: "Deriving displacement normals from unit(p) cuts corner notches"
importance: medium
category: warning
tags: [openscad, displacement, normals, skin]
created: 2026-09-26T23:52:49Z
model: z-ai/glm-5.3-flash
---

In stackable-box.scad, deriving displacement normals from point
position (unit(p), direction from the origin) cut a ~0.22 mm notch
where the corner arcs meet the front wall: stacking inset stepped at
top/bottom and the pattern wave creased vertically. Fix: pair every
point with its true outward normal at construction time ([point,
normal] lists; arcs radial from their own centers, walls
axis-aligned, pocket [0, -1]) and expose the pairs via outline_raw(z)
for testing. Never derive normals from origin distance on off-center
rounded rects.
