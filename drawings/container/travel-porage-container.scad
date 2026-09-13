// Travel porridge container: a hollow cup sized by its INTERNAL
// dimensions — a cylinder for the porridge box plus a side pocket block
// for a spoon. box_d, box_h, pocket_w and pocket_d are the usable inner
// space; the wall adds wall_t around the silhouette and the floor adds
// box_plate_t below it (outer height = box_h + box_plate_t, outer
// diameter = box_d + 2 * wall_t). The wall runs uniform around the
// silhouette, through the base fillet (concentric arcs), and around the
// neck step under the lid.
// Rounding: the pocket's vertical edges and its junctions into the cylinder
// are rounded in the footprint (offset), the bottom edge gets a circular
// fillet (offset_sweep). Internal dimensions stay exact in both cases.
// Lid: a cap that wraps the whole silhouette (cylinder + pocket). Its
// outer wall is flush with the container's main outer wall; the skirt
// overlaps the wall by lid_overlap and caps the top with a lid_plate_t
// plate. To keep the outer envelope unchanged, the container's neck is
// narrowed by a straight step over the lid overlap (same silhouette,
// scaled in by the skirt thickness plus the clearance); the step also
// acts as a stop so the lid can only seat one lid_overlap deep. The lid
// top edge carries the same base_r fillet as the container's bottom edge.
// The lid prints upside down (plate on the bed, skirt ring rising) and
// is modeled that way; the seated fit is shown as a preview ghost.
// Optional snap bead: a ring on the skirt's inner wall clicks into a
// groove in the neck wall bead_lift above the seat line. Effective snap
// depth is bead_h - lid_fit; turn off with bead=false to remove both
// bead and groove.
    // Export the container (normal solid print: floor, walls, open top):
    //   openscad -o travel-porage-container.stl --export-format binstl -D 'show="container"' drawings/container/travel-porage-container.scad
    // Export the lid (print it as modeled: plate on the bed, skirt up):
    //   openscad -o travel-porage-lid.stl --export-format binstl -D 'show="lid"' drawings/container/travel-porage-container.scad
    // With show="both" the lid stands beside the container, both in print
    // orientation.

include <../../lib/BOSL2/std.scad>

// ================= PARAMETERS =================
/* [Porridge box space] */
// Internal diameter: porridge box diameter plus a fit clearance
box_d = 85; // [60:120]
// Internal height: usable depth from floor top to rim
box_h = 130; // [80:200]

/* [Spoon pocket] */
// Internal pocket length along X; the pocket reaches pocket_w / 2 into
// the reserved side space
pocket_w = 30; // [15:60]
// Internal pocket width along Y
pocket_d = 30; // [15:60]

/* [Rounding] */
// Bottom fillet radius where the wall meets the floor
base_r = 6; // [0:16]
// Radius for the pocket edges and their junctions into the cylinder
edge_r = 6; // [0:12]

/* [Walls] */
// Wall thickness of the hollowed container
wall_t = 3; // [2:0.2:6]
// Floor plate thickness
box_plate_t = 3; // [2:0.5:8]

/* [Lid] */
// Skirt overlap down the container wall (the lid seat length)
lid_overlap = 30; // [6:1:40]
// Radial clearance between lid skirt and container neck
lid_fit = 0.4; // [0.2:0.05:1.0]
// Lid skirt wall thickness
lid_skirt_t = 2; // [1.2:0.2:4]
// Lid top plate thickness
lid_plate_t = 3; // [2:0.5:6]

/* [Snap bead] */
// Snap bead locking the lid to the neck (adds a matching groove)
bead = true;
// Bead protrusion; effective snap depth = bead_h - lid_fit
bead_h = 1.0; // [0.6:0.1:2]
// Bead band height along the wall
bead_w = 1.2; // [0.8:0.2:3]
// Distance from the skirt's bottom edge up to the bead
bead_lift = 2; // [1:1:10]

// Which part to render: both (beside each other), container, or lid
show = "both"; // [both, container, lid]

/* [Quality] */
// Rendering resolution: coarse in preview for speed, full for export
$fn = $preview ? 32 : 96;

$fs = $preview ? 1 : 0.1;  // Minimum facet size
$fa = $preview ? 12 : 1;   // Minimum angle (degrees)


