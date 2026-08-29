// Skadis pegboard generator
// Purpose: parametric Skadis-style pegboard for 3D printing. The slot grid,
// board size, and corner screw holes are configurable. An optional lattice
// cuts through the board, leaving only a border, a material ring around each
// slot, X spokes, and vertical rails to save filament.

/* [Board Settings] */
// Number of columns (horizontal direction).
Number_Of_Columns = 4;       
// Number of rows (vertical direction). An odd number keeps the top and
// bottom rows aligned, so the grid looks symmetric.
Number_Of_Rows = 7;       
// (mm)
Board_Thickness = 5; 
// (mm)
Board_Corner_Radius = 10;  

/* [Corner Mount Settings] */
Corner_Screw_Holes = true;
Corner_Screw_Holes_Chamfer = false;
// (mm)
Corner_Screw_Holes_Diameter = 3;
// (mm)
Corner_Screw_Holes_Inset = 10;
// (mm)
Corner_Screw_Holes_Chamfer_Diameter = 8;

/* [Skadis Slot Settings] */
// (mm)
Skadis_Slot_Width = 5;    
// (mm)
Skadis_Slot_Height = 15;    
// Chamfer the slot openings so tools slide in more easily.
Chamfer_Skadis_Slots = true;

/* [Lattice Settings] */
// Cut the board down to a border, X spokes, vertical rails, and slot rings
// to save filament. Disable for a solid board.
Enable_Lattice = true;
// (mm) Width of the border, spokes, rails, and the material ring around
// each slot.
Lattice_Width = 3;

$fa=1;
$fs=.2;


// Corner radius of the slots; kept just under half the slot width so the
// rounded ends do not collapse during the offset-based corner rounding.
hole_radius = Skadis_Slot_Width / 2 - 0.01;

// Center-to-center spacing; leaves a 35 mm gap between adjacent slot edges.
hole_spacing_x = 35 + Skadis_Slot_Width;
// Center-to-center row spacing (staggered rows use the same pitch).
hole_spacing_y = 25 - Skadis_Slot_Width;

// Edge-to-center margin: half the 35 mm slot gap plus half the slot width.
edge_margin_x = 17.5 + ( Skadis_Slot_Width / 2 );
// Edge-to-center margin: half the 25 mm row pitch plus half the slot height.
edge_margin_y = 12.5 + ( Skadis_Slot_Height / 2 );

board_width = 2 * edge_margin_x + (Number_Of_Columns - 1) * hole_spacing_x;
board_height = 2 * edge_margin_y + (Number_Of_Rows - 1) * hole_spacing_y;

// Shrink-then-expand via offset rounds the corners while keeping the outer size.
module rounded_rectangle(width, height, radius, c = true) {
    offset(r=radius) 
        offset(delta=-radius)
            square([width, height], center=c);
}

module rounded_board() {
    linear_extrude(height = Board_Thickness) {
        rounded_rectangle(board_width, board_height, Board_Corner_Radius, false);
    }
}

// Capsule (stadium shape) between two points; used for the diagonal spokes.
module capsule(p1, p2, r) {
    hull() {
        translate(p1) circle(r);
        translate(p2) circle(r);
    }
}

// 2D profile of the material that remains when the lattice is enabled:
// outer border, one ring per slot, four X spokes per slot, and vertical
// rails connecting the aligned slots of each column.
module lattice_profile() {
    union() {
        // Outer border: board outline minus the inset outline. The inset
        // shape is shifted by the lattice width so the border is uniform
        // on all four sides.
        difference() {
            rounded_rectangle(board_width, board_height, Board_Corner_Radius, false);
            translate([Lattice_Width, Lattice_Width]) {
                rounded_rectangle(
                    board_width - 2 * Lattice_Width,
                    board_height - 2 * Lattice_Width,
                    max(Board_Corner_Radius - Lattice_Width, 0.01),
                    false
                );
            }
        }

