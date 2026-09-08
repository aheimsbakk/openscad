---
topic: "OpenSCAD Customizer annotation rules (2021.01 parser)"
importance: high
category: pattern
tags: [openscad, customizer, annotations, parametrization]
created: 2026-09-08T18:26:47Z
model: z-ai/glm-5.3-flash
---

Customizer descriptions in .scad drawings: the parser (2021.01
src/comment.cpp) reads ONLY the single line immediately above an
assignment, and only if it starts with `//` at column 0 — no blank line,
no multi-line blocks (their last line would wrongly become the next
param's description), no indentation. Trailing same-line comments are
parsed exclusively as widget options `// [...]`; plain-text trailing
comments are ignored. Dropdown labels use `value:Label` order. Collection
stops at the first `{` (the `__Customizer_Limit__` module); `$fn` before
that point is a visible parameter and needs its own description line and
group tab. Indent auxiliary comment blocks (e.g. CLI recipes) so they
cannot be captured as descriptions.
