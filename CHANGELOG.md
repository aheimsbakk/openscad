# Changelog

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
