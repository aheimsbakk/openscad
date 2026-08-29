---
topic: "chamfer_cylinder_mask only correct at 45 degrees"
importance: medium
category: warning
tags: [openscad, bosl2, chamfer, masks]
created: 2026-08-29T22:09:41Z
model: z-ai/glm-5.3-flash
---

In the vendored BOSL2 (lib/BOSL2), `chamfer_cylinder_mask(r, chamfer, ang)`
produces a stepped counterbore instead of a cone taper when ang != 45: the
mask's internal `ch = chamfer*tan(90-ang)` disagrees with `cyl()`'s
chamfang interpretation, leaving a ledge at the mask's mid-plane. It also
asserts when chamfer > r (wide countersinks from small holes are
impossible). Use an anchored `cyl()` frustum (`anchor=TOP` at the face)
for non-45-degree hole chamfers instead.
