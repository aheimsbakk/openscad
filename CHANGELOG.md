# Changelog

## [0.1.3] - 2026-08-14

- **why:** Separate clearance into per-component values for more accurate tolerances
- **model:** kompis/qwen-3.6-think-coding
- **tags:** openscad, tolerance, clearance

### Changed

- Split single `clearance` variable into `clearance_rod`, `clearance_aditional`, and `clearance_peg`
- Rod holes now use `clearance_rod + clearance_aditional` for easier assembly
- Peg holes use `clearance_peg` for tighter fit
- Spacer `ring_ratio` changed from 1.66 to 1.5
- Commented out `cap` instantiation in `drawings/frames/rod-cage.scad`

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