        for (j = [0:Number_Of_Rows-1]) {
            x_offset = (j % 2 == 0) ? hole_spacing_x / 2 : 0;
            col_reduction = (j % 2 == 0) ? 2 : 1;

            for (i = [0:Number_Of_Columns-col_reduction]) {
                x = edge_margin_x + x_offset + i * hole_spacing_x;
                y = edge_margin_y + j * hole_spacing_y;

                // Solid ring around the slot; the slot cut reopens the middle.
                translate([x, y]) {
                    rounded_rectangle(
                        Skadis_Slot_Width + 2 * Lattice_Width,
                        Skadis_Slot_Height + 2 * Lattice_Width,
                        hole_radius + Lattice_Width
                    );
                }

                // X spokes toward the four diagonal neighbour positions.
                // Where no neighbour slot exists, the spoke runs on to the
                // border and is clipped by the board outline.
                for (sx = [-1, 1], sy = [-1, 1]) {
                    capsule(
                        [x, y],
                        [x + sx * hole_spacing_x / 2, y + sy * hole_spacing_y],
                        Lattice_Width / 2
                    );
                }

                // Vertical rails: segments between aligned slots two rows
                // apart, extended so every rail runs on to the border at
                // both the top and the bottom of the board.
                if (j + 2 < Number_Of_Rows) {
                    // Segment down to the next aligned slot.
                    translate([x - Lattice_Width / 2, y]) {
                        square([Lattice_Width, 2 * hole_spacing_y]);
                    }
                } else {
                    // Topmost slot of this column: run the rail up to the
                    // top border.
                    translate([x - Lattice_Width / 2, y]) {
                        square([Lattice_Width, board_height - y]);
                    }
                }

                if (j - 2 < 0) {
                    // Bottom-most slot of this column: run the rail down to
                    // the bottom border.
                    translate([x - Lattice_Width / 2, 0]) {
                        square([Lattice_Width, y]);
                    }
                }
            }
        }

        // Solid pads so the corner screw holes keep enough bearing material.
        if (Corner_Screw_Holes) {
            // Radius clears the widest countersink part that reaches the
            // board face (midpoint of the cone radii), plus one lattice
            // width of material.
            pad_r = (Corner_Screw_Holes_Chamfer
                        ? (Corner_Screw_Holes_Diameter / 2 + Corner_Screw_Holes_Chamfer_Diameter) / 2
                        : Corner_Screw_Holes_Diameter / 2)
                    + Lattice_Width;

            for (px = [Corner_Screw_Holes_Inset, board_width - Corner_Screw_Holes_Inset]) {
                for (py = [Corner_Screw_Holes_Inset, board_height - Corner_Screw_Holes_Inset]) {
                    translate([px, py]) circle(pad_r);

                    // Strips to the two adjacent edges keep the pad attached
                    // to the border for unusual insets.
                    capsule([px, py], [px < board_width / 2 ? 0 : board_width, py], Lattice_Width / 2);
                    capsule([px, py], [px, py < board_height / 2 ? 0 : board_height], Lattice_Width / 2);
                }
            }
        }
    }
}

// Chamfers every top edge of the lattice web (spokes, rails, rings, and the
// border inner edge) the same way the slot openings are chamfered: thin
// layers of the open region, each dilated further, taper the web toward the
// top face. The open region never touches the board outline, so the outer
// silhouette stays sharp.
module lattice_chamfer_cut() {
    steps = 4;
    // Same band height as the slot chamfer, with a 45 degree taper.
    band = Board_Thickness / 5;

    for (i = [1:steps]) {
        translate([0, 0, Board_Thickness - band + (i - 1) * band / steps]) {
            linear_extrude(height = band / steps + 0.01) {
                intersection() {
                    rounded_rectangle(board_width, board_height, Board_Corner_Radius, false);
                    offset(r = band * i / steps) {
                        difference() {
                            rounded_rectangle(board_width, board_height, Board_Corner_Radius, false);
                            lattice_profile();
                        }
                    }
                }
            }
        }
    }
}

// Cuts a slot through the board with optionally chamfered ends.
module hole(x, y, z) {
    // Extend 1 mm past each face so the cut passes cleanly through the board.
    translate([ x, y, z ]) {
        linear_extrude(height = Board_Thickness + 2, center=true) {
            rounded_rectangle(Skadis_Slot_Width, Skadis_Slot_Height, hole_radius);
        }
    }
    
