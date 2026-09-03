// Stackable vase-mode storage box: 1960s op-art stiffening pattern, front
// slide-in plaque pocket, lid, and nesting stacking. The model is SOLID by
// design (blocks, no hollow parts): vase (spiral) mode prints only the bottom
// fill plus the outer contour of a solid block, which yields exactly one
// continuous wall. Hollow models break vase mode.
// Box and lid print as separate vase jobs (-D part=box / -D part=lid), the
// plaque prints flat (-D part=plaque), e.g.:
//   openscad -o box.stl --export-format binstl -D 'part="box"' drawings/container/stackable-box.scad
// Stacking: the top of the box has a smooth recess (inset stack_inset over
// the top stack_depth mm); the bottom of the next box is inset by
// stack_inset - stack_fit and sinks stack_depth into that recess, resting on
// the recess ledge. Each stacked box adds height - stack_depth of height.
// Pocket: the plaque slides down from the top between the clamp rails,
// rests on the ledge, and the funnel shoulder above the channel stops it
// tipping forward. Fits plaques up to plaque_t. The pocket exists only on
// the front face; the back is a plain patterned wall.
// Slicer: bottom layers >= lid_plate_t / layer_height (8 layers at 0.2 mm).

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
pattern = "waffle";  // ["waffle", "ribs", "rings", "none"]
pattern_amp = 1.2;   // radial wave depth, mm
pattern_pitch = 12;  // wave period along wall and height, mm

/* [Plaque pocket (front, -Y)] */
plaque_w = 50;      // plaque width, mm
plaque_h = 22;      // plaque height, mm
pocket_z = 29;      // plaque center height when seated, mm
plaque_t = 1.5;     // max plaque thickness the pocket accepts, mm
pocket_fit = 0.4;   // clearance around the plaque (sides and depth), mm
pocket_blend = 3;   // frame shoulder width, mm
guide_h = 5;        // channel extension above the seated plaque, mm
rail_w = 4;         // clamp rail width, mm
rail_grip = 0.15;   // rail protrusion beyond the plaque face, mm
rail_blend = 1.5;   // clamp rail blend width, mm

/* [Stacking] */
stack_depth = 5;      // how far the bottom sinks into the box below, mm
stack_inset = 1.2;    // top recess inset (also the bearing ledge width), mm
stack_fit = 0.4;      // total side clearance between insert and recess, mm
stack_blend = 2;      // transition width below both inset zones, mm
stack_count = 1;      // boxes in the preview stack ("both" only)

/* [Lid] */
lid_rim_h = 10;     // rim height wrapping the box top, mm
lid_fit = 1.5;      // box top to printed rim wall clearance, mm (incl. line width)
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
    // Boxes nested: each one sinks stack_depth into the one below.
    for (i = [0:stack_count - 1])
        up(i * (height - stack_depth)) vase_box();
    right(lid_cx) vase_lid();
    right(plaque_cx) vase_plaque();
}

// ================= SANITY CHECKS =================
assert(plaque_w + 2 * (pocket_fit + rail_w + pocket_blend) <= length - 2 * corner_r, "Pocket plus frame does not fit on the front face.");
assert(pocket_z + plaque_h / 2 + guide_h + pocket_blend <= height - stack_depth - stack_blend, "Pocket channel must clear the stacking recess at the top.");
assert(lid_fit >= pattern_amp * sin(180 * lid_rim_h / height) + 0.65, "Lid clearance smaller than the wall wave near the top plus line width.");
assert(stack_fit < stack_inset, "Recess fit clearance must stay below the recess inset, or the upper box has no bearing ledge.");

// ================= PATH HELPERS =================
// Clamped 0..1 smooth transition between a and b (BOSL2 has no smoothstep).
function smoothstep(a, b, u) =
    let(t = min(1, max(0, (u - a) / (b - a)))) t * t * (3 - 2 * t);

// Smooth plateau window: 1 inside [a, b], fading to 0 over `blend` outside.
function window(u, a, b, blend) =
    smoothstep(a - blend, a, u) * (1 - smoothstep(b, b + blend, u));

