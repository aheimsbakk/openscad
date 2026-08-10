// Enclosure parts connector system
// Purpose: Modular interlocking pieces for building a rectangular frame
// that wraps plastic foil. Pieces connect via pegs and holes in a 3D grid,
// held together by a 6mm hollow aluminum rod running through the center of
// each piece.
//
// Assembly:
// 1. Cut the aluminum rod to the desired frame length.
// 2. Slide grid_nodes onto the rod in your desired layout.
// 3. Push adjacent pieces together so the pegs of one engage the holes of
//    the next. Pegs have 0.2mm clearance for easy assembly.
// 4. Cap the frame ends with frame_caps (solid disc, aesthetic) or
//    foil_caps (disc with tapered pegs, for wrapping foil through).
// 5. Use rod_anchors at corners or frame ends to secure the rod and
//    transfer load into the grid.
// 6. Place a spacer between two grid_nodes on the same rod to create a
//    low-friction pivot point — useful for a hinged door.
//
// Parts shown (left to right, bottom to top):
//   grid_node (hollow) — main interlocking cube with rod hole
//   grid_node (solid)  — same shape, no rod hole for edge positions
//   rod_anchor         — tapered cylinder, anchors the rod
//   frame_cap          — solid disc, aesthetic end cap
//   foil_cap           — disc with tapered pegs, leaves gap for foil
//   spacer             — thin ring, reduces friction between stacked pieces
//
// Peg variants:
//   Straight pegs  → pegs sit flush against the mating surface.
//   Tapered pegs   → pegs narrow toward the mating surface, creating a gap
//                    between the part and its neighbor. Used where plastic
//                    foil needs to be tucked in.

// ================= PARAMETERS =================
node_size = 25;
rod_hole_d = 6;           // Matches 6mm aluminum rod
peg_d = 4;
peg_l = node_size / 8;

// Clearance between pegs and holes (0.2mm for easy assembly)
clearance = 0.2;

// Render resolution
$fs = 0.1;  // Minimum facet size (nozzle)
$fa = 1;    // Minimum angle (degrees)

// ================= MAIN MODULES =================

module small_pegs(size = node_size, peg_d = peg_d, peg_l = peg_l, peg_tip_d = 0) {
    // Four peg positions on a 2D grid
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
                    // Straight cylindrical peg.
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
        // Rounded cube body (cube intersected with sphere)
        intersection() {
            cube(size, center = true);
            sphere(d = size * sqrt(2));
        }

        // Central hole for aluminum rod
        if (hollow) {
            cylinder(size, d = rod_hole_d, center = true);
        }

        // Holes on each face for mating pegs
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
        cylinder(size / 2, d = rod_hole_d, center = true);
    }
    translate([0, 0, size / 4 - peg_l]) {
        small_pegs(size, peg_d);
    }
}

module frame_cap(size = node_size, peg_d = peg_d, peg_l = peg_l) {
    // Flat disc with straight pegs. Sits flush against the grid_node.
    // Use for aesthetic end caps where no foil needs to be fastened.
    cylinder(size / 8, d = size, center = true);
    translate([0, 0, peg_l / 2 + size / 2]) {
        small_pegs(size, peg_d, peg_l);
    }
}

module foil_cap(size = node_size, peg_d = peg_d, peg_l = peg_l, peg_tip_d = peg_d / 1.5) {
    // Flat disc with tapered pegs. The taper creates a gap between the
    // disc and the grid_node so plastic foil can be tucked in.
    // peg_tip_d controls the gap size — smaller taper = larger gap.
    cylinder(size / 8, d = size, center = true);
    translate([0, 0, peg_l / 2 + size / 2]) {
        small_pegs(size, peg_d, peg_l, peg_tip_d);
    }
}

module spacer(size = node_size, rod_hole_d = rod_hole_d) {
    // Thin ring with central hole. Placed between two grid_nodes on the
    // same rod to create a small gap that reduces friction and allows
    // one node to pivot relative to the other — useful for hinged doors.
    ring_ratio = 1.66;
    difference() {
        cylinder(size / 16, d = size / ring_ratio, center = true);
        cylinder(size / 16, d = rod_hole_d, center = true);
    }
}

// ================= INSTANTIATION =================

// Center: hollow grid node (main frame intersection)
grid_node(node_size, rod_hole_d + clearance, peg_d + clearance, peg_l + clearance);

// Left: solid grid node (no rod hole, for edge positions)
translate([-node_size * 1.5, 0, 0]) {
    grid_node(node_size, rod_hole_d + clearance, peg_d + clearance, peg_l + clearance, false);
}

// Right: rod anchor (secures the aluminum rod at a corner)
translate([node_size * 1.5, 0, 0]) {
    rotate([180]) {
        rod_anchor(node_size, rod_hole_d + clearance, peg_d, peg_l);
    }
}

// Top: frame cap (solid disc, aesthetic end cap)
translate([0, node_size * 1.5, 0]) {
    frame_cap(node_size, peg_d, peg_l);
}

// Top-right: foil cap (tapered pegs, leaves gap for plastic foil)
translate([node_size * 1.5, node_size * 1.5, 0]) {
    foil_cap(node_size, peg_d, peg_l);
}

// Top-left: spacer (thin ring, reduces friction between stacked pieces)
translate([-node_size * 1.5, node_size * 1.5, 0]) {
    spacer(node_size, rod_hole_d);
}
