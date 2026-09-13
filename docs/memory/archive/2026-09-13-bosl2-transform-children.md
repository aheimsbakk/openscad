---
topic: "BOSL2 transforms need children, not argument-attached geometry"
importance: medium
category: warning
tags: [openscad, bosl2, transforms, syntax]
created: 2026-09-13T17:25:00Z
model: z-ai/glm-5.3-flash
---

In BOSL2, `up(z, some_module())` fails with "Module up() requires children":
OpenSCAD module invocations inside another module's argument list are not
children. Always attach geometry as a child: `up(z) some_module();` or
`up(z) { ... }`.

Tapered lofts between silhouettes: skin() needs matched vertex counts and
resampled correspondence shears/twists; a single hull over two offset slabs
is a chord blend that flattens rounded corners. For a true "same silhouette
scaled in" taper, stack thin hull pairs over progressively offset profiles
(hull is exact for convex silhouettes at small steps).

