---
topic: "Preview ghosts of mating parts are preferred"
importance: medium
category: preference
tags: [openscad, preview, ghost, usability, parametrization]
created: 2026-09-09T13:52:00Z
model: z-ai/glm-5.3-flash
---

User liked the translucent phone ghost in phone-horn previews and wants
that pattern remembered: when a drawing mates with an external object
(phone, plaque, rod), render a translucent ghost of it in previews via
`%`-modifier inside `if ($preview && show_<part>)`, sized from the same
parameters as the mating interface. Keep it out of STL/CGAL geometry.
Add a `show_<part>` boolean parameter so it can be toggled.
