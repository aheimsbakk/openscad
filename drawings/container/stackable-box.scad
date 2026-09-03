// Stackable vase-mode storage box with 1960s op-art stiffening pattern.
// Purpose: single-wall vase-printed box with a capping lid; boxes stack on lids.
// Notes:
//   - The model is SOLID by design (blocks, no hollow parts). Vase (spiral)
//     mode only prints the bottom fill plus the outermost contour, so a solid
//     block slices into exactly one continuous wall. Hollow or shelled models
//     produce extra contours and break vase mode.
//   - Print "box" and "lid" as SEPARATE vase mode jobs:
//     openscad -o box.stl -D part=box drawings/container/stackable-box.scad
//     openscad -o lid.stl -D part=lid drawings/container/stackable-box.scad
//   - Set `wall` of the print = one extrusion line width in the slicer; the
//     pattern is what stiffens that single line.
//   - Lid plate must fit inside the vase bottom fill: set slicer bottom layers
//     to at least lid_plate_t / layer_height (8 layers at 0.2 mm).

include <../../lib/BOSL2/std.scad>

// ================= PARAMETERS =================
/* [Part] */
part = "both";  // ["box", "lid", "both"]

/* [Box] */
length = 100;    // outer length (X), mm
width = 70;      // outer width (Y), mm
height = 55;     // wall height, mm
corner_r = 12;   // corner rounding, mm

/* [Pattern: 1960s op-art stiffening] */
pattern = "waffle";  // ["waffle", "ribs", "rings", "none"]
pattern_amp = 1.2;   // radial wave depth, mm
pattern_pitch = 12;  // wave period along wall and height, mm

/* [Label plaque (front, -Y)] */
plaque_w = 50;      // plaque width, mm
plaque_h = 22;      // plaque height, mm
plaque_z = 30;      // plaque center height, mm
plaque_d = 1.8;     // plaque raise, mm; must exceed pattern_amp to stand clear
plaque_blend = 6;   // shoulder blend width, mm

/* [Lid] */
lid_rim_h = 10;     // rim height wrapping the box base, mm
lid_fit = 1.5;      // box base to printed rim wall clearance, mm (incl. line width)
lid_plate_t = 1.6;  // lid plate thickness (vase bottom fill), mm
lid_ledger = 2.0;   // plate ledge beyond rim, mm

$fn = 64;

// ================= RENDER LOGIC =================
if (part == "box") {
    vase_box();
} else if (part == "lid") {
    vase_lid();
} else {
    vase_box();
    right(length / 2 + (length + 2 * (lid_fit + lid_ledger)) / 2 + 10)
        vase_lid();
}

// ================= SANITY CHECKS =================
assert(plaque_w + 2 * plaque_blend <= length - 2 * corner_r,
    "Plaque plus blend does not fit on the front face.");
assert(plaque_z + plaque_h / 2 + plaque_blend <= height,
    "Plaque plus blend does not fit below the top rim.");
assert(lid_fit >= pattern_amp * sin(180 * lid_rim_h / height) + 0.65,
    "Lid clearance smaller than the wall wave near the base plus line width.");

// ================= PATH HELPERS =================
// Clamped 0..1 smooth transition between a and b (BOSL2 has no smoothstep).
function smoothstep(a, b, u) =
    let(t = min(1, max(0, (u - a) / (b - a)))) t * t * (3 - 2 * t);

// Smooth plateau window: 1 inside [a, b], fading to 0 over `blend` outside.
function window(u, a, b, blend) =
    smoothstep(a - blend, a, u) * (1 - smoothstep(b, b + blend, u));

function dot2(u, v) = u.x * v.x + u.y * v.y;

// ================= BASE OUTLINE =================
raw_path = rect([length, width], rounding = corner_r);
perim = path_length(raw_path);
// Resample so the straight faces carry enough points for the waves.
base_path = resample_path(raw_path, n = max(96, ceil(perim / 1.5)));
// Normals must point outward regardless of the winding rect() returns.
_raw_norms = path_normals(base_path, closed = true);
_flip = dot2(_raw_norms[0], base_path[0]) < 0 ? -1 : 1;
outward = [for (n = _raw_norms) n * _flip];

// ================= WALL DISPLACEMENT =================
// Radial wall displacement at arc position t (0..1) and height z.
// The sin(180*z/height) envelope forces a flat bottom edge and flat top rim,
// which is what lets the box sit on the lid and stack cleanly.
function pattern_disp(t, z) =
    let(
        wt = sin(360 * t * perim / pattern_pitch),
        wz = sin(360 * z / pattern_pitch),
        env = sin(180 * z / height)
    )
    pattern == "ribs" ? pattern_amp * wt * env :
    pattern == "rings" ? pattern_amp * wz * env :
    pattern == "waffle" ? pattern_amp * wt * wz * env : 0;

// Raised plaque on the front face only (front = -Y, base points at y = -width/2).
// Outward pillow instead of a recess: the printed single wall keeps full
// thickness and the writing surface stays on the smooth outer contour.
function plaque_zone(p, z) =
    (p.y < -width / 2 + 0.01)
        ? window(z, plaque_z - plaque_h / 2, plaque_z + plaque_h / 2, plaque_blend)
          * window(p.x, -plaque_w / 2, plaque_w / 2, plaque_blend)
        : 0;

// Outline at height z: base path pushed along outward normals. The pattern is
// suppressed inside the plaque zone so the writing surface stays flat.
function outline_at(z) = [
    for (i = idx(base_path))
        let(
            pz = plaque_zone(base_path[i], z),
            d = pattern_disp(i / len(base_path), z) * (1 - pz) + plaque_d * pz
        )
        base_path[i] + outward[i] * d
];

// z samples dense enough for the height waves (10 slices per pitch).
dz = pattern_pitch / 10;
_zs_raw = [for (z = [0:dz:height]) z];
zs = (select(_zs_raw, -1) == height) ? _zs_raw : concat(_zs_raw, [height]);

// ================= BOX =================
// Solid block: the displaced outer surface lofted over the full height and
// closed with cap discs. Vase mode prints only its outer contour.
module vase_box() {
    union() {
        skin([for (z = zs) path3d(outline_at(z), z)], slices = 0, closed = true);
        linear_extrude(0.2) polygon(outline_at(0));
        up(height - 0.2) linear_extrude(0.2) polygon(outline_at(height - 0.2));
    }
}

// ================= LID =================
// Solid tray: plate plus a solid rim block. The printed spiral runs along the
// rim's outer contour, which is sized so the box base nests inside it
// (1960s cooler style stacking: box sits on the lid below it).
module vase_lid() {
    rim_out = rect([length + 2 * lid_fit, width + 2 * lid_fit],
        rounding = corner_r + lid_fit);
    plate_out = offset(rim_out, r = lid_ledger);
    union() {
        linear_extrude(lid_plate_t) polygon(plate_out);
        up(lid_plate_t) linear_extrude(lid_rim_h) polygon(rim_out);
    }
}
