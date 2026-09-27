---
topic: "Ghost pot placement must derive from the crossing half's bar midpoint"
importance: medium
category: pattern
tags: [openscad, ghost, preview, transforms, parametrization]
created: 2026-09-27T01:07:09Z
model: z-ai/glm-5.3-flash
---

In pot-stand.scad the ghost pot axis must pass through the crossing
half's bar midpoint: x = bar_length/2, y = -(foot_length + slot_width/2
+ part_gap). The bar_length terms cancel in y, so the axis depends only
on foot_length, slot_width, part_gap — anchoring y to -bar_length/2
instead made the pot drift when sizes changed. When placing ghosts on a
transformed assembly, derive the position from the same translate
constants the assembly uses, never from a sibling dimension. Verify
placements with an ortho top view and a fixed --camera (7-param form):
--autocenter --viewall re-frames per bounding box and masks translation
between renders.