// Hide customizer logic for all values below this
module __Customizer_Limit__ () {}

// ================= DERIVED VALUES =================
// Outer height of the container: internal height plus the floor plate.
outer_h = box_h + box_plate_t;
// Total narrowing of the container neck under the lid skirt.
neck_inset = lid_skirt_t + lid_fit;
// Height of the step where the neck inset starts: the lid's seat line.
z_seat = outer_h - lid_overlap;

// ================= SANITY CHECKS =================
assert(pocket_d > 2 * edge_r,
    str("edge_r = ", edge_r, " mm exceeds half the pocket depth (", pocket_d / 2,
        " mm). Reduce edge_r or increase pocket_d."));
assert(pocket_w > 2 * edge_r,
    str("edge_r = ", edge_r, " mm consumes the pocket's contact with the cylinder. Reduce edge_r or increase pocket_w."));
assert(box_d > 2 * (edge_r + base_r - wall_t),
    str("The base fillet (radius ", base_r, " mm) plus the edge rounding swallow the internal cylinder. Reduce the rounding or increase box_d."));
assert(box_h + box_plate_t > lid_overlap + base_r,
    str("The container (outer height ", box_h + box_plate_t, " mm) is too short for the lid seat (", lid_overlap, " mm) plus the base fillet. Increase box_h."));
assert(wall_t > neck_inset + 0.4,
    str("wall_t = ", wall_t, " mm must exceed the neck inset (", neck_inset, " mm) plus one extrusion line, or the neck walls vanish. Reduce lid_skirt_t or lid_fit, or increase wall_t."));
assert(wall_t < base_r,
    str("wall_t = ", wall_t, " mm must stay below the base fillet radius (", base_r, " mm) so the inner fillet keeps a positive radius."));
assert(box_d > 2 * (edge_r + neck_inset),
    str("The neck inset (", neck_inset, " mm) plus the edge rounding swallow the internal cylinder. Reduce lid_skirt_t or lid_fit, or increase box_d."));
assert(pocket_w > edge_r + 2 * neck_inset && pocket_d > 2 * edge_r + 2 * neck_inset,
    str("The neck inset (", neck_inset, " mm) plus the edge rounding swallow the pocket. Reduce lid_skirt_t or lid_fit, or increase the pocket."));
assert(!bead || bead_h > lid_fit + 0.2,
    str("bead_h = ", bead_h, " mm must exceed lid_fit (", lid_fit, " mm) by at least 0.2 mm, or the bead never engages the groove."));
assert(!bead || bead_lift + bead_w < lid_overlap - 2,
    str("The bead (lift ", bead_lift, " + height ", bead_w, " mm) does not fit inside the lid overlap (", lid_overlap, " mm). Reduce the bead or increase lid_overlap."));
assert(!bead || wall_t > bead_h + 0.8,
    str("wall_t = ", wall_t, " mm leaves less than 0.8 mm of neck wall under the ", bead_h, " mm groove. Reduce bead_h or increase wall_t."));

// ================= SILHOUETTE =================
// All silhouettes come from one parametric raw footprint grown by delta on
// all sides, rounded by a SINGLE offset. Chained offsets (offset of an
// already-offset path) produce degenerate vertex structures that crash
// CGAL in 3D booleans, so every surface must be derived directly from raw.
// delta is the radial distance from the internal surface: 0 = internal,
// wall_t = outer, wall_t - neck_inset = neck outer, wall_t - lid_skirt_t =
// lid skirt inner, negative deltas = cavities inside the internal space.
// Note: corner rounding stays edge_r for every delta (a true parallel
// offset would grow the corner radius); the deviation only softens pocket
// corners by fractions of a millimeter and preserves all fits because
// mating surfaces share the same construction.
function raw(delta) = union([
    circle(d = box_d - 2 * edge_r + 2 * delta),
    move([-box_d / 2 + edge_r / 2, 0],
         rect([pocket_w - edge_r + 2 * delta, pocket_d - 2 * edge_r + 2 * delta]))]);

// INTERNAL silhouette: the cavity footprint, exact internal size.
inner = offset(raw(0), r = edge_r);
// Outer silhouette: internal grown by the wall thickness.
wall = offset(raw(wall_t), r = edge_r);

