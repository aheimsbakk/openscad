// Two-piece slot-together pot stand (trivet).
// Purpose: each half is a U-shaped bracket. The two halves slide together
// through slots cut in the middle of their pot-size bars, locking into a
// flat cross that keeps a pot off the table. The feet rest on the table.
// Notes: pot_diameter is the pot diameter the stand is sized for, at
// most a 25 cm pot, and the bar spans it. The slot reaches half the
// width, so the crossed pot-size bars sit flush at the centerline. The
// file shows both variants side by side: slot on the inner edge of the U
// (facing the opening) and slot on the outer edge. With show_ghosts on,
// fast previews also draw the two halves as a translucent ghost cross in
// the assembled position; full renders and STL exports always output
// solid geometry. Builtin OpenSCAD only, no library needed.

// ================= PARAMETERS =================
/* [Bracket members] */
// Width of every member, in the part's plane
member_width = 40; // [10:1:100]
// Extrusion thickness of the part
member_thickness = 20; // [5:1:50]

/* [Pot size] */
// Pot diameter the stand is sized for, up to a 25 cm pot
pot_diameter = 200; // [100:5:250]
// Length of each of the two feet
foot_length = 100; // [50:5:200]

/* [Center slot] */
// Slide-fit gap added to the mating half's thickness
slot_clearance = 0.1; // [0:0.05:1]

/* [Layout] */
// Empty space between the two parts on the y axis
part_gap = 50; // [0:5:150]

/* [Preview] */
// Draw the assembled ghost cross in fast previews; renders and STL stay solid
show_ghosts = true;

/* [Hidden] */
// Pot-size bar length, spans the pot diameter
bar_length = pot_diameter;
// Slot width across the bar, derived from the member thickness
slot_width = member_thickness + slot_clearance;
// Slot depth, reaches the member centerline, derived from the member width
slot_depth = member_width / 2;

// ================= MAIN MODULE =================
// U-shaped bracket: one pot-size bar spanning the full length plus one
// foot at each end. All members share the same cross-section.
module u_bracket() {
    union() {
        // Pot-size bar, along the x axis
        cube([bar_length, member_width, member_thickness]);

        // Left foot
        cube([member_width, foot_length, member_thickness]);

        // Right foot
        translate([bar_length - member_width, 0, 0])
            cube([member_width, foot_length, member_thickness]);
    }
}

// Bracket with the center slot cut from the pot-size bar. The slot opens
// on the inner edge of the U when inside_slot is true, on the outer edge
// otherwise. The cut box is oversized past both faces so no surfaces stay
// coplanar with the part.
module slotted_bracket(inside_slot) {
    slot_y = inside_slot ? member_width - slot_depth : -0.1;
    difference() {
        u_bracket();
        translate([bar_length / 2 - slot_width / 2, slot_y, -0.5])
            cube([slot_width, slot_depth + 0.1, member_thickness + 1]);
    }
}

// Renders child geometry translucent in fast previews when ghosts are
// on, so the slot cuts stay visible through the material. The % modifier
// keeps ghost geometry out of full renders and STL exports; with ghosts
// off or under --render the child passes through unchanged.
module maybe_ghost() {
    if ($preview && show_ghosts) %children();
    else children();
}

// Ghost view of the two halves in the assembled pose, placed beside the
// printed parts so both stay visible. Each half is stood upright so its
// member width becomes height and its feet become legs, the second half
// is crossed through the first at the slot center, and the final mirror
// turns the crossed pair right-side up with the bars on top. Ghost
// geometry is preview-only: it never reaches renders or STL exports.
module ghost_assembly() {
    // Placement of the crossed half: its member-thickness band is centered
    // on the first half's bar midpoint, and its bar midpoint sits half a
    // slot width behind the layout origin.
    cross_x = bar_length / 2 - slot_width / 2;
    cross_y = -(slot_width + bar_length) / 2;

    mirror([0, 0, 1])
        translate([0, -foot_length, -foot_length]) {
            rotate([90, 0, 0])
                maybe_ghost() slotted_bracket(false);

            translate([cross_x, cross_y, 0])
                rotate([90, 0, 90])
                    maybe_ghost() slotted_bracket(true);
        }
}

// Both parts side by side: first the slot on the inner edge, then the
// slot on the outer edge, separated on the y axis for a clear view. In
// fast previews with ghosts on, the assembled pose is added as a ghost.
module pot_stand() {
    slotted_bracket(true);
    translate([0, foot_length + part_gap, 0])
        slotted_bracket(false);

    if ($preview && show_ghosts)
        ghost_assembly();
}

// ================= INSTANTIATION =================
pot_stand();
