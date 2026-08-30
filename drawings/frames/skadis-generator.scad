// Skadis pegboard generator
// Purpose: parametric Skadis-style pegboard for 3D printing. The slot grid,
// board size, and corner screw holes are configurable. An optional lattice
// cuts through the board, leaving only a border, a material ring around each
// slot, X spokes, and vertical rails to save filament.
// Uses the vendored BOSL2 library (lib/BOSL2) for region construction, the
// offset-sweep lattice chamfer, and frustum-based chamfers for slot ends
// and corner countersinks.

include <../../lib/BOSL2/std.scad>

// ================= PARAMETERS =================

/* [Grid] */
// Number of columns (horizontal direction).
number_of_columns = 6;
// Number of rows (vertical direction). An odd number keeps the top and
// bottom rows aligned, so the grid looks symmetric.
number_of_rows = 11;

/* [Board] */
board_thickness = 4.9;
board_corner_radius = 10;

/* [Corner Screw Holes] */
corner_screw_holes = false;
// Countersink the holes so flat-head screws sit flush with the face.
corner_screw_holes_chamfer = false;
corner_screw_holes_diameter = 3;
// Distance of each hole center from the two board edges it sits between.
corner_screw_holes_inset = 10;
corner_screw_holes_chamfer_diameter = 8;
// Depth of the countersink cone. Defaults to board_thickness / 6.
corner_screw_holes_chamfer_depth = board_thickness / 4;

/* [Slots] */
skadis_slot_width = 5;
skadis_slot_height = 15;
// Chamfer the slot openings so tools slide in more easily.
chamfer_skadis_slots = true;
// Depth of the slot-end chamfer flare. Defaults to board_thickness / 6.
slot_chamfer_depth = board_thickness / 6;

/* [Lattice] */
// Cut the board down to a border, X spokes, vertical rails, and slot rings
// to save filament. Disable for a solid board.
enable_lattice = true;
// Width of the border, spokes, rails, and the material ring around each slot.
lattice_width = 3;
// Depth of the 45 degree bevel cut into the top of the lattice web.
// The bevel also erodes the web sideways by the same amount, so it must stay
// below lattice_width / 2 or it severs the web; it must also leave a minimum
// web sliver at the top face (enforced in lattice_chamfer_cut), because
// thinner slivers make CGAL fail intermittently and do not print.
lattice_chamfer_depth = board_thickness / 6;

// Curve resolution caps. BOSL2 region booleans (used by the chamfer void)
// scale with segment count, and 24-gon arcs keep the chord error negligible
// at every radius in this model.
$fs = $preview ? 1 : 0.1;  // Minimum facet size
$fa = $preview ? 12 : 1;   // Minimum angle (degrees)
$fn = 48;

// ================= DERIVED DIMENSIONS =================

// Corner radius of the slots; kept just under half the slot width so the
// rounded ends do not collapse during the offset-based corner rounding.
hole_radius = skadis_slot_width / 2 - 0.01;

// Center-to-center spacing; leaves a gap of 35 between adjacent slot edges.
hole_spacing_x = 35 + skadis_slot_width;
// Center-to-center row spacing (staggered rows use the same pitch).
hole_spacing_y = 25 - skadis_slot_width;

// Edge-to-center margin: half the slot gap (35) plus half the slot width.
edge_margin_x = 17.5 + skadis_slot_width / 2;
// Edge-to-center margin: half the row pitch (25) plus half the slot height.
edge_margin_y = 12.5 + skadis_slot_height / 2;

board_width = 2 * edge_margin_x + (number_of_columns - 1) * hole_spacing_x;
board_height = 2 * edge_margin_y + (number_of_rows - 1) * hole_spacing_y;

// Every slot as [x, y, row]: center coordinates plus row index. The row
// index feeds the lattice rails, whose extent depends on the slot's row.
// Shifted rows end one column early so the margin stays equal.
function slots() = [
    for (j = [0:number_of_rows - 1])
        let(
            x_offset = (j % 2 == 0) ? hole_spacing_x / 2 : 0,
            col_reduction = (j % 2 == 0) ? 2 : 1
        )
        for (i = [0:number_of_columns - col_reduction])
            [edge_margin_x + x_offset + i * hole_spacing_x,
             edge_margin_y + j * hole_spacing_y,
             j]
];

// Center of each corner screw hole, inset from the board corners.
function corner_positions() = [
    for (px = [corner_screw_holes_inset, board_width - corner_screw_holes_inset],
         py = [corner_screw_holes_inset, board_height - corner_screw_holes_inset])
        [px, py]
];

// ================= REGION DATA =================

