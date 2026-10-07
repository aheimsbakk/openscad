---
topic: "Skadis universal hook: user-authored parametric version is the finished product"
importance: medium
category: decision
tags: [openscad, skadis, hook, parametrization]
created: 2026-10-07T19:34:39Z
model: kompis/qwen3.8-flash-next-iq3_s
---

The user wrote the parametric hook themselves (union of five 2D
squares, extruded 4.5 mm) and declared it finished. Do not rewrite it;
adjust parameters only when asked. Source reference: `docs/Hook_-_No_Filets.step`
(STEP analysis: 4.5 mm prism, 21-edge profile, degenerate B-splines).
Fit knobs: board_thickness, hole_clearance, part_thickness, spine_height,
locking_peg_height, protrusion_depth, hook_lip_height, hook_vertical_offset.
