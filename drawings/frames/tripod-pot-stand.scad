// Single-piece reciprocal pot stand (trivet) with minimized hub.
// Purpose: One printable leg geometry that arrays into a 3 to 5 leg stand.
// The vertical foot width expands inwards toward the center. Includes a
// boolean toggle to switch the pot support wall between a curved contour 
// for round pots, or a flat plane for rectangular/polygonal pots.
// Builtin OpenSCAD only, no library needed.

// ================= PARAMETERS =================
/* [Assembly] */
// Number of identical legs in the stand
num_legs = 3; // [3:1:5]

/* [Clearance and Fit] */
// Slide-fit gap applied to the mating slots (width and depth) and the inner tip joint
slot_clearance = 0.2; // [0:0.05:1]
// Minimum solid material required between the two intersecting slots
min_solid_bridge = 15; // [5:1:30]

/* [Bracket members] */
// Width of the horizontal bar and the vertical leg
member_width = 30; // [10:1:100]
// Extrusion thickness of the part (flat print thickness)
member_thickness = 15; // [5:1:50]

/* [Pot size] */
// Pot diameter the stand is sized for, up to a 25 cm pot
pot_diameter = 150; // [100:5:250]
// Height of the stand from the table to the resting bars
foot_length = 100; // [50:5:200]

/* [Pot support] */
// True carves a curved profile for round pots. False keeps the face flat for polygonal pots.
contour_support_face = true; 
// Height of each support wall above the stand top
support_height = 15; // [0:1:100]
// Lean of each support wall away from the stand center
support_angle = 5; // [0:1:45]
// Width of the support wall base (independent of member_width)
support_width = 15; // [5:0.5:100]

/* [Layout] */
// Empty space between the solid part and the ghost assembly
part_gap = 100; // [0:5:200]

/* [Preview] */
// Draw the assembled ghost cross in fast previews; renders and STL stay solid
show_ghosts = true;

/* [Hidden] */
alpha = 360 / num_legs;
t_clear = member_thickness + slot_clearance;

// Calculate the minimum possible hub offset that maintains the min_solid_bridge
hub_offset_auto = (t_clear / sin(alpha) + min_solid_bridge) / (2 * tan(alpha / 2));
// Ensure the offset never causes the central hole radius to go negative
hub_offset = max(t_clear / 2, hub_offset_auto);

actual_radius = max(pot_diameter / 2, hub_offset + 1);
ghost_pot_extra = 20;

// ================= MAIN MODULES =================

// 2D profile of the solid uncut leg. 
module uncut_leg_2d() {
    x_start = -pot_diameter; // Extended far inside, cleanly chopped by tip_cutter
    
    // Intersection of the offset leg centerline with the target pot radius
    x_pot_circle = sqrt(pow(actual_radius, 2) - pow(hub_offset, 2));
    
    // If contoured, extend inward to guarantee boolean intersection. If flat, sit at apothem.
    x_inner = contour_support_face ? x_pot_circle - member_thickness : actual_radius;
    x_outer = contour_support_face ? x_pot_circle + support_width : actual_radius + support_width;
    
    union() {
        // Main horizontal bar
        translate([x_start, foot_length - member_width])
            square([x_outer - x_start, member_width]);
            
        // Foot extending downwards (aligned to outer edge, expanding inward)
        translate([x_outer - member_width, 0])
            square([member_width, foot_length]);
            
        // Support wall leaning outward
        lean = support_height * tan(support_angle);
        polygon([
            [x_inner, foot_length],
            [x_outer, foot_length],
            [x_outer + lean, foot_length + support_height],
            [x_inner + lean, foot_length + support_height]
        ]);
    }
}

// Extrudes the profile and orients it upright, centered perfectly on the Y axis.
module uncut_leg_upright() {
    translate([0, member_thickness / 2, 0])
        rotate([90, 0, 0])
            linear_extrude(member_thickness)
                uncut_leg_2d();
}

