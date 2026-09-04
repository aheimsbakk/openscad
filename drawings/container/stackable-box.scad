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
// All pocket Z transitions derive from height and the stack parameters, and
// the plaque self-centers at half the box height — see [Plaque pocket].
// Lid: a simple rounded cap wrapping the box lip (the top stacking recess
// band) with adjustable clearance; its height equals the lip.

include <../../lib/BOSL2/std.scad>

// ================= PARAMETERS =================
/* [Part] */
part = "both";  // ["box", "lid", "plaque", "both"]

/* [Box] */
length = 60;    // outer length (X), mm
width = 60;      // outer width (Y), mm
height = 30;     // wall height, mm
corner_r = 12;   // corner rounding, mm

/* [Pattern: 1960s op-art stiffening] */
pattern = "waffle";  // ["waffle", "ribs", "rings", "none"]
pattern_amp = 1.2;   // radial wave depth, mm
pattern_pitch = 12;  // wave period along wall and height, mm

/* [Plaque pocket (front, -Y)] */
// pocket_z is derived, not set: the plaque centers at height/2, clamped into
// the clear band between the stacking zones. Small-box recipe (50x50x25),
// pass together with the size overrides:
// -D 'length=50' -D 'width=50' -D 'height=25' -D 'stack_depth=4'
// -D 'stack_blend=1.5' -D 'plaque_h=6' -D 'guide_h=2'
plaque_w = 25;      // plaque width, mm
plaque_h = 10;      // plaque height, mm
plaque_t = 1;     // max plaque thickness the pocket accepts, mm
pocket_fit = 0.4;   // clearance around the plaque (sides and depth), mm
lip_w = 1.5;        // retaining lip overlap in X over plaque edge, mm
lip_t = 1.2;        // retaining lip thickness in Y, mm
bracket_w = 2.0;    // outer frame rib width beyond slot, mm
guide_h = 2;        // channel extension above the seated plaque, mm
ledge_ramp_h = 5;  // ledge forward-ramp length below the seated ledge, mm

/* [Stacking] */
stack_depth = 5;      // how far the bottom sinks into the box below, mm
stack_inset = 1.2;    // top recess inset (bearing ledge width), mm
stack_fit = -1;      // side clearance between insert and recess, mm
stack_blend = 2;      // transition width below both inset zones, mm
stack_count = 1;      // boxes in the preview stack ("both" only)

/* [Lid] */
// Simple rounded cap wrapping the box lip (the top stacking recess band).
// Height equals the lip. lid_fit sets the clearance around the lip: lower
// for a tighter grip, raise if the lid is hard to slide on.
lid_fit = 0.8;      // clearance around the lip band, mm

$fn = 64;

// ================= RENDER LOGIC =================
// Lid footprint matches the recessed lip band plus clearance.
lid_outer = length - 2 * stack_inset + 2 * lid_fit;
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
assert(plaque_w + 2 * (pocket_fit + bracket_w) <= length - 2 * corner_r,
    str("Pocket frame needs ", plaque_w + 2 * (pocket_fit + bracket_w),
        " mm, but the straight front face is only ", length - 2 * corner_r,
        " mm. Reduce plaque_w, pocket_fit, or bracket_w, or increase length."));
assert(plaque_h + guide_h + 4 <= height - 2 * (stack_depth + stack_blend),
    str("The plaque window is empty: centered placement needs ", plaque_h + guide_h + 4,
        " mm of clear height, but only ", height - 2 * (stack_depth + stack_blend),
        " mm fits between the stacking zones. Reduce plaque_h, guide_h, stack_depth, or stack_blend, or increase height."));
assert(lid_fit >= 0.65,
    str("lid_fit = ", lid_fit, " mm is below one printed line width plus tolerance (0.65 mm). Increase lid_fit."));
assert(corner_r + lid_fit > stack_inset,
    str("Lid corner rounding (corner_r - stack_inset + lid_fit = ", corner_r - stack_inset + lid_fit,
        " mm) would go negative. Increase corner_r or lid_fit, or reduce stack_inset."));
