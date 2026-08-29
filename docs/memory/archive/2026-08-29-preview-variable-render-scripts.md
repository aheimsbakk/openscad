---
topic: "$preview variable ignored under --render in repo scripts"
importance: low
category: pattern
tags: [openscad, preview, render-scripts]
created: 2026-08-29T12:47:27Z
model: openrouter/~deepseek/deepseek-v4-flash-latest
---

`$preview` is always false in the repo pipeline because render-one.sh and
render-all.sh pass `--render` (CGAL mode). The dynamic `$fs`/`$fa`
ternaries in rod-cage.scad only reduce detail in OpenCSG preview (GUI F5 or
CLI without `--render`, which requires Xvfb). STL export and scripted PNGs
keep full resolution.