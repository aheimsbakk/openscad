# Changelog

## [0.7.0] - 2026-09-09

- **why:** Add a passive phone-amplifier horn, then keep the blueprint generic for all drawings and fold the updated agent rules into one release
- **model:** openrouter/z-ai/glm-5.3-flash
- **tags:** audio, horn, blueprint, rules, governance, memory

### Added

- `drawings/audio/phone-horn.scad`: passive phone-amplifier horn with exponential flare derived from Webster's equation (`m = 4*pi*fc/c`), rectangular throat to octagonal mouth loft, flat bottom, and a slot lip that sets the phone insertion depth; defaults hit 500 Hz cutoff with mouth perimeter above the cutoff wavelength
- `previews/audio/phone-horn.png` full-geometry preview
- Preview ghost pattern for mating parts (translucent `%`-modifier block behind `$preview && show_<part>`), recorded in `docs/memory/` with the skin 3D-profile loft technique and the blueprint consent rule

### Changed

- `BLUEPRINT.md` is now drawing-agnostic: only repo-wide contracts remain (file structure, BOSL2 inclusion, preview requirements, CLI commands)
- `.opencode/RULES.md` restructured: rules renumbered, new "Commit Consent" rule (no commits, pushes, or PRs without explicit user request), new "Verification Gate" rule (run lint/typecheck/tests before completion), and sharper "Layer Boundaries" and "State Ownership & Concurrency" wording
- `.opencode/skills/wrap-up/SKILL.md` description trimmed; the Builder-to-QA handoff phrase is gone

### Removed

- `BLUEPRINT.md`: the two drawing-specific contracts ("Phone Horn Acoustic Model Contract", "Slide-in Plaque Interface Contract") and the concrete `audio/` category from the component hierarchy; that design intent lives in the `.scad` file headers and concrete paths in `CODEBASE.md`

## [0.6.0] - 2026-09-08

- **why:** Make the Customizer panel usable so users can tweak the box without editing code
- **model:** openrouter/z-ai/glm-5.3-flash
- **tags:** openscad, customizer, annotations, container

### Added

- Flush-left Customizer description line above every parameter in `drawings/container/stackable-box.scad`; the OpenSCAD parser only reads the single line directly above an assignment, so the old trailing comments never showed
- Slider ranges for the box dimensions (`length`, `width`, `height`, `corner_r`) and labeled dropdowns for `part` and `pattern`
- `Quality` tab describing the `$fn` rendering resolution
- Customizer annotation rules for OpenSCAD 2021.01 recorded in `docs/memory/` for future drawings

### Changed

- Customizer tabs renamed to plain names: `Parts to render`, `Dimensions`, `Pattern`, `Plaque pocket`
- Parameter descriptions shortened and "mm" references removed (all sizes are in millimeters by convention)
- CLI recipe comment indented so the Customizer no longer shows it as the `plaque_w` description

## [0.5.0] - 2026-09-05

- **why:** Let users print the box without the plaque pocket when no nameplate is needed
- **model:** openrouter/z-ai/glm-5.3-flash
- **tags:** openscad, container, plaque-pocket, parametrization

### Added

- `drawings/container/stackable-box.scad`: `plaque_pocket` true/false parameter; `false` renders a plain front wall so the op-art pattern covers all four sides

### Changed

- Pocket size asserts in `drawings/container/stackable-box.scad` now run only when `plaque_pocket = true`; stacking and lid asserts stay unconditional

## [0.4.0] - 2026-09-04

- **why:** Add a stackable vase-mode storage box with lid and slide-in plaque pocket
- **model:** openrouter/z-ai/glm-5.3-flash
- **tags:** openscad, container, vase-mode, stacking, plaque-pocket

### Added

- `drawings/container/stackable-box.scad`: vase-mode box, 60 x 60 x 30 mm, with a 1960s op-art stiffening pattern; prints as box, lid, or plaque via `-D 'part=...'`
- Front slide-in plaque pocket: the perimeter folds into lateral C-channels with retaining lips, a resting ledge, and an entry funnel; the plaque self-centers at half the box height
- Nesting stack: the top recess receives the box below with fit clearance; `stack_count` previews a multi-box stack
- Rounded lid wrapping the box lip with adjustable clearance (`lid_fit`)

### Changed

- `scripts/render-one.sh` and `scripts/render-all.sh`: fast OpenCSG preview by default; `FULL=1` switches to a full CGAL render with true geometry for release-quality PNGs

### Fixed

- Plaque pocket no longer carves into the back face: the cut is gated by a shared front-face test, so the back wall keeps the plain op-art pattern
- Corner arcs now carry true outward normals, removing the 0.22 mm notch in the stacking inset and creases in the pattern wave

