---
topic: "Continuous container cavity shrinks seat-band wall"
importance: medium
category: decision
tags: [openscad, container, cavity, neck, parametrization]
created: 2026-09-15T00:00:00Z
model: openrouter/z-ai/glm-5.3-flash
---

In travel-porage-container.scad the internal cavity is one continuous
`inner` sweep from floor to rim (user requirement: inner space must be
uninterrupted). Consequence: in the lid-seat band the wall is only
`neck_inset` (= `lid_skirt_t + lid_fit`) thick, not `wall_t`. The
`wall_t > neck_inset + 0.4` assert guards this. The old
pocket-vs-neck-inset assert is obsolete.