// The lattice web is built as BOSL2 region data so one source of truth
// feeds both the rendered web and the chamfer sweep, which needs the void
// (board minus web) as point data. The parts are kept UN-unioned: rendering
// unions overlapping parts natively (fast CSG), while the chamfer path
// unions them once to derive the void region.

// Rectangle spanning [0,w] x [0,h].
function _rect_region(w, h) = [square([w, h])];

// Rectangle with its corner at pos.
function _rect_region_at(pos, w, h) = [move(pos, square([w, h]))];

// Rounded rectangle spanning [0,w] x [0,h]; matches the module below.
function _rounded_rect_region(w, h, r) =
    [move([w / 2, h / 2], rect([w, h], rounding = r))];

// Capsule (stadium shape) between two points; used for the diagonal spokes.
function _capsule_region(p1, p2, r) = let(
    pts = concat(move(p1, circle(r)), move(p2, circle(r)))
) [select(pts, hull(pts))];  // hull() returns indices into pts

// Board outline as region data, corner at the origin.
function board_region() =
    _rounded_rect_region(board_width, board_height, board_corner_radius);

// Border ring: board outline minus the inset outline. The inset shape is
// shifted by the lattice width so the border is uniform on all four sides.
function border_region() = difference(
    board_region(),
    move([lattice_width, lattice_width],
         _rounded_rect_region(
             board_width - 2 * lattice_width,
             board_height - 2 * lattice_width,
             max(board_corner_radius - lattice_width, 0.01)
         ))
);

// Un-unioned parts of the lattice web: one border, one ring per slot, four
// X spokes per slot, vertical rails connecting the aligned slots of each
// column, and corner pads.
function lattice_web_parts() = let(
    // Solid pads so the corner screw holes keep enough bearing material.
    // The pad radius must cover the full countersink flare that lands on
    // the board face.
    pad_r = (corner_screw_holes_chamfer
                ? corner_screw_holes_chamfer_diameter
                : corner_screw_holes_diameter / 2)
            + lattice_width
) concat(
    [border_region()],
    [
        for (slot = slots())
            let(x = slot[0], y = slot[1], j = slot[2])
            each [
                // Solid ring around the slot; the slot cut reopens the middle.
                move([x, y], rect(
                    [skadis_slot_width + 2 * lattice_width,
                     skadis_slot_height + 2 * lattice_width],
                    rounding = hole_radius + lattice_width)),

                // X spokes toward the four diagonal neighbour positions.
                // Where no neighbour slot exists, the spoke runs on to the
                // border and is clipped by the board outline.
                for (sx = [-1, 1], sy = [-1, 1])
                    _capsule_region(
                        [x, y],
                        [x + sx * hole_spacing_x / 2, y + sy * hole_spacing_y],
                        lattice_width / 2),

                // Vertical rails: segments between aligned slots two rows
                // apart, extended so every rail runs on to the border at
                // both the top and the bottom of the board.
                each (j + 2 < number_of_rows
                    ? [_rect_region_at([x - lattice_width / 2, y],
                                       lattice_width, 2 * hole_spacing_y)]
                    : [_rect_region_at([x - lattice_width / 2, y],
                                       lattice_width, board_height - y)]),
                each (j - 2 < 0
                    ? [_rect_region_at([x - lattice_width / 2, 0],
                                       lattice_width, y)]
                    : [])
            ]
    ],
    corner_screw_holes ? [
        for (pos = corner_positions())
            let(px = pos[0], py = pos[1])
            each [
                [move([px, py], circle(pad_r))],

                // Strips to the two adjacent edges keep the pad attached
                // to the border for unusual insets.
                _capsule_region([px, py],
                                [px < board_width / 2 ? 0 : board_width, py],
                                lattice_width / 2),
                _capsule_region([px, py],
                                [px, py < board_height / 2 ? 0 : board_height],
                                lattice_width / 2)
            ]
    ] : []
);

// The void enclosed by the board outline and the lattice web; consumed by
// the chamfer offset sweep. Union of the overlapping web parts is the
// expensive step here, so this is only evaluated in full renders (guarded
// by $preview at the call site).
function lattice_void_region() =
    difference(board_region(), union(lattice_web_parts()));

// ================= MODULES =================

// Shrink-then-expand via offset rounds the corners while keeping the outer
// size. With center=false the lower-left corner sits at the origin; with
// center=true the rectangle is centered on the origin.
module rounded_rectangle(width, height, radius, center = true) {
    region(move(center ? [0, 0] : [width / 2, height / 2],
                rect([width, height], rounding = radius)));
}

module rounded_board() {
    linear_extrude(height = board_thickness) {
        rounded_rectangle(board_width, board_height, board_corner_radius, false);
    }
}

module lattice_profile() {
    // Overlapping web parts union natively at the CSG stage, which is much
    // faster than a region-level boolean union.
    for (part = lattice_web_parts()) {
        region(part);
    }
}