// Neck silhouette: the outer wall narrowed for the lid's inner cavity plus
// the clearance (delta wall_t - neck_inset).
wall_neck = offset(raw(wall_t - neck_inset), r = edge_r);
// Neck cavity: the neck inset by the wall thickness.
neck_cavity = offset(raw(-neck_inset), r = edge_r);
// Snap bead geometry: the groove ring is the band between the neck outer
// surface grown by bead_h and the same surface embedded 0.01 mm inward
// (embedding avoids coplanar faces); the bead ring is the matching band
// on the skirt's inner wall, embedded into the skirt.
groove_ring = difference(offset(raw(wall_t - neck_inset + bead_h), r = edge_r),
    offset(raw(wall_t - neck_inset - 0.01), r = edge_r));
// Bead ring: protrudes INWARD from the skirt's inner wall (delta
// wall_t - lid_skirt_t), tip at delta wall_t - lid_skirt_t - bead_h,
// embedded 0.01 mm into the skirt wall on its outer boundary.
bead_ring = difference(offset(raw(wall_t - lid_skirt_t + 0.01), r = edge_r),
    offset(raw(wall_t - lid_skirt_t - bead_h), r = edge_r));
// Cavity bottom fillet radius: concentric with the outer base fillet.
cavity_r = base_r - wall_t;

// ================= MAIN MODULE =================
module travel_porage_container()
    // Hollow cup: the outer block (full silhouette up to the neck step,
    // inset silhouette over the lid overlap) minus the internal cavity.
    // The cavity fillet has radius base_r - wall_t, so the wall keeps its
    // thickness through the bottom curve; the floor is a box_plate_t
    // plate under the box_h deep cavity; the neck cavity steps in with
    // the outer step and runs past the rim to leave it open.
    difference() {
        union() {
            offset_sweep(wall, height = z_seat, bottom = os_circle(r = base_r));
            up(z_seat)
                if (bead)
                    // Neck band with the groove for the lid's snap bead.
                    difference() {
                        offset_sweep(wall_neck, height = lid_overlap);
                        up(z_seat + bead_lift) linear_sweep(groove_ring,
                            height = bead_w);
                    }
                else
                    offset_sweep(wall_neck, height = lid_overlap);
        }
        union() {
            // 0.01 mm overlap into the neck cavity avoids coplanar cap
            // faces (z-fighting in preview) at the inner step.
            up(box_plate_t) offset_sweep(inner,
                height = z_seat - box_plate_t + 0.01,
                bottom = os_circle(r = cavity_r));
            up(z_seat) offset_sweep(neck_cavity, height = lid_overlap + 1);
        }
    }

// ================= LID MODULE =================
module travel_porage_lid() {
    // Modeled upside down in print orientation: the plate lies on the bed
    // with its base_r fillet as the domed underside (in use that fillet is
    // the rounded top edge, same radius as the container's bottom edge).
    // The skirt is a plain hollow: one cavity sweep cuts the ring out of
    // the top, so the skirt opens upward for printing. The 2D-ring-only
    // construction is impossible here because base_r is larger than
    // lid_plate_t: the fillet dome runs up into the skirt.
    difference() {
        offset_sweep(wall, height = lid_overlap + lid_plate_t,
            bottom = os_circle(r = base_r));
        up(lid_plate_t)
            offset_sweep(offset(raw(wall_t - lid_skirt_t), r = edge_r),
                height = lid_overlap + 0.01);
    }
    if (bead)
        // Snap bead ring on the skirt's inner wall. The skirt's bottom
        // edge is at the top in print orientation, hence the lift is
        // measured from there.
        up(lid_plate_t + lid_overlap - bead_lift - bead_w)
            linear_sweep(bead_ring, height = bead_w);
}

// ================= INSTANTIATION =================
if (show != "lid")
    travel_porage_container();
if (show == "both" && $preview)
    // Seated ghost of the lid (flipped out of print orientation) to show
    // the fit; preview only, so STL exports stay single-part.
    %up(outer_h + lid_plate_t) xrot(180) travel_porage_lid();
if (show != "container")
    // Beside the container in print orientation, offset past its right edge.
    right(box_d + pocket_w / 2 + 2 * wall_t + 10) travel_porage_lid();
