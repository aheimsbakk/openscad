/*
 * Parametric SKADIS Universal Hook
 * Reconstructed from exact Cartesian coordinate data in "Hook - No Filets.step"
 */

/* [Global Properties] */
// Overall thickness/extrusion width of the hook
hook_thickness = 4.5; // [1.0:0.1:15.0]

/* [Board Interface (SKADIS)] */
// Thickness of the pegboard
board_thickness = 4.5; // [2.0:0.1:10.0]
// Vertical distance between the two pegs
peg_spacing = 21.3; // [15.0:0.1:30.0]
// Thickness of the top insertion peg
top_peg_thickness = 4.4; // [2.0:0.1:8.0]
// Height the top peg hooks upward behind the board
top_peg_hook_height = 4.67; // [1.0:0.01:10.0]
// Thickness of the bottom resting peg
bottom_peg_thickness = 4.3; // [2.0:0.1:8.0]

/* [Main Body (Spine)] */
// Thickness of the vertical spine resting against the board
spine_thickness = 4.5; // [2.0:0.1:10.0]

/* [Top Arm Geometry] */
// How far the top arm extends outward from the spine
top_arm_length = 9.7; // [1.0:0.1:50.0]
// Vertical thickness of the top arm
top_arm_thickness = 4.5; // [1.0:0.1:15.0]
// Distance the front lip drops downward
top_arm_drop = 7.5; // [0.0:0.1:30.0]
// Thickness of the front downward lip
top_arm_drop_thickness = 4.5; // [1.0:0.1:15.0]
// Vertical offset of the top arm from the peg origin
top_arm_y_offset = 0.5; // [-5.0:0.1:10.0]

/* [Bottom Arm Geometry] */
// How far the bottom arm extends outward from the spine
bottom_arm_length = 7.5; // [0.0:0.1:50.0]
// Vertical thickness of the bottom arm
bottom_arm_thickness = 4.5; // [1.0:0.1:15.0]

module skadis_hook() {
    // Calculate back protrusion based on board thickness to maintain chamfer slope
    board_adj = board_thickness - 4.5;
    peg_back_x = 9.0 + board_adj;
    
    linear_extrude(height = hook_thickness) {
        polygon(points=[
            // 1. Top Front of Top Arm
            [-(spine_thickness + top_arm_length), top_arm_y_offset + top_arm_thickness],
            // 2. Bottom Front of Top Arm Drop
            [-(spine_thickness + top_arm_length), top_arm_y_offset - top_arm_drop],
            // 3. Bottom Inner of Top Arm Drop
            [-(spine_thickness + top_arm_length - top_arm_drop_thickness), top_arm_y_offset - top_arm_drop],
            // 4. Inner Corner of Top Arm Drop
            [-(spine_thickness + top_arm_length - top_arm_drop_thickness), top_arm_y_offset],
            // 5. Inner Corner at Spine
            [-spine_thickness, top_arm_y_offset],
            // 6. Inner Corner at Bottom Arm
            [-spine_thickness, -(top_peg_thickness + peg_spacing + bottom_peg_thickness) + bottom_arm_thickness],
            // 7. Top Front of Bottom Arm
            [-(spine_thickness + bottom_arm_length), -(top_peg_thickness + peg_spacing + bottom_peg_thickness) + bottom_arm_thickness],
            // 8. Bottom Front of Bottom Arm
            [-(spine_thickness + bottom_arm_length), -(top_peg_thickness + peg_spacing + bottom_peg_thickness)],
            // 9. Bottom Back of Bottom Peg
            [board_thickness, -(top_peg_thickness + peg_spacing + bottom_peg_thickness)],
            // 10. Top Back of Bottom Peg
            [board_thickness, -(top_peg_thickness + peg_spacing)],
            // 11. Top Front of Bottom Peg (Spine Back)
            [0, -(top_peg_thickness + peg_spacing)],
            // 12. Bottom Front of Top Peg (Spine Back)
            [0, -top_peg_thickness],
            // 13. Bottom Back of Top Peg
            [peg_back_x, -top_peg_thickness],
            // 14. Top Back of straight peg section
            [peg_back_x, 0.84],
            // 15. Chamfer Point 1
            [8.49 + board_adj, 2.18],
            // 16. Chamfer Point 2
            [6.24 + board_adj, 4.67],
            // 17. Top of Top Peg Hook
            [board_thickness, top_peg_hook_height],
            // 18. Bottom of Top Peg Hook cutout
            [board_thickness, 0],
            // 19. Inner Top corner of Top Peg
            [0, 0],
            // 20. Top Back of Spine
            [0, top_arm_y_offset + top_arm_thickness]
        ]);
    }
}

skadis_hook();