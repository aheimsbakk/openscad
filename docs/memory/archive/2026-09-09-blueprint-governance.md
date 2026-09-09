---
topic: "BLUEPRINT.md changes require explicit user consent"
importance: high
category: preference
tags: [blueprint, governance, consent, documentation]
created: 2026-09-09T14:05:00Z
model: z-ai/glm-5.3-flash
---

BLUEPRINT.md must stay generic for all drawings in the repository: no
contracts, models, or geometry rules tied to specific drawings belong
there; per-drawing design intent lives in the .scad file headers, and
concrete paths live in CODEBASE.md. Never edit BLUEPRINT.md without the
user's explicit consent — propose the change first and wait for approval.