    if( Chamfer_Skadis_Slots ) {
        // Hull of two tapered cones at the slot ends forms each chamfer.
        hull() {
            translate([ x, y - (Skadis_Slot_Height / 2) + (Skadis_Slot_Width / 2), Board_Thickness ]) {
                cylinder(h=Board_Thickness / 5, r1=Skadis_Slot_Width / 2, r2=Skadis_Slot_Width / 1.25, center=true);
            }
            translate([ x, y + (Skadis_Slot_Height / 2) - (Skadis_Slot_Width / 2), Board_Thickness ]) {
                cylinder(h=Board_Thickness / 5, r1=Skadis_Slot_Width / 2, r2=Skadis_Slot_Width / 1.25, center=true);
            }
        }
    }
}

// Corner screw holes for wall mounting.
module corner_hole(x, y, z) {
    translate([ x, y, z ]) {
        linear_extrude(height = Board_Thickness + 2, center=true) {
            circle(d=Corner_Screw_Holes_Diameter);
        }
    }
    
    // Countersink so flat-head screws sit flush with the face.
    if( Corner_Screw_Holes_Chamfer ) {
        translate([ x, y, Board_Thickness ]) {
            cylinder(h=Board_Thickness / 2, r1=Corner_Screw_Holes_Diameter / 2, r2=Corner_Screw_Holes_Chamfer_Diameter, center=true);
        }
    }
}

module pegboard() {
    difference() {
        if (Enable_Lattice) {
            // Keep only border, rings, spokes, and rails from the solid board.
            intersection() {
                rounded_board();
                linear_extrude(height = Board_Thickness) {
                    lattice_profile();
                }
            }
        } else {
            // Solid board that the slots and holes are cut from.
            rounded_board();
        }

        // Stagger every other row by half a pitch, matching the Skadis pattern.
        for (j = [0:Number_Of_Rows-1]) {
            // Shifted rows end one column early so the margin stays equal.
            x_offset = (j % 2 == 0) ? hole_spacing_x / 2 : 0;
            col_reduction = (j % 2 == 0) ? 2 : 1;

            for (i = [0:Number_Of_Columns-col_reduction]) {
                hole(
                    edge_margin_x + x_offset + i * hole_spacing_x, 
                    edge_margin_y + j * hole_spacing_y, 
                    Board_Thickness / 2
                );
            }
        }
        
        if (Corner_Screw_Holes) {
            // Bottom-left corner.
            corner_hole(
                Corner_Screw_Holes_Inset,
                Corner_Screw_Holes_Inset,
                Board_Thickness / 2
            );
            
            // Bottom-right corner.
            corner_hole(
                board_width - Corner_Screw_Holes_Inset,
                Corner_Screw_Holes_Inset,
                Board_Thickness / 2
            );
            
            // Top-left corner.
            corner_hole(
                Corner_Screw_Holes_Inset,
                board_height - Corner_Screw_Holes_Inset,
                Board_Thickness / 2
            );
            
            // Top-right corner.
            corner_hole(
                board_width - Corner_Screw_Holes_Inset,
                board_height - Corner_Screw_Holes_Inset,
                Board_Thickness / 2
            );
        }

        // Bevel all lattice web edges on the top face when slot chamfering
        // is enabled. Skipped in fast previews: the layered 2D offsets are
        // the most expensive operation in this model. $preview is never true
        // under --render, so full renders and STL exports keep the bevel.
        if (Enable_Lattice && Chamfer_Skadis_Slots && !$preview) {
            lattice_chamfer_cut();
        }
    }
}

// Render the 3D board. Set the condition to false to export a 2D projection
// instead (useful for laser cutting).
if ( true ) {
    pegboard();
    echo(board_width);
    echo(board_height);
} else {
    projection(cut=true) {
        Corner_Screw_Holes_Chamfer = false;
        Chamfer_Skadis_Slots = false;
        pegboard();
    }
}