assert(stack_fit < stack_inset, "Recess fit clearance must stay below recess inset, or upper box has no bearing ledge.");

// ================= PATH HELPERS =================
// Clamped 0..1 smooth transition between a and b.
function smoothstep(a, b, u) =
    let(t = min(1, max(0, (u - a) / (b - a)))) t * t * (3 - 2 * t);

// ================= POCKET CONSTANTS =================
slot_w = plaque_w + 2 * pocket_fit;
slot_x0 = slot_w / 2;
slot_d = plaque_t + pocket_fit;
x_bracket_out = slot_x0 + bracket_w;

y_wall = -width / 2;
y_slot_open = y_wall - slot_d;
y_front_open = y_slot_open - lip_t;
bracket_proj = y_wall - y_front_open;

// Height-relative feature levels so any box height renders a valid pocket.
z_neck0 = height - stack_depth - stack_blend; // top recess transition start
z_lid_seat = height - stack_depth; // lid seat plane = top of the recess ramp;
// the recess band and the lid wrap share it, so the pocket only needs to
// clear z_neck0.

// Plaque self-centering: target half the box height, clamped into the clear
// window between the bottom stacking zone and the top recess / lid band.
// The window assert above guarantees pz_lo <= pz_hi, so the clamp result
// always satisfies both the ledge and funnel clearances.
pz_lo = stack_depth + stack_blend + 4 + plaque_h / 2;
pz_hi = z_neck0 - guide_h - plaque_h / 2;
pocket_z = min(max(height / 2, pz_lo), pz_hi);

z_ledge = pocket_z - plaque_h / 2;
z_plaque_top = pocket_z + plaque_h / 2;
// Ledge ramp must never start below the bottom insert zone, or the insert
// bulges and no longer nests into the box below.
z_ramp0 = max(stack_depth + stack_blend, z_ledge - ledge_ramp_h);
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

// Perimeter segments as [point, outward_normal] pairs. True surface normals
// (radial from each arc's own center, axis normals on straight walls) keep
// the displacement field continuous across segment junctions; deriving the
// normal from the point position (unit(p)) deviates up to ~39 degrees at the
// tangent junctions and cut a visible notch into the stacking inset and the
// pattern. The duplicated tangent points each carry their own edge normal,
// so offsets behave like a true polygon offset. Front and pocket points
// share [0,-1] so collapsed pocket features stay flush with the wall.
// Corner arcs (CCW)
c_tr = [for (a = [0 : 90/fn_c : 90]) [[cx, cy] + corner_r*[cos(a), sin(a)], [cos(a), sin(a)]]];
c_tl = [for (a = [90 : 90/fn_c : 180]) [[-cx, cy] + corner_r*[cos(a), sin(a)], [cos(a), sin(a)]]];
c_bl = [for (a = [180 : 90/fn_c : 270]) [[-cx, -cy] + corner_r*[cos(a), sin(a)], [cos(a), sin(a)]]];
c_br = [for (a = [-90 : 90/fn_c : 0]) [[cx, -cy] + corner_r*[cos(a), sin(a)], [cos(a), sin(a)]]];

// Wall points along straight segments
wall_r = [for (y = [c_br[len(c_br)-1][0].y + 1.5 : 1.5 : c_tr[0][0].y - 0.5]) [[length/2, y], [1, 0]]];
wall_t = [for (x = [c_tr[len(c_tr)-1][0].x - 1.5 : -1.5 : c_tl[0][0].x + 0.5]) [[x, width/2], [0, 1]]];
wall_l = [for (y = [c_tl[len(c_tl)-1][0].y - 1.5 : -1.5 : c_bl[0][0].y + 0.5]) [[-length/2, y], [-1, 0]]];

// Front wall segments flanking the bracket
front_l = [for (x = [-cx : 1.5 : -x_bracket_out - 0.5]) [[x, y_wall], [0, -1]]];
front_r = [for (x = [x_bracket_out + 0.5 : 1.5 : cx]) [[x, y_wall], [0, -1]]];

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

