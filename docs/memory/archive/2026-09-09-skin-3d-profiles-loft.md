---
topic: "Lofted constant-wall horns via skin 3D profiles"
importance: medium
category: pattern
tags: [openscad, bosl2, skin, loft, walls, parametrization]
created: 2026-09-09T13:40:00Z
model: z-ai/glm-5.3-flash
---

BOSL2 skin() accepts 3D profiles (all 2D or all 3D), so lofted shells can
be built directly in final orientation (map section point (w, h) to
[xpos, w, h]) with no post-rotation. For a flat-bottomed shell with wall
t, the outer section is the inner octagon/rect grown by 2t in width and
2t in height, and any 45 deg corner cut grows by t*(2-sqrt(2)); sections
keep 8 vertices by clamping the corner cut to a small positive minimum at
the throat. A cavity skinned past both open ends (cap planes outside the
shell) differences cleanly; CGAL reports Simple: yes, Volumes: 2.
