// Skadis slide-on storage box: vase-mode bin that hangs on individual snap
// pegs pushed into the IKEA Skadis pegboard slots (40 mm grid).
// Two parts from one file: the box (part="box") and the snap peg
// (part="peg"); part="both" previews the box seated on its pegs in front of
// a ghost board.
// Mounting: push the pegs into two board slots tip-first, then slide the box
// straight down. The pockets in the box back wrap the peg fins and their
// ceilings seat on the fin tops; the pockets taper from a shallow entry at
// the bottom to a full wrap at the top so the fins slide in without snagging.
// Removal: lift ~10 mm so the fins clear the pockets, then pull forward.
// Box: vase mode (single wall, solid bottom). Length defaults to a multiple
// of the 40 mm pitch so two boxes mount side by side on the same hole grid.
// Peg: standard Skadis snap profile, 4.6 mm thick, 5 mm tip, 20 mm insert
// length (dimensions after franpoli's ikea_skadis.scad reference library;
// prints flat, profile face on the bed).
// The op-art pattern covers the front and both side walls only: the back
// wall faces the board and carries the peg pockets. The pattern envelope
// fades out before the top rim, so the rim is a complete uniform loop.

include <../../lib/BOSL2/std.scad>

// ================= PARAMETERS =================
/* [Parts to render] */
// Which part to render
part = "both"; // [box:Box, peg:Peg, both:Assembled]

/* [Box dimensions] */
// Outer length along X; keep a multiple of pitch for side-by-side boxes
length = 80; // [40:40:400]
// Outer depth along Y
depth = 30; // [30:256]
// Outer height along Z
height = 80; // [40:256]
// Corner rounding radius of the footprint
corner_r = 12; // [12:24]

/* [Pattern] */
// Wall pattern (front and sides only)
pattern = "waffle"; // [waffle:Waffle, ribs:Ribs, rings:Rings, none:None]
// Wave depth
pattern_amp = 1.2;
// Wave spacing
pattern_pitch = 12;

/* [Skadis board] */
// Hole spacing on the board
pitch = 40;
// Peg arm thickness (fits the slot width)
peg_t = 4.6;
// Peg tip width
peg_w = 5;
// Peg insert length
peg_len = 20;
// Retainer bump on the peg tip
peg_retainer = false;
// Distance from board face to the peg base plane when seated
peg_standoff = 8.5;
// Margin between box ends and the outermost pegs
end_margin = 15;

/* [Box-peg interface] */
// Box back hover gap in front of the peg fins
back_gap = 1.5;
// Side clearance around the fins inside the pockets
bulb_fit = 0.4;
// How far the pockets wrap behind the fin fronts
bulb_wrap = 0.8;
// Pocket ceiling rides above the fin top edge (print tolerance)
seat_clear = 0.2;
// Distance from the rim down to the pocket ceilings
bulb_below_rim = 12;
// Pocket height along Z
notch_h = 20;

/* [Quality] */
// Rendering resolution
$fn = 64;

// Hide customizer logic for all values below this
module __Customizer_Limit__ () {}

// Preview helper: lift the box this far in the assembled view to show the
// fins entering the pockets mid-mounting. Set via -D, not the customizer.
mount_lift = 0;

// ================= RENDER LOGIC =================
if (part == "box") vase_box();
else if (part == "peg") print_peg();
else {
    // Assembled preview rotated so the peg pockets on the back wall face
    // the camera; the default view angle would hide the interface.
    // mount_lift shows the box mid-mounting (fins entering the pockets).
    rotate([0, 0, 150]) {
        board_ghost();
        up(mount_lift) vase_box();
        for (px = peg_xs) mounted_peg(px, zc_peg());
    }
}

// ================= SANITY CHECKS =================
assert(length >= 2 * corner_r + 10,
    str("Straight back wall is only ", 2 * cx, " mm. Reduce corner_r or increase length."));
for (px = peg_xs)
    assert(abs(px) + bulb_w / 2 + 0.5 + 2 <= cx,
        str("Peg pocket at x = ", px, " runs into the back corner arc. Increase length or reduce end_margin."));
assert(bulb_top + 2 <= height, "Pocket ceilings must stay below the rim. Reduce bulb_below_rim.");
assert(notch_bot >= 6, "Pocket bottoms run into the bottom corner curve. Increase height or reduce notch_h.");
assert(depth >= box_back + 4,
    str("Depth ", depth, " mm leaves no interior depth behind the peg interface."));

