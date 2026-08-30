---
topic: "BOSL2 adopted for skadis-generator chamfers"
importance: high
category: decision
tags: [openscad, bosl2, chamfer, offset-sweep, performance]
created: 2026-08-29T22:09:41Z
model: z-ai/glm-5.3-flash
---

Skadis-generator chamfers refactored to BOSL2 (`include <../../lib/BOSL2/std.scad>`).
Lattice chamfer = `offset_sweep` of the void region with `os_chamfer(height=band,
width=-band)`: negative width offsets OUTWARD, which a void-cut sweep needs.
Set `check_valid=false` (thin-web dilation self-tangents). Web parts are kept
UN-unioned for rendering (native CSG union is fast); the region-level
`union()` (60 s at $fn=24, 4+ min at $fa=1) runs only inside the
$preview-guarded chamfer path. Hole/countersink chamfers use BOSL2 `cyl()`
frusta anchored with `anchor=TOP` on the face. Result: FULL render dropped
from ~15m49s (stepped chamfer) to ~1m54s, and the taper is exact instead of
4-step staircase. Flares now land fully on the face (old cones lost half
their flare above the board), so countersink pads use r = chamfer_d + L.