// Raw outline at height z as [point, outward_normal] pairs: the perimeter
// with C-channel brackets and resting ledge, before displacement. Exposed as
// its own function so tooling can inspect the normal field directly.
function outline_raw(z) =
    let(
        // Bracket outer ribs: start above the bottom insert zone, fade out
        // completely before the lid seat plane
        b_act = smoothstep(stack_depth + stack_blend, stack_depth + stack_blend + 3, z)
              * (1 - smoothstep(z_lid_seat - 3, z_lid_seat, z)),
        y_b_front = y_wall - bracket_proj * b_act,

        // Resting ledge forms a forward shelf below z_ledge, chamfers back above
        ledge_act = smoothstep(z_ramp0, z_ledge, z) * (1 - smoothstep(z_ledge, z_ledge + 2.5, z)),
        y_c = y_wall - bracket_proj * ledge_act,

        // Front retaining lips grip plaque edges, funnel open at top
        lip_act = smoothstep(z_ledge - 1.5, z_ledge + 0.5, z) * (1 - smoothstep(z_plaque_top, z_plaque_top + guide_h, z)),
        x_li = slot_x0 - lip_w * lip_act,

        // Slot cavity opens above resting ledge, closes before the lid seat
        slot_act = smoothstep(z_ledge, z_ledge + 2.5, z) * (1 - smoothstep(z_lid_seat - 3, z_lid_seat, z)),
        y_s = y_b_front + (y_slot_open - y_b_front) * slot_act,

        // Front perimeter with C-channels [ ] and center ledge/pocket
        front_bracket = [
            [[-x_bracket_out, y_wall], [0, -1]],
            [[-x_bracket_out, y_b_front], [0, -1]],
            [[-x_li, y_b_front], [0, -1]],
            [[-x_li, y_s], [0, -1]],
            [[-slot_x0, y_s], [0, -1]],
            [[-slot_x0, y_c], [0, -1]],
            each [for (x = center_xs) [[x, y_c], [0, -1]]],
            [[slot_x0, y_c], [0, -1]],
            [[slot_x0, y_s], [0, -1]],
            [[x_li, y_s], [0, -1]],
            [[x_li, y_b_front], [0, -1]],
            [[x_bracket_out, y_b_front], [0, -1]],
            [[x_bracket_out, y_wall], [0, -1]]
        ],
        full_front = concat(front_l, front_bracket, front_r),
        rest = concat(c_br, wall_r, c_tr, wall_t, c_tl, wall_l, c_bl)
    )
    concat(full_front, rest);

// Outline at height z: displace the raw perimeter along its per-point
// normals with the pattern wave (suppressed inside the pocket) and the
// stacking inset.
function outline_at(z) =
    let(
        nz = neck_zone(z),
        bz = base_zone(z),
        raw = outline_raw(z)
    )
    [
        for (i = idx(raw))
            let(
                p = raw[i][0],
                n = raw[i][1],
                in_pocket = (p.y < y_wall + 0.01 && abs(p.x) <= x_bracket_out + 1.0),
                p_disp = in_pocket ? 0 :
                    pattern_disp(i / len(raw), z) * (1 - nz) * (1 - bz),
                d_stack = (bz > 0 ? -insert_inset * bz : (nz > 0 ? -stack_inset * nz : 0))
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
// Simple rounded cap wrapping the lip band (the top stacking recess) with
// lid_fit clearance; height equals the lip. Modeled solid — vase printing
// turns it into a hollow cap whose ceiling plate stops the lip at full seat.
lid_h = stack_depth;

module vase_lid() {
    lip_out = rect(
        [length - 2 * stack_inset + 2 * lid_fit, width - 2 * stack_inset + 2 * lid_fit],
        rounding = corner_r - stack_inset + lid_fit);
    linear_extrude(lid_h) polygon(lip_out);
}

// ================= PLAQUE =================
module vase_plaque() {
    cuboid([plaque_w, plaque_h, plaque_t], rounding = 0.5, edges = EDGES_ALL, $fn = 16);
}