// Mathematical cutter block representing the intersecting slots.
module slot_cutter(is_top) {
    cut_w = 1000; 
    cut_thick = t_clear;
    // Overcut depth by slot_clearance / 2 to prevent bottoming out
    cut_h = member_width / 2 + slot_clearance / 2 + 1; 
    
    z_start = is_top ? (foot_length - member_width / 2 - slot_clearance / 2) 
                     : (foot_length - member_width - 1);
    
    translate([-cut_w / 2, hub_offset - cut_thick / 2, z_start])
        cube([cut_w, cut_thick, cut_h]);
}

// Chops the inner tip of the leg at the exact angle to sit flush against the adjacent leg.
module tip_cutter() {
    rotate([0, 0, alpha])
        translate([-500, hub_offset + member_thickness / 2 - slot_clearance, -500])
            cube([1000, 1000, 1000]);
}

// Carves the inner face of the support wall to perfectly contour a curved pot.
module pot_cutter() {
    slope = tan(support_angle);
    pot_height = support_height + 2;
    r_bottom = actual_radius;
    r_top = r_bottom + pot_height * slope;
    
    translate([0, 0, foot_length])
        cylinder(h = pot_height, r1 = r_bottom, r2 = r_top, $fn = 96);
}

// The leg positioned in the global assembly with mathematically subtracted joints and contours.
module slotted_leg_global() {
    difference() {
        // Base leg placed at operational radius
        translate([0, hub_offset, 0])
            uncut_leg_upright();
            
        // Outer Slot (Top Cut): Subtracted by the preceding leg (Leg -1)
        rotate([0, 0, -alpha])
            slot_cutter(true);
            
        // Inner Slot (Bottom Cut): Subtracted by the succeeding leg (Leg +1)
        rotate([0, 0, alpha])
            slot_cutter(false);
            
        // Inner Tip Chop: Trims excess material with clearance applied
        tip_cutter();
        
        // Support Contour: Carves the support wall if enabled for round pots
        if (contour_support_face) {
            pot_cutter();
        }
    }
}

// Reverses the assembly transformations to lay the final angled-cut leg flat for 3D printing.
module single_leg_flat() {
    translate([0, 0, member_thickness / 2])
        rotate([-90, 0, 0])
            translate([0, -hub_offset, 0])
                slotted_leg_global();
}

// Ghost view of the pot resting in the support walls.
module ghost_pot() {
    slope = tan(support_angle);
    pot_height = support_height + ghost_pot_extra;
    r_bottom = actual_radius;
    r_top = r_bottom + pot_height * slope;
    wall = 3;
    
    // Adapt geometry to circular or polygonal shape based on settings
    pot_fn = contour_support_face ? 96 : num_legs;
    r_mult = contour_support_face ? 1 : 1 / cos(180 / pot_fn);
    rot_z = contour_support_face ? 0 : 180 / pot_fn;
    
    rotate([0, 0, rot_z])
    %difference() {
        cylinder(h = pot_height, r1 = r_bottom * r_mult, r2 = r_top * r_mult, $fn = pot_fn);
        translate([0, 0, -1])
            cylinder(h = pot_height + 2,
                     r1 = (r_bottom - wall) * r_mult - slope,
                     r2 = (r_bottom - wall) * r_mult + (pot_height + 1) * slope,
                     $fn = pot_fn);
    }
}

// Assembles the upright legs radially to form the minimized reciprocal frame.
module assembly_ghost() {
    for (i = [0 : num_legs - 1]) {
        rotate([0, 0, i * alpha])
            %slotted_leg_global();
    }
    translate([0, 0, foot_length])
        ghost_pot();
}

// Combined layout mapping for visualization and export.
module pot_stand() {
    // Left: The single solid part to be printed flat on the XY plane
    translate([-pot_diameter / 2 - part_gap / 2, 0, 0])
        single_leg_flat();

    // Right: The ghost assembly showing the flush interlocking hub
    if ($preview && show_ghosts) {
        translate([pot_diameter / 2 + part_gap / 2, 0, 0])
            assembly_ghost();
    }
}

// ================= INSTANTIATION =================
pot_stand();