// ================= INTERFACE DERIVED VALUES =================
// Mounted geometry: the board face is y = 0 and the peg fins sit at
// peg_standoff. The box back plane hovers at box_back. Model coords shift
// the box back plane to y_w = depth/2, so model_y = real_y + (y_w - box_back).
y_w = depth / 2;
box_back = peg_standoff + back_gap;
// Pegs distributed on the pitch grid, symmetric about the box center
n_pegs = max(1, floor((length - 2 * end_margin) / pitch) + 1);
peg_xs = [for (i = [0 : n_pegs - 1]) (i - (n_pegs - 1) / 2) * pitch];
// Pocket walls reach fold_deep behind the back plane, i.e. bulb_wrap behind
// the fin fronts; the entry stays fold_shallow in front of the fin fronts.
fold_deep = back_gap + bulb_wrap;
fold_shallow = back_gap - 1.2;
bulb_w = peg_t + 2 * bulb_fit;        // pocket width around the fin
bulb_top = height - bulb_below_rim;   // pocket ceiling = seat plane
notch_bot = bulb_top - notch_h;       // pocket bottom = fin entry

// Fin placement for the assembled preview: the pocket ceiling seats on the
// fin top edge where that edge crosses the deep fold line, seat_clear above.
// The fin profile top crosses the fold line 5.0 mm below the ceiling
// (4.8 mm profile rise + seat_clear).
seat_off = 4.8 + seat_clear;
function zc_peg() = bulb_top - seat_off;

// ================= PATH HELPERS =================
// Clamped 0..1 smooth transition between a and b.
function smoothstep(a, b, u) =
    let(t = min(1, max(0, (u - a) / (b - a)))) t * t * (3 - 2 * t);

// ================= PATTERN =================
perim = 2 * (length + depth);
function pattern_disp(t, z) =
    let(
        wt = sin(360 * t * perim / pattern_pitch),
        wz = sin(360 * z / pattern_pitch),
        env = sin(180 * z / height)
    )
    pattern == "ribs" ? pattern_amp * wt * env :
    pattern == "rings" ? pattern_amp * wz * env :
    pattern == "waffle" ? pattern_amp * wt * wz * env : 0;

// ================= POCKET PATH =================
// The pocket folds the back wall toward the cavity: shallow at the bottom
// (fin entry clears the fin front), full wrap at the top (walls grip the
// fin sides, ceiling seats on the fin top edge).
function notch_fold(z) =
    fold_shallow + (fold_deep - fold_shallow) * smoothstep(notch_bot + 2, bulb_top - 4, z);

// Entry funnel: the pocket flares slightly at the bottom to guide the fins
function notch_halfw(z) =
    bulb_w / 2 + 0.5 * (1 - smoothstep(notch_bot, notch_bot + 3, z));

function notch_on(z) = z <= bulb_top && z >= notch_bot;

// Pocket outline points for one peg; all carry the back-wall normal so the
// pattern gate suppresses displacement on them.
function notch_pts(px, z) =
    let(f = notch_fold(z), w2 = notch_halfw(z))
    [
        [[px + w2, y_w], [0, 1]],
        [[px + w2, y_w - f], [0, 1]],
        [[px - w2, y_w - f], [0, 1]],
        [[px - w2, y_w], [0, 1]]
    ];

// ================= BASE CORNERS & WALLS =================
cx = length / 2 - corner_r;
cy = depth / 2 - corner_r;
fn_c = 12;

// Perimeter corner arcs (CCW) with true radial normals
c_tr = [for (a = [0 : 90/fn_c : 90]) [[cx, cy] + corner_r*[cos(a), sin(a)], [cos(a), sin(a)]]];
c_tl = [for (a = [90 : 90/fn_c : 180]) [[-cx, cy] + corner_r*[cos(a), sin(a)], [cos(a), sin(a)]]];
c_bl = [for (a = [180 : 90/fn_c : 270]) [[-cx, -cy] + corner_r*[cos(a), sin(a)], [cos(a), sin(a)]]];
c_br = [for (a = [-90 : 90/fn_c : 0]) [[cx, -cy] + corner_r*[cos(a), sin(a)], [cos(a), sin(a)]]];

// Straight walls flanking the corners
wall_r = [for (y = [c_br[len(c_br)-1][0].y + 1.5 : 1.5 : c_tr[0][0].y - 0.5]) [[length/2, y], [1, 0]]];
wall_l = [for (y = [c_tl[len(c_tl)-1][0].y - 1.5 : -1.5 : c_bl[0][0].y + 0.5]) [[-length/2, y], [-1, 0]]];
front_plain = [for (x = [-cx : 1.5 : cx - 0.5]) [[x, -y_w], [0, -1]]];

