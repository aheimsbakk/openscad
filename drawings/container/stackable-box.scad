// Stackable vase-mode storage box: 1960s op-art stiffening pattern, front
// slide-in plaque pocket, lid, and nesting stacking. The model is solid by
// design: vase (spiral) mode prints only the bottom fill plus the outer
// contour of a solid block, yielding one continuous wall.
// Box and lid print as separate vase jobs (-D 'part="box"' / -D 'part="lid"'),
// the plaque prints flat (-D 'part="plaque"').
// Stacking: the top of the box has an inset recess; the bottom nests into the
// box below with fit clearance and rests on the recess ledge.
// Pocket: the continuous perimeter folds into lateral C-channels [ ] with
// retaining lips that grip the plaque edges, a solid lower ledge for the
// plaque to rest on, and an upper entry funnel for slide-in insertion.
// Fits plaques up to plaque_t. The back and sides carry the op-art pattern.

include <../../lib/BOSL2/std.scad>

// ================= PARAMETERS =================
/* [Part] */
part = "both";  // ["box", "lid", "plaque", "both"]

/* [Box] */
length = 100;    // outer length (X), mm
width = 70;      // outer width (Y), mm
height = 55;     // wall height, mm
corner_r = 12;   // corner rounding, mm

/* [Pattern: 1960s op-art stiffening] */
pattern = "rings";  // ["waffle", "ribs", "rings", "none"]
pattern_amp = 1.2;   // radial wave depth, mm
pattern_pitch = 12;  // wave period along wall and height, mm

/* [Plaque pocket (front, -Y)] */
plaque_w = 50;      // plaque width, mm
plaque_h = 22;      // plaque height, mm
pocket_z = 29;      // plaque center height when seated, mm
plaque_t = 1.5;     // max plaque thickness the pocket accepts, mm
pocket_fit = 0.4;   // clearance around the plaque (sides and depth), mm
lip_w = 2.5;        // retaining lip overlap in X over plaque edge, mm
lip_t = 1.2;        // retaining lip thickness in Y, mm
bracket_w = 3.0;    // outer frame rib width beyond slot, mm
guide_h = 4;        // channel extension above the seated plaque, mm

/* [Stacking] */
stack_depth = 5;      // how far the bottom sinks into the box below, mm
stack_inset = 1.2;    // top recess inset (bearing ledge width), mm
stack_fit = 0.4;      // side clearance between insert and recess, mm
stack_blend = 2;      // transition width below both inset zones, mm
stack_count = 1;      // boxes in the preview stack ("both" only)

/* [Lid] */
lid_rim_h = 10;     // rim height wrapping the box top, mm
lid_fit = 1.5;      // box top to printed rim wall clearance, mm
lid_plate_t = 1.6;  // lid plate thickness (vase bottom fill), mm
lid_ledger = 2.0;   // plate ledge beyond rim, mm

$fn = 64;

// ================= RENDER LOGIC =================
lid_outer = length + 2 * (lid_fit + lid_ledger);
lid_cx = length / 2 + 10 + lid_outer / 2;
plaque_cx = lid_cx + lid_outer / 2 + 10 + plaque_w / 2;
if (part == "box") vase_box();
else if (part == "lid") vase_lid();
else if (part == "plaque") vase_plaque();
else {
    for (i = [0:stack_count - 1])
        up(i * (height - stack_depth)) vase_box();
    right(lid_cx) vase_lid();
    right(plaque_cx) vase_plaque();
}

// ================= SANITY CHECKS =================
assert(plaque_w + 2 * (pocket_fit + bracket_w) <= length - 2 * corner_r, "Pocket bracket does not fit on the front face.");
assert(pocket_z + plaque_h / 2 + guide_h <= height - stack_depth - stack_blend, "Pocket channel must clear the top stacking recess.");
assert(pocket_z - plaque_h / 2 >= stack_depth + stack_blend + 4, "Pocket ledge must clear the bottom stacking zone.");
assert(lid_fit >= pattern_amp * sin(180 * lid_rim_h / height) + 0.65, "Lid clearance smaller than wall wave near the top plus line width.");
assert(stack_fit < stack_inset, "Recess fit clearance must stay below recess inset, or upper box has no bearing ledge.");

// ================= PATH HELPERS =================
// Clamped 0..1 smooth transition between a and b.
function smoothstep(a, b, u) =
    let(t = min(1, max(0, (u - a) / (b - a)))) t * t * (3 - 2 * t);

// ================= POCKET CONSTANTS =================
slot_w = plaque_w + 2 * pocket_fit;
slot_x0 = slot_w / 2;
slot_d = plaque_t + pocket_fit;
x_lip_in = slot_x0 - lip_w;
x_bracket_out = slot_x0 + bracket_w;

y_wall = -width / 2;
y_slot_open = y_wall - slot_d;
y_front_open = y_slot_open - lip_t;
bracket_proj = y_wall - y_front_open;

z_ledge = pocket_z - plaque_h / 2;
z_plaque_top = pocket_z + plaque_h / 2;
insert_inset = stack_inset - stack_fit;

// ================= STACKING ZONES =================
function neck_zone(z) =
    smoothstep(height - stack_depth - stack_blend, height - stack_depth, z);

function base_zone(z) =
    1 - smoothstep(stack_depth, stack_depth + stack_blend, z);

// ================= BASE CORNERS & WALLS =================
cx = length / 2 - corner_r;
cy = width / 2 - corner_r;
fn_c = 12;

