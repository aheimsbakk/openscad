// Two-piece slot-together pot stand (trivet).
// Purpose: each half is a U-shaped bracket. The two halves slide together
// through slots cut in the middle of their pot-size bars, locking into a
// flat cross that keeps a pot off the table. The feet rest on the table.
// Notes: pot_diameter is the pot diameter the stand is sized for, at
// most a 25 cm pot, measured as the inner width between the two support
// walls; the bar is one support_width longer on each side. Each support
// wall rises from the bar end on top of a leg, leans outward by
// support_angle so a pot that widens toward the top rests flush against
// its inner face, and is support_height tall above the stand top. The
// slot reaches half the
// width, so the crossed pot-size bars sit flush at the centerline. The
// file shows both variants side by side: slot on the inner edge of the U
// (facing the opening) and slot on the outer edge. With show_ghosts on,
// fast previews also draw the two halves as a translucent ghost cross in
// the assembled position, plus a translucent flared pot resting in the
// support walls so the support angle can be judged; full renders and STL
// exports always output
// solid geometry. Builtin OpenSCAD only, no library needed.

// ================= PARAMETERS =================
/* [Bracket members] */
// Width of every member, in the part's plane
member_width = 30; // [10:1:100]
// Extrusion thickness of the part
member_thickness = 15; // [5:1:50]

/* [Pot size] */
// Pot diameter the stand is sized for, up to a 25 cm pot, as the inner
// width between the support walls
pot_diameter = 150; // [100:5:250]
// Length of each of the two feet
foot_length = 100; // [50:5:200]

/* [Pot support] */
// Height of each support wall above the stand top
support_height = 15; // [0:1:100]
// Lean of each support wall away from the stand center, matching pots
// that widen toward the top
support_angle = 5; // [0:1:45]
// Width of each support wall and bar extension per side; keep at most
// the member width
support_width = 15; // [5:0.5:100]

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
// Pot-size bar length: pot diameter plus one support width per side, so
// the pot diameter is the inner width between the support walls
bar_length = pot_diameter + 2 * support_width;
// Slot width across the bar, derived from the member thickness
slot_width = member_thickness + slot_clearance;
// Slot depth, reaches the member centerline, derived from the member width
slot_depth = member_width / 2;
// Height of the ghost pot above the support walls, preview aid only
ghost_pot_extra = 20;

// ================= MAIN MODULE =================
// Support wall on one bar end, leaning outward from the bar center. The
// base sits on the stand-top segment of the bar end, exactly
// support_width wide, and the wall leans by support_angle about the
// inner bottom edge, which is the pot rim line. A pot whose wall slope
// matches support_angle rests flush against the inner face. The outer
// face is parallel, one support_width farther out, and the top is cut
// level. In the flat part the wall extends past the bar's spine edge
// (assembled up), on the side away from the feet.
// Built for the left bar end; the right end mirrors this wall.
module support_wall() {
    lean = support_height * tan(support_angle);
    linear_extrude(member_thickness)
        polygon([
            [0, 0],
            [support_width, 0],
            [support_width - lean, -support_height],
            [-lean, -support_height]
        ]);
}

// U-shaped bracket: one pot-size bar spanning the full length plus one
// foot at each end and one support wall on each bar end. All members
// share the same thickness; the support walls are thinner in width.
module u_bracket() {
    union() {
        // Pot-size bar, along the x axis
        cube([bar_length, member_width, member_thickness]);

        // Left foot
        cube([member_width, foot_length, member_thickness]);

        // Right foot
        translate([bar_length - member_width, 0, 0])
            cube([member_width, foot_length, member_thickness]);

        // Pot-support wall on the left bar end
        support_wall();

        // Pot-support wall on the right bar end
        translate([bar_length, 0, 0])
            mirror([1, 0, 0])
                support_wall();
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

// Ghost view of a flared pot resting in the support walls, so the
// support angle can be judged before printing. The pot is a thin-walled
// cone whose outer wall slope equals support_angle, so the outer wall
// lies flat on the support walls' inner faces. It rises
// ghost_pot_extra above the support walls and is open at both ends so
// the crossed bars stay visible. Ghost geometry is preview-only: it
// never reaches renders or STL exports.
module ghost_pot() {
    slope = tan(support_angle);
    pot_height = support_height + ghost_pot_extra;
    r_bottom = pot_diameter / 2;
    r_top = r_bottom + pot_height * slope;
    // Ghost shell thickness, presentational only, not part geometry
    wall = 3;
    %difference() {
        cylinder(h = pot_height, r1 = r_bottom, r2 = r_top, $fn = 96);
        translate([0, 0, -1])
            cylinder(h = pot_height + 2,
                     r1 = r_bottom - wall - slope,
                     r2 = r_bottom - wall + (pot_height + 1) * slope,
                     $fn = 96);
    }
}

// Both parts side by side: first the slot on the inner edge, then the
// slot on the outer edge, separated on the y axis for a clear view. In
// fast previews with ghosts on, the assembled pose is added as a ghost,
// with the flared pot resting in its support walls.
module pot_stand() {
    slotted_bracket(true);
    translate([0, foot_length + part_gap, 0])
        slotted_bracket(false);

    if ($preview && show_ghosts)
        translate([0, -part_gap, 0]) {
            ghost_assembly();

            // Ghost pot in the final assembled frame: centered on the
            // crossing bars, base on the stand top at foot_length height.
            translate([bar_length / 2, -bar_length / 2 - (member_thickness + member_width) / 2 + 6, foot_length])
                ghost_pot();
        }
}

// ================= INSTANTIATION =================
pot_stand();