// Chamfers every top edge of the lattice web (spokes, rails, rings, and the
// border inner edge) the same way the slot openings are chamfered. The open
// region is swept with an outward-tapering chamfer: a negative chamfer
// width makes offset_sweep dilate the void toward the top face, so the cut
// is one continuous 45 degree taper. The open region never touches the
// board outline, so the outer silhouette stays sharp. check_valid is off
// because dilating a thin web makes the void contour self-tangent, which
// the validity check would reject but the geometry tolerates.
module lattice_chamfer_cut() {
    band = lattice_chamfer_depth;

    // Beyond half the lattice width the dilation swallows the web entirely;
    // close to that limit the remaining top-face sliver becomes thinner than
    // min_top_web, which CGAL converts to Nef polyhedra only intermittently
    // and no printer lays down reliably.
    min_top_web = 1;
    assert(band > 0 && band <= (lattice_width - min_top_web) / 2,
           str("lattice_chamfer_depth must be in (0, ",
               (lattice_width - min_top_web) / 2,
               "] for a ", lattice_width,
               " wide lattice: deeper bevels leave a top-face web sliver ",
               "thinner than ", min_top_web, "."));

    intersection() {
        rounded_board();
        translate([0, 0, board_thickness - band]) {
            offset_sweep(
                lattice_void_region(),
                height = band,
                top = os_chamfer(height = band, width = -band),
                check_valid = false
            );
        }
    }
}

// Cuts a slot through the board with optionally chamfered ends.
module hole(x, y, z) {
    // Overshoot both faces so the cut passes cleanly through the board.
    translate([x, y, z]) {
        linear_extrude(height = board_thickness + 2, center = true) {
            rounded_rectangle(skadis_slot_width, skadis_slot_height, hole_radius);
        }
    }

    if (chamfer_skadis_slots) {
        // Hull of two BOSL2 frusta anchored on the top face forms the slot
        // chamfer: the full flare lands on the face with the same wall slope
        // as the extruded slot. (chamfer_cylinder_mask was rejected: its
        // cone geometry is only self-consistent at a 45 degree angle.)
        depth = assert(slot_chamfer_depth > 0, "slot_chamfer_depth must be positive.")
                slot_chamfer_depth;
        hull() for (sy = [-1, 1]) {
            translate([x, y + sy * (skadis_slot_height / 2 - skadis_slot_width / 2), board_thickness]) {
                cyl(
                    h = depth,
                    r1 = skadis_slot_width / 2,
                    r2 = skadis_slot_width / 1.25,
                    anchor = TOP
                );
            }
        }
    }
}

// Corner screw hole for wall mounting, with optional countersink.
module corner_hole(x, y, z) {
    translate([x, y, z]) {
        linear_extrude(height = board_thickness + 2, center = true) {
            circle(d = corner_screw_holes_diameter);
        }
    }

    if (corner_screw_holes_chamfer) {
        // The frustum is anchored on the board face so the full chamfer
        // diameter sits there and flat-head screws sit flush.
        depth = assert(corner_screw_holes_chamfer_depth > 0,
                       "corner_screw_holes_chamfer_depth must be positive.")
                corner_screw_holes_chamfer_depth;
        translate([x, y, board_thickness]) {
            cyl(
                h = depth,
                r1 = corner_screw_holes_diameter / 2,
                r2 = corner_screw_holes_chamfer_diameter,
                anchor = TOP
            );
        }
    }
}

module pegboard() {
    difference() {
        if (enable_lattice) {
            // Keep only border, rings, spokes, and rails from the solid board.
            intersection() {
                rounded_board();
                linear_extrude(height = board_thickness) {
                    lattice_profile();
                }
            }
        } else {
            // Solid board that the slots and holes are cut from.
            rounded_board();
        }

        for (slot = slots()) {
            hole(slot[0], slot[1], board_thickness / 2);
        }

        if (corner_screw_holes) {
            for (pos = corner_positions()) {
                corner_hole(pos[0], pos[1], board_thickness / 2);
            }
        }

        // Bevel all lattice web edges on the top face when slot chamfering
        // is enabled. Skipped in fast previews: the offset sweep over the
        // void region is the most expensive operation in this model.
        // $preview is never true under --render, so full renders and STL
        // exports keep the bevel.
        if (enable_lattice && chamfer_skadis_slots && !$preview) {
            lattice_chamfer_cut();
        }
    }
}

// Render the 3D board. Set the condition to false to export a 2D projection
// instead (useful for laser cutting).
if (true) {
    pegboard();
    echo(board_width);
    echo(board_height);
} else {
    projection(cut = true) {
        corner_screw_holes_chamfer = false;
        chamfer_skadis_slots = false;
        pegboard();
    }
}