// Corner arcs (CCW)
c_tr = [for (a = [0 : 90/fn_c : 90]) [cx + corner_r*cos(a), cy + corner_r*sin(a)]];
c_tl = [for (a = [90 : 90/fn_c : 180]) [-cx + corner_r*cos(a), cy + corner_r*sin(a)]];
c_bl = [for (a = [180 : 90/fn_c : 270]) [-cx + corner_r*cos(a), -cy + corner_r*sin(a)]];
c_br = [for (a = [-90 : 90/fn_c : 0]) [cx + corner_r*cos(a), -cy + corner_r*sin(a)]];

// Wall points along straight segments
wall_r = [for (y = [c_br[len(c_br)-1].y + 1.5 : 1.5 : c_tr[0].y - 0.5]) [length/2, y]];
wall_t = [for (x = [c_tr[len(c_tr)-1].x - 1.5 : -1.5 : c_tl[0].x + 0.5]) [x, width/2]];
wall_l = [for (y = [c_tl[len(c_tl)-1].y - 1.5 : -1.5 : c_bl[0].y + 0.5]) [-length/2, y]];

// Front wall segments flanking the bracket
front_l = [for (x = [-cx : 1.5 : -x_bracket_out - 0.5]) [x, y_wall]];
front_r = [for (x = [x_bracket_out + 0.5 : 1.5 : cx]) [x, y_wall]];

// Center pocket points across back wall
n_center = 16;
dx_c = 2 * slot_x0 / n_center;
center_xs = [for (i = [1 : n_center - 1]) -slot_x0 + i * dx_c];

// Op-art pattern displacement for non-pocket zones
perim = 2 * (length + width);
function pattern_disp(t, z) =
    let(
        wt = sin(360 * t * perim / pattern_pitch),
        wz = sin(360 * z / pattern_pitch),
        env = sin(180 * z / height)
    )
    pattern == "ribs" ? pattern_amp * wt * env :
    pattern == "rings" ? pattern_amp * wz * env :
    pattern == "waffle" ? pattern_amp * wt * wz * env : 0;

// Outline at height z: perimeter with C-channel brackets and resting ledge
function outline_at(z) =
    let(
        nz = neck_zone(z),
        bz = base_zone(z),

        // Bracket outer ribs active above bottom insert and below top recess
        b_act = smoothstep(7, 10, z) * (1 - smoothstep(44, 47, z)),
        y_b_front = y_wall - bracket_proj * b_act,

        // Resting ledge forms a forward shelf below z_ledge, chamfers back above
        ledge_act = smoothstep(14, z_ledge, z) * (1 - smoothstep(z_ledge, z_ledge + 2.5, z)),
        y_c = y_wall - bracket_proj * ledge_act,

        // Front retaining lips grip plaque edges, funnel open at top
        lip_act = smoothstep(z_ledge - 1.5, z_ledge + 0.5, z) * (1 - smoothstep(z_plaque_top, z_plaque_top + guide_h, z)),
        x_li = slot_x0 - lip_w * lip_act,

        // Slot cavity opens above resting ledge
        slot_act = smoothstep(z_ledge, z_ledge + 2.5, z) * (1 - smoothstep(44, 47, z)),
        y_s = y_b_front + (y_slot_open - y_b_front) * slot_act,

        // Front perimeter with C-channels [ ] and center ledge/pocket
        front_bracket = [
            [-x_bracket_out, y_wall],
            [-x_bracket_out, y_b_front],
            [-x_li, y_b_front],
            [-x_li, y_s],
            [-slot_x0, y_s],
            [-slot_x0, y_c],
            each [for (x = center_xs) [x, y_c]],
            [slot_x0, y_c],
            [slot_x0, y_s],
            [x_li, y_s],
            [x_li, y_b_front],
            [x_bracket_out, y_b_front],
            [x_bracket_out, y_wall]
        ],
        full_front = concat(front_l, front_bracket, front_r),
        rest = concat(c_br, wall_r, c_tr, wall_t, c_tl, wall_l, c_bl),
        full_raw = concat(full_front, rest),
        perim_len = path_length(full_raw)
    )
    [
        for (i = idx(full_raw))
            let(
                p = full_raw[i],
                in_pocket = (p.y < y_wall + 0.01 && abs(p.x) <= x_bracket_out + 1.0),
                p_disp = in_pocket ? 0 :
                    pattern_disp(i / len(full_raw), z) * (1 - nz) * (1 - bz),
                d_stack = (bz > 0 ? -insert_inset * bz : (nz > 0 ? -stack_inset * nz : 0)),
                n = (p.y < y_wall + 0.01) ? [0, -1] : unit(p)
            )
            p + n * (p_disp + d_stack)
    ];

dz = pattern_pitch / 10;
_zs_raw = [for (z = [0:dz:height]) z];
zs = (select(_zs_raw, -1) == height) ? _zs_raw : concat(_zs_raw, [height]);

// ================= BOX =================
module vase_box() {
    skin([for (z = zs) path3d(outline_at(z), z)], slices = 0, caps = true);
}

// ================= LID =================
module vase_lid() {
    rim_out = rect([length + 2 * lid_fit, width + 2 * lid_fit],
        rounding = corner_r + lid_fit);
    plate_out = offset(rim_out, r = lid_ledger);
    union() {
        linear_extrude(lid_plate_t) polygon(plate_out);
        up(lid_plate_t) linear_extrude(lid_rim_h) polygon(rim_out);
    }
}

// ================= PLAQUE =================
module vase_plaque() {
    cuboid([plaque_w, plaque_h, plaque_t], rounding = 0.5, edges = EDGES_ALL, $fn = 16);
}
