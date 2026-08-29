// Enclosure parts connector system
// Purpose: Modular frame for a 3D printer dust cover. Interlocking parts
// slide onto a 6mm aluminum rod and snap together via peg-and-hole joints,
// creating a rectangular enclosure that wraps with plastic foil to protect
// the printer from dust when not in use.
//
// Assembly:
// 1. Cut the aluminum rod to the desired frame length.
// 2. Slide grid_nodes onto the rod in your desired layout.
// 3. Push adjacent pieces together so the pegs of one engage the holes of
//    the next. Pegs have 0.05mm clearance for a snug fit.
// 4. Cap the frame ends with a cap (straight pegs, flush fit).
// 5. Use rod_anchors at corners or frame ends to secure the rod and
//    transfer load into the grid.
// 6. Place a spacer between two grid_nodes on the same rod to create a
//    low-friction pivot point — useful for a hinged door.
// 7. Attach a clip to any rod segment that needs to hold a foil cover in
//    place. The clip wraps around the rod and its two tips press against
//    the surface to grip it.
//
// Parts shown (left to right, bottom to top):
//   grid_node (hollow) — main interlocking cube with rod hole
//   grid_node (solid)  — same shape, no rod hole for edge positions
//   rod_anchor         — tapered cylinder, anchors the rod
//   cap                — solid disc with straight pegs
//   clip               — ring with rounded tips that grips the rod
//   spacer             — thin ring, reduces friction between stacked pieces

// ================= PARAMETERS =================
node_size = 25;
rod_hole_d = 6;           // Matches 6mm aluminum rod
peg_d = 4;
peg_l = node_size / 8;

// Clearance between rod and rod holes (0.2mm for easy assembly)
clearance_rod = 0.2;
// Extra tolerance added on top of clearance_rod where rod holes are
// shared across multiple modules (e.g., grid_node body holes use this
// to match the rod_anchor bore tolerance)
clearance_additional = 0.05;
clearance_peg = 0.05;

// Render resolution — coarse in preview (fast), fine in render/export.
// $preview is true in OpenCSG preview (F5 and PNG without --render),
// false in render mode (F6 and STL/DXF/SVG export). This keeps the high
// quality $fs/$fa for final renders while previews stay responsive.
$fs = $preview ? 1 : 0.1;  // Minimum facet size
$fa = $preview ? 12 : 1;   // Minimum angle (degrees)

// ================= MAIN MODULES =================

module small_pegs(size = node_size, peg_d = peg_d, peg_l = peg_l, peg_tip_d = 0) {
    // Four peg positions arranged as a square centered on the face.
    peg_positions = [
        [size / 4, size / 4, 0],
        [-size / 4, size / 4, 0],
        [size / 4, -size / 4, 0],
        [-size / 4, -size / 4, 0]
    ];

    for (pos = peg_positions) {
        translate(pos) {
            translate([0, 0, -size / 2]) {
                if (peg_tip_d > 0) {
                    // Tapered peg: wider at base, narrower at tip.
                    // Creates a gap between this part and the mating surface.
                    cylinder(peg_l, d1 = peg_d, d2 = peg_tip_d);
                } else {
                    cylinder(peg_l, d = peg_d);
                }
            }
        }
    }
}

module grid_node(size = node_size, rod_hole_d = rod_hole_d, peg_d = peg_d, peg_l = peg_l, hollow = true) {
    // Rounded cube with pegs on all 6 faces and a central rod hole.
    // hollow=true  → has central hole for the aluminum rod
    // hollow=false → solid, for edge positions where no rod passes through
    face_rotations = [
        [0, 0, 0],
        [90, 0, 0],
        [180, 0, 0],
        [270, 0, 0],
        [90, 0, 90],
        [90, 0, 270]
    ];

    difference() {
        // Intersect a cube with a large sphere to get a rounded cube. The
        // sphere diameter is sqrt(2) * size so it touches the cube edges,
        // producing a smooth chamfer-like corner.
        intersection() {
            cube(size, center = true);
            sphere(d = size * sqrt(2));
        }

        // Central bore for the aluminum rod. Widen by clearance_additional so
        // the hole matches the tolerance used by rod_anchor (which also adds
        // clearance_additional on top of clearance_rod).
        if (hollow) {
            cylinder(size, d = rod_hole_d + clearance_additional, center = true);
        }

        // Additional rod holes on each face so the same rod passes through
        // the center and all six faces. Uses the bare rod diameter because
        // the peg module already provides its own clearance.
        for (face = face_rotations) {
            rotate(face) {
                translate([0, 0, -size / 2]) {
                    cylinder(size / 3, d = rod_hole_d);
                }
            }
        }

        // Pegs on each face for connecting to adjacent pieces
        for (face = face_rotations) {
            rotate(face) {
                small_pegs(size, peg_d, peg_l);
            }
        }
    }
}

