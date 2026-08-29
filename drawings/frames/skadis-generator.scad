// Skadis pegboard generator
// Purpose: parametric Skadis-style pegboard for 3D printing. The slot grid,
// board size, and corner screw holes are configurable. An optional lattice
// hollows the webs between slots to save plastic.

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
Corner_Screw_Holes = false;
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
        // Solid board that the slots and holes are cut from.
        rounded_board();

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
