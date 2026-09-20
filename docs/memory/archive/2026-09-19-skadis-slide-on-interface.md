---
topic: "Skadis slide-on box interface: tapered pockets, fin-top seat"
importance: high
category: decision
tags: [openscad, skadis, slide-on, vase-mode, interface]
created: 2026-09-19T22:44:09Z
model: z-ai/glm-5.3-flash
---

The slide-on mount works as: pegs replicate the standard Skadis snap profile
(4.6 mm thick, 5 mm tip, 20 mm long, after franpoli's reference library) and
seat ~8.5 mm proud of the board; the box back plane hovers `back_gap` (1.5 mm)
in front of the fin fronts. Each pocket on the box back tapers from a shallow
entry fold (clears the fin front, no snag) to a full wrap behind the fin front
(fit grip over the fin sides), and the pocket ceiling — the fold's top step —
seats on the fin top edge. The fin top edge crosses the fold line 4.8 mm below
the ceiling, so the assembled preview places fins at `bulb_top - 4.8 -
seat_clear`. Note: the peg body intersects the model solid (vase-mode prints
only the outer contour, so this is fine), and lib/BOSL2 is a git submodule
that may need `git submodule update --init` after a fresh clone.
