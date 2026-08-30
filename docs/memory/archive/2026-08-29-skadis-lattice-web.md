---
topic: "Skadis generator lattice pattern decision"
importance: medium
category: decision
tags: [openscad, skadis, lattice, 3d-printing, parametrization]
created: 2026-08-29T18:57:39Z
model: openrouter/~deepseek/deepseek-v4-flash-latest
---

The skadis-generator lattice uses rectangular (egg-crate) pockets, not
hexagonal: out-of-plane bending from hung tools favors continuous vertical
ribs over disconnected hexagonal cells. Implementation detail: pockets fill
the empty diamonds of the staggered slot grid with two interleaved grids
mirroring the slot loops, so pocket size derives from existing spacing
variables and the web around every slot is exactly `Web_Lattice_Beam_Width`.
Solid board stays the default; wall-mount cantilever loads mean the
perimeter frame and top edge rail stay solid. `Web_Lattice_Beam_Width` has
an upper bound enforced by `assert` (pocket size must stay positive).