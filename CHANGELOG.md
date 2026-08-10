# Changelog

## [0.1.2] - 2026-08-10

- **why:** Combine `frame_cap` and `foil_cap` into a single `cap` module
- **model:** kompis/qwen-3.6-think-coding-mtp
- **tags:** openscad, refactor, deduplication

### Changed

- Replaced `frame_cap` and `foil_cap` modules with single `cap(size, peg_d, peg_l, peg_tip_d=0)`
- `peg_tip_d=0` produces straight pegs (frame cap); `peg_tip_d>0` produces tapered pegs (foil cap)
- Updated instantiation calls and header comments to use `cap`

## [0.1.1] - 2026-08-10

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
