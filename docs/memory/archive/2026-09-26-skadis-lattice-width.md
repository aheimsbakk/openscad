---
topic: "Skadis generator rib lattice: lattice_width, on by default"
importance: medium
category: decision
tags: [openscad, skadis, lattice, 3d-printing]
created: 2026-09-26T23:52:49Z
model: z-ai/glm-5.3-flash
---

The skadis-generator board is cut to a rib lattice by default
(`enable_lattice = true`): border, X spokes, vertical rails, and a
material ring around every slot; `false` gives a solid board.
Rectangular ribs beat hexagonal cells because continuous ribs resist
out-of-plane bending from hung tools. The uniform web width is
`lattice_width` (the old `Web_Lattice_Beam_Width` name is gone). The
top-face bevel `lattice_chamfer_depth` erodes the web sideways, so
asserts keep it below `lattice_width / 2` minus a minimum top-face
sliver; thinner slivers make CGAL fail intermittently and do not
print.