module rod_anchor(size = node_size, rod_hole_d = rod_hole_d, peg_d = peg_d, peg_l = peg_l) {
    // Tapered cylinder that anchors the aluminum rod at a corner or end.
    // Pegs on the outer face connect to adjacent grid nodes.
    taper_ratio = 1.5;
    difference() {
        cylinder(size / 2, d1 = size, d2 = size / taper_ratio, center = true);
        cylinder(size / 2, d = rod_hole_d + clearance_additional, center = true);
    }
    translate([0, 0, size / 4 - peg_l]) {
        small_pegs(size, peg_d);
    }
}

module cap(size = node_size, peg_d = peg_d, peg_l = peg_l, peg_tip_d = 0) {
    // Flat disc with pegs on the outer face.
    // peg_tip_d = 0  → straight pegs (frame cap, flush fit)
    // peg_tip_d > 0  → tapered pegs (foil cap, creates gap for foil)
    cylinder(size / 8, d = size, center = true);
    translate([0, 0, peg_l / 2 + size / 2]) {
        small_pegs(size, peg_d, peg_l, peg_tip_d);
    }
}

module spacer(size = node_size, rod_hole_d = rod_hole_d) {
    // Thin ring with central hole. Placed between two grid_nodes on the
    // same rod to create a small gap that reduces friction and allows
    // one node to pivot relative to the other — useful for hinged doors.
    ring_ratio = 1.5;
    difference() {
        cylinder(size / 16, d = size / ring_ratio, center = true);
        cylinder(size / 16, d = rod_hole_d + clearance_additional + clearance_additional, center = true);
    }
}

// Parametric clip that wraps around a round tube. The profile is a ring
// with a wedge cut out and two rounded tips that press against the tube
// surface. The opening angle is adjusted so the tips do not clip into
// the subtractive wedge when the ring is extruded.
module clip(tube_diameter = 6, clip_width = 5, target_opening_angle = 90, wall_thickness = 1) {
    module clip_profile() {
        inner_radius = tube_diameter / 2;
        outer_radius = inner_radius + wall_thickness;
        center_radius = inner_radius + (wall_thickness / 2);
        tip_radius = wall_thickness / 2;

        // The rounded tips extend past the theoretical wedge boundary by
        // tip_radius. Compute the angle subtended by that extension so the
        // wedge can be widened to avoid CSG clipping artifacts.
        compensation_angle = 2 * asin(tip_radius / center_radius);
        adjusted_opening_angle = target_opening_angle + compensation_angle;

        // The wedge polygon must be large enough to fully remove the sector
        // between the two tips. Double the ring thickness to guarantee no
        // residual material remains after the difference operation.
        cut_size = outer_radius * 2;

        union() {
            difference() {
                circle(r=outer_radius);
                circle(r=inner_radius);

                // Wedge polygon rotated so its bisector aligns with the
                // positive Y axis (the "top" of the ring). The expanded
                // angle accounts for tip protrusion.
                polygon(points=[
                    [0, 0],
                    [cut_size * sin(adjusted_opening_angle / 2), cut_size * cos(adjusted_opening_angle / 2)],
                    [cut_size, cut_size],
                    [-cut_size, cut_size],
                    [-cut_size * sin(adjusted_opening_angle / 2), cut_size * cos(adjusted_opening_angle / 2)]
                ]);
            }

            // Two rounded tips sit at the edges of the opening. They press
            // against the tube to hold the clip in place. Positioning them
            // along the centerline of the wall thickness keeps the grip
            // force distributed evenly.
            tip_x = center_radius * sin(adjusted_opening_angle / 2);
            tip_y = center_radius * cos(adjusted_opening_angle / 2);

            translate([tip_x, tip_y, 0])
                circle(r=tip_radius);

            translate([-tip_x, tip_y, 0])
                circle(r=tip_radius);
        }
    }

    linear_extrude(height=clip_width, center=true)
        clip_profile();
}


// ================= INSTANTIATION =================

// Center: hollow grid node (main frame intersection)
grid_node(node_size, rod_hole_d + clearance_rod, peg_d + clearance_peg, peg_l + clearance_rod);

// Left: solid grid node (no rod hole, for edge positions)
translate([-node_size * 1.5, 0, 0]) {
    grid_node(node_size, rod_hole_d + clearance_rod, peg_d + clearance_peg, peg_l + clearance_rod, false);
}

// Right: rod anchor (secures the aluminum rod at a corner)
translate([node_size * 1.5, 0, 0]) {
    rotate([180]) {
        rod_anchor(node_size, rod_hole_d + clearance_rod + clearance_additional, peg_d, peg_l);
    }
}

// Top: frame cap (straight pegs, flush fit)
translate([0, node_size * 1.5, 0]) {
    cap(node_size, peg_d, peg_l);
}

// Tube clip: grips a 6mm rod to hold a foil cover in place.
translate([node_size * 1.5, node_size * 1.5, 0]) {
    clip(rod_hole_d, node_size / 4, 90, node_size / 24);
}

// Top-left: spacer (thin ring, reduces friction between stacked pieces)
translate([-node_size * 1.5, node_size * 1.5, 0]) {
    spacer(node_size, rod_hole_d);
}
