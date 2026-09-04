---
topic: "stackable-box lid is a snug lip-wrap cap; pocket auto-centering"
importance: high
category: decision
tags: [openscad, vase-mode, lid, pocket, parametrization]
created: 2026-09-03T20:16:23Z
model: z-ai/glm-5.3-flash
---

stackable-box.scad lid redesign: single rounded cap wrapping the lip (the
recessed top band), footprint `length - 2*stack_inset + 2*lid_fit` per side,
height `lid_h = stack_depth` (derived). Removed `lid_rim_h`, `lid_plate_t`,
`lid_ledger` (old plate/ledger design). Default `lid_fit = 0.8` mm, min 0.65
(line width + tolerance). Bracket/slot fade ends at `z_lid_seat = height -
stack_depth`. `pocket_z` is derived: clamp `height/2` into `[sd+sb+4+
plaque_h/2, z_neck0 - guide_h - plaque_h/2]`. Small-box recipe (50x50x25):
`-D 'length=50' -D 'width=50' -D 'height=25' -D 'stack_depth=4'
-D 'stack_blend=1.5' -D 'plaque_h=6' -D 'guide_h=2'`.
