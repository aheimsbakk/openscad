---
topic: "Stackable box nesting fit: insert inset = recess inset - fit"
importance: medium
category: pattern
tags: [openscad, stacking, vase-mode, parametrization]
created: 2026-09-03T18:24:18Z
model: z-ai/glm-5.3-flash
---

Vase-mode nesting in stackable-box.scad: the top recess is inset
`stack_inset` over `stack_depth`; the bottom insert is inset
`stack_inset - stack_fit`. The insert must be inset LESS than the recess,
or the upper box falls through the ledge instead of resting on it. Suppress
the op-art pattern in both zones (`base_zone`, `neck_zone`) so the fit
surfaces stay smooth; pattern waves near flat edges otherwise reach ~0.3 mm
and can eat the 0.4 mm clearance. CLI `-D part=box` must be quoted:
`-D 'part="box"'`.
