---
topic: "OpenSCAD module braces, BOSL2 region booleans, chained offsets vs CGAL"
importance: high
category: warning
tags: [openscad, bosl2, modules, regions, cgal, offsets]
created: 2026-09-13T19:10:00Z
model: z-ai/glm-5.3-flash
---

Three footguns from the travel-porage-container work:

1. A brace-less module body binds only the NEXT statement; later
   statements (e.g. `if (bead) ...`) become top-level code outside the
   module and escape all transforms. Always brace multi-part modules.
2. BOSL2 regions (lists of 2D paths) must be combined with the
   argument-style functional booleans (`difference(regA, regB)`); native
   module-style booleans over region children silently yield EMPTY
   geometry.
3. Chained 2D offsets (`offset(offset(raw, r), d)`) create degenerate
   vertex structures: sweeps render fine but any 3D boolean on them hits
   "PolySet has nonplanar faces" + CGAL Nef assertion. Derive every
   silhouette with a SINGLE offset from a pre-sized raw footprint
   (`raw(delta)` grown by delta, then one `offset(r)`).
