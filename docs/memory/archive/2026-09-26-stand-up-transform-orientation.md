---
topic: "Stand-up transforms: flat y=0 spine edge becomes the assembled top"
importance: medium
category: pattern
tags: [openscad, transforms, orientation, ghost, preview]
created: 2026-09-26T23:41:57Z
model: z-ai/glm-5.3-flash
---

In pot-stand.scad the ghost assembly uses rotate([90,0,0]) plus a
translate and a final mirror([0,0,1]), so assembled +z maps to flat
−y: the bar's spine edge (flat y=0) is the rail TOP, and flat +y
toward the feet points DOWN. Parts meant to rise above the assembled
stand (pot-support walls) must extend in flat −y from y=0; extending
in flat +y silently hangs them below the rail along the legs. Check
the mirror direction before placing anything on a stood-up part.