// window() with the blend inside the band: 0 at the edges, never spreads
// past [a, b].
function window_in(u, a, b, blend) =
    smoothstep(a, a + blend, u) * (1 - smoothstep(b - blend, b, u));

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
// Radial displacement at arc position t (0..1) and height z. The
// sin(180*z/height) envelope forces a flat bottom edge and flat top rim,
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

pocket_depth = plaque_t + pocket_fit;
channel_half = plaque_w / 2 + pocket_fit;  // slide channel, fit on each side
rail_depth = pocket_fit - rail_grip;       // rails proud of the plaque face
// Bottom footprint inset. Smaller than the recess inset so the insert keeps
// stack_fit of side clearance, and the recess ledge (stack_inset wide) bears
// the box above.
insert_inset = stack_inset - stack_fit;

// Pocket z-profile: ledge below the seated plaque, deep channel, guide
// extension above. Lower shoulder = ledge; upper shoulder = funnel that
// stops the plaque tipping forward.
function pocket_zwin(z) =
    window(z, pocket_z - plaque_h / 2 - pocket_fit,
           pocket_z + plaque_h / 2 + guide_h, pocket_blend);

// Full-depth channel, centered on the front face.
function channel_xwin(x) = window(x, -channel_half, channel_half, pocket_blend);

// Clamp rails flanking the channel. Blends stay inside the band so the rails
// never narrow the channel below the plaque width.
function rail_xwin(x) =
    let(a = channel_half, b = a + rail_w)
    window_in(x, a, b, rail_blend) + window_in(-x, a, b, rail_blend);

// Front-face indicator: pocket geometry (cut and pattern suppression)
// exists only on the front (-Y) face, never on the back or corners.
function is_front(p) = p.y < -width / 2 + 0.01 ? 1 : 0;

// Front-face zone for pattern suppression (channel + rails + frame band).
function pocket_zone(p, z) =
    is_front(p)
        ? pocket_zwin(z)
          * window(p.x, -(channel_half + rail_w), channel_half + rail_w, pocket_blend)
        : 0;

// Stacking recess: inward step over the top stack_depth; the shoulder below
// it is the ledge the upper box rests on.
function neck_zone(z) = window(z, height - stack_depth, height, stack_blend);

// Bottom insert: inset over the lower stack_depth, so the box sinks into the
// recess of the box below. Blends back to the full wall just above the
// engagement depth.
function base_zone(z) = 1 - smoothstep(stack_depth, stack_depth + stack_blend, z);

// Outline at height z: base path pushed along outward normals. Pattern is
// suppressed under pocket, stacking recess and bottom insert. Channel wall
// sits at pocket_depth, the clamp rails only at rail_depth.
function outline_at(z) = [
    for (i = idx(base_path))
        let(
            p = base_path[i],
            pz = pocket_zone(p, z),
            nz = neck_zone(z),
            bz = base_zone(z),
            ch = channel_xwin(p.x),
            rl = rail_xwin(p.x),
            d = pattern_disp(i / len(base_path), z) * (1 - pz) * (1 - nz) * (1 - bz)
                - is_front(p) * pocket_zwin(z)
                  * (pocket_depth * ch * (1 - rl) + rail_depth * rl)
                - stack_inset * nz
                - insert_inset * bz
        )
        p + outward[i] * d
];

// z samples dense enough for the height waves (10 slices per pitch).
dz = pattern_pitch / 10;
_zs_raw = [for (z = [0:dz:height]) z];
zs = (select(_zs_raw, -1) == height) ? _zs_raw : concat(_zs_raw, [height]);

// ================= BOX =================
// Solid block: displaced surface lofted over the full height, closed with
// cap discs. Vase mode prints only its outer contour.
module vase_box() {
    union() {
        skin([for (z = zs) path3d(outline_at(z), z)], slices = 0, closed = true);
        linear_extrude(0.2) polygon(outline_at(0));
        up(height - 0.2) linear_extrude(0.2) polygon(outline_at(height - 0.2));
    }
}

// ================= LID =================
// Solid tray: plate plus rim block; the printed spiral runs along the rim's
// outer contour, which wraps the box top.
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
// Flat plate, printed normally (no vase mode). Softened edges ease sliding
// into the pocket.
module vase_plaque() {
    offset_sweep(rect([plaque_w, plaque_h], rounding = 3),
        height = plaque_t - 0.3, rounding = 0.6);
}