// Back wall, walking +x to -x: plain samples, or samples interrupted by a
// folded pocket path at every peg position.
function back_wall(z) =
    let(ordered = [for (i = [0 : n_pegs - 1]) peg_xs[n_pegs - 1 - i]])
    !notch_on(z)
        ? [for (x = [cx - 1.5 : -1.5 : -cx + 0.5]) [[x, y_w], [0, 1]]]
        : concat(
            [for (x = [cx - 1.5 : -1.5 : ordered[0] + notch_halfw(z) + 0.75]) [[x, y_w], [0, 1]]],
            notch_pts(ordered[0], z),
            [for (i = [1 : n_pegs - 1]) each
                concat(
                    [for (x = [ordered[i-1] - notch_halfw(z) - 0.75 : -1.5 : ordered[i] + notch_halfw(z) + 0.75]) [[x, y_w], [0, 1]]],
                    notch_pts(ordered[i], z)
                )
            ],
            [for (x = [ordered[n_pegs - 1] - notch_halfw(z) - 0.75 : -1.5 : -cx + 0.5]) [[x, y_w], [0, 1]]]
        );

// Perimeter segments as [point, outward_normal] pairs.
function outline_raw(z) = concat(c_br, wall_r, c_tr, back_wall(z), c_tl, wall_l, c_bl, front_plain);

function outline_at(z) =
    let(raw = outline_raw(z))
    [
        for (i = idx(raw))
            let(
                p = raw[i][0],
                n = raw[i][1],
                // Pattern only on front and sides: the back wall faces the
                // board and carries the peg pockets.
                p_disp = (n[1] > 0.5) ? 0 : pattern_disp(i / len(raw), z)
            )
            p + n * p_disp
    ];

// Dense sampling near the pocket ceiling so the seat step stays flat
_zs_base = [for (z = [0 : 1.2 : height]) if (abs(z - bulb_top) > 0.5) z];
_zs_sorted = sort(concat(_zs_base, [bulb_top - 0.6, bulb_top, bulb_top + 0.2]));
zs = [for (i = [0 : len(_zs_sorted) - 1]) if (i == 0 || _zs_sorted[i-1] < _zs_sorted[i]) _zs_sorted[i]];

// ================= BOX =================
module vase_box() {
    skin([for (z = zs) path3d(outline_at(z), z)], slices = 0, caps = true);
}

// ================= PEG =================
// Standard Skadis snap profile (after franpoli's reference library).
// Peg frame: X = arm thickness, Y = profile width, Z = insert axis with the
// base plane at Z = 0 and the tip at Z = peg_len.
module skadis_peg() {
    pw = peg_w;
    pt = peg_t;
    ptl = peg_len;
    ptw = 3 * pw;
    intersection() {
        translate([-pt/2, -pw, 0]) cube([pt, ptw, ptl]);
        difference() {
            hull() {
                translate([-pt/2, ptw - 2*pw, ptl - pw]) cube([pt, pw, pw]);
                translate([-pt/2, (ptw - pw) - 2*pw, 2*pw/sqrt(2)])
                    rotate([0, 90, 0]) cylinder(h = pt, r = 2*pw);
            }
            hull() {
                translate([-pt/2 - 0.01, -pw - 0.01, ptl - pw + 0.01])
                    cube([pt + 0.02, pw + 0.02, pw + 0.02]);
                translate([-pt/2 - 0.01, -2*pw - 0.01, pw + 0.01])
                    cube([pt + 0.01, pw + 0.01, pw + 0.01]);
                translate([-pt/2 - 0.01, ptw - 3*pw - 0.01, ptl - pw + 0.01])
                    cube([pt + 0.01, pw + 0.01, pw + 0.01]);
            }
        }
    }
    // Optional tip retainer; note it doubles the tip thickness on one face,
    // so flip the peg in the slicer when printing with it enabled.
    if (peg_retainer) {
        hull() {
            translate([-pt/2, pw, 3*pw]) cube([pt, pw, pw]);
            translate([-pt/2 + 2, pw, 3*pw + 2]) cube([pt, pw, pw - 1.6]);
        }
    }
}

// Flat print orientation: profile face on the bed, thickness up.
module print_peg() {
    translate([0, peg_w, peg_t/2]) rotate([0, 90, 0]) skadis_peg();
}

// Mounted orientation for the assembled preview: base plane at
// peg_standoff, tip into the board, profile centered on (px, zc).
module mounted_peg(px, zc) {
    translate([px, peg_standoff, zc]) rotate([90, 0, 0]) skadis_peg();
}

// Translucent board stand-in for the assembled preview only
module board_ghost() {
    %translate([0, -3.2, bulb_top - 20]) cube([length + 60, 6.4, 160], center = true);
}
