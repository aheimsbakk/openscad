---
topic: "Vase-mode sketches: the union silhouette is the design"
importance: high
category: warning
tags: [openscad, vase-mode, sketches, parametrization, ghosts]
created: 2026-09-13T16:58:11Z
model: z-ai/glm-5.3-flash
---

When a user's sketch is a solid union of primitives (e.g. cylinder + cube),
that silhouette IS the container — a vase-mode print where the slicer traces
the outer contour. Never reinterpret it as a shell with cut cavities or add
lids unless asked; parametrize the sketch's own geometry relations instead.
Also: % preview ghosts are invisible inside solids (occluded from all
angles), so the ghost pattern only applies when the mating part sits in an
open cavity. Confirm the intended print mode before redesigning a sketch.