## [0.3.0] - 2026-08-31

- **why:** Add a second clip drawing whose middle width and mouth gaps adjust smoothly without bend-rate artifacts
- **model:** openrouter/z-ai/glm-5.3-flash
- **tags:** openscad, clips, cable-organizer, parametric

### Added

- `drawings/clips/s-cable-organizer.scad`: S-shaped double-hook cable clip, 15 x 30 x 10 mm, holding one cable per hook (top loads from the right, bottom from the left)
- Centerline built from sin/cos arcs: hook arcs, curvature-matched quarter-ellipse transitions, flat middle; mouth gaps stay equal for every `tip_deg` value
- `mid_flat` and `tip_deg` parameters with derived valid range, clamping, and console warning
- `previews/clips/s-cable-organizer.png`: full CGAL release preview
- `scripts/bump-version.sh`: prepends a new version section instead of renaming the previous release header

## [0.2.1] - 2026-08-29

- **why:** Make the skadis generator easier to read and configure
- **model:** openrouter/z-ai/glm-5.3-flash
- **tags:** openscad, skadis, refactor, naming

### Changed

- `drawings/frames/skadis-generator.scad`: renamed all configuration variables to snake_case and regrouped them into Grid, Board, Corner Screw Holes, Slots, and Lattice
- Removed redundant unit comments; all dimensions are in millimeters
- Extracted `slots()` and `corner_positions()` helpers to remove duplicated slot and corner loops
- Removed unused `module capsule`; renamed the `c` parameter of `rounded_rectangle` to `center`
- Geometry verified unchanged after the refactor: identical volume and bounding box

## [0.2.0] - 2026-08-29

- **why:** Make previews faster without losing render quality
- **model:** openrouter/~deepseek/deepseek-v4-flash-latest
- **tags:** openscad, preview, render, resolution

### Changed

- `drawings/frames/rod-cage.scad` sets `$fs` and `$fa` conditionally on `$preview`: coarse facets in preview, fine facets in render and export

## [0.1.5] - 2026-08-16

- **why:** Fix outdated header documentation to match current code
- **model:** kompis/qwen-3.6-think-coding
- **tags:** openscad, documentation, header

### Changed

- Removed tapered peg references: no part uses tapered pegs in the current build
- Replaced "cap (tapered)" with "clip" in the parts list
- Added assembly step 7 describing clip usage
- Fixed peg clearance value: was 0.2mm (rod clearance), now 0.05mm (actual peg clearance)
- Removed "Peg variants" section describing unused tapered peg behavior

## [0.1.4] - 2026-08-16

- Renamed `clearance_aditional` to `clearance_additional` across all files
- Fixed `clearance_rod` comment: was "between pegs and holes," now correctly "between rod and rod holes"
- Fixed face-hole comment: was "holes for mating pegs," now correctly "additional rod holes"
- Fixed instantiation label: "tiny cap" renamed to "tube clip"
- Replaced label-only comments with intent-based explanations in `grid_node`, `clip`, and `small_pegs`

## [0.1.3] - 2026-08-14

- **why:** Improve code readability and documentation for the enclosure parts system
- **model:** kompis/qwen-3.6-think-coding-mtp
- **tags:** openscad, refactor, documentation, rename

### Changed

- Moved `drawings/enclosure-parts.scad` to `drawings/frames/rod-cage.scad`
- Renamed `dimension` to `node_size`, `hole_diameter` to `rod_hole_d`, `peg_diameter` to `peg_d`, `peg_length` to `peg_l`
- Renamed `peg_tip_diameter` to `peg_tip_d`, `face_normals` to `face_rotations`, `inner_ratio` to `ring_ratio`
- Renamed `corner_ring` module to `spacer`
- Split `cap` module into `frame_cap` (straight pegs) and `foil_cap` (tapered pegs)
- Renamed `piece` to `grid_node`, `stabilizator` to `rod_anchor`
- Fixed typos: `pice` → `piece`, `stabilizator` → `stabilizer`, `one_forth` → `one_fourth`
- Replaced magic number `size*1.415` with `size * sqrt(2)`, added `taper_ratio` and `ring_ratio` constants

### Fixed

- Removed `previews/` from `.gitignore` so preview PNGs are tracked in Git
- Removed obsolete commented-out `translate` call from instantiation section

### Added

- Assembly instructions and part descriptions in file header comment
- Inline comments explaining each module's purpose and parameters
- `scripts/bump-version.sh` for version management
- `README.md` with setup and usage instructions

## [0.1.0] - 2026-08-10

- Initial version of the enclosure parts connector system
