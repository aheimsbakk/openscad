// S-shaped cable organizer, extruded 10 mm.
// Purpose: spring clip that holds two cables. The top hook is loaded from
// the right, the bottom hook from the left. Cables slide in sideways past
// the round-capped tips; the hook mouths hold them.
// Notes: The S centerline is one tangent- and curvature-matched chain:
// hook arc, quarter-ellipse transition, flat middle, mirrored transition,
// hook arc. The transition span is derived so its curvature equals the
// hook arc curvature at the junction (G2 continuity), which removes the
// visible bend-rate crease on the strip boundary.
// The hook tip angle (degrees) is the master mouth control.
// Builtin OpenSCAD only, no library needed.

// ================= PARAMETERS =================
// Overall size and extrusion
width_x     = 15.0;   // x extent of the bounding box (mm)
height_y    = 30.0;   // y extent of the bounding box (mm)
depth_z     = 10.0;   // extrusion depth (mm)

// Strip
strip_width = 2.0;    // constant thickness of the S strip (mm)

// Hook tip angle in degrees, measured down from the hook's wide side.
// This is the master control for both mouth gaps; larger angle =
// smaller gaps. 10 deg gives about a 4.4 mm gap at the current size.
// Keep within roughly -40 (very wide open) to +20 (nearly closed).
tip_deg     = 10;

// Derived centerline geometry
strip_r = strip_width / 2;
cx      = width_x / 2;                        // hook arc center x
hook_r  = (width_x - strip_width) / 2;        // = 6.5, hook arc radius
cy_top  = height_y - strip_r - hook_r;        // = 22.5, top hook center y
cy_bot  = strip_r + hook_r;                   // = 7.5, bottom hook center y
mid_y   = height_y / 2;                       // = 15.0, middle centerline y

// Flat middle length in mm. The transitions stay curvature-matched for
// every value in range: their horizontal span takes the width remainder,
// their height shrinks to keep the bend rate equal to the hook arc, and
// any leftover height becomes a short vertical straight on each hook
// side. Valid range is echoed as a warning if exceeded (clamped).
// At the current size the matched floor is below 0 (see min_mid), so
// every value renders smooth; larger = straighter middle, smaller
// transitions.
mid_flat    = 2.5;

// Derived transition geometry
side_room = cy_top - mid_y;                                  // = 7.5, height available per transition
min_mid   = width_x - 2 * strip_r - 2 * side_room * side_room / hook_r; // = -4.3 here: no floor at this size
max_mid   = width_x - 2 * strip_r;                           // = 13, transitions fully vanished
mid_eff   = min(max(mid_flat, min_mid), max_mid);
ease_dx   = (width_x - 2 * strip_r - mid_eff) / 2;           // horizontal span of each transition
ease_dy   = sqrt(ease_dx * hook_r);                          // transition height, keeps bend rate = 1 / hook_r
straight_v = side_room - ease_dy;                            // leftover: short vertical straight per side
mid_x_l   = strip_r + ease_dx;                               // left end of the flat middle
mid_x_r   = width_x - strip_r - ease_dx;                     // right end of the flat middle

if (mid_flat != mid_eff)
    echo(str("WARNING: mid_flat ", mid_flat, " is outside the valid range [",
             min_mid, ", ", max_mid, "]; using ", mid_eff, " instead."));

// Informational: resulting mouth gap in mm, identical on both sides.
mouth_mm = (cy_top - mid_y - 2 * strip_r) - hook_r * sin(tip_deg);

echo(str("Mouth gap: ", mouth_mm, " mm on both sides"));

// ================= HELPER =================
// Sample a circular arc including both endpoints, about 6 deg resolution.
function arc(c, r, a0, a1) =
    let(n = max(1, ceil(abs(a1 - a0) / 6)))
    [for (i = [0 : n])
        [c.x + r * cos(a0 + (a1 - a0) * i / n),
         c.y + r * sin(a0 + (a1 - a0) * i / n)]];

// Quarter-ellipse transition: vertical tangent at the start, horizontal
// tangent at the end (pure sin/cos sampling).
function ease_vh(p0, dx, dy, n = 24) =
    [for (i = [0 : n])
        [p0.x + dx * (1 - cos(90 * i / n)),
         p0.y + dy * sin(90 * i / n)]];

// Mirrored variant: horizontal tangent at the start, vertical tangent
// at the end (sin/cos roles swapped).
function ease_hv(p0, dx, dy, n = 24) =
    [for (i = [0 : n])
        [p0.x + dx * sin(90 * i / n),
         p0.y + dy * (1 - cos(90 * i / n))]];

// ================= MAIN MODULE =================
module s_cable_organizer() {
    // Optional short vertical straights between hook side and transition;
    // present whenever mid_flat is above its minimum (leftover height).
    vert_l = straight_v > 0.001 ? [[strip_r, cy_top - straight_v]] : [];
    vert_r = straight_v > 0.001 ? [[width_x - strip_r, cy_bot]] : [];

    // Sampled centerline of the S, top tip to bottom tip. Every piece
    // starts where the previous one ends and has a matching tangent;
    // the hook-to-transition junctions also match in curvature.
    path = concat(
        // top hook arc, tip -> over the apex -> to the left side
        arc([cx, cy_top], hook_r, -tip_deg, 180),
        vert_l,
        // quarter-ellipse transition, vertical -> horizontal
        ease_vh([strip_r, cy_top - straight_v], ease_dx, -ease_dy),
        // flat middle (mid_flat long)
        [[mid_x_r, mid_y]],
        // mirrored transition, horizontal -> vertical
        ease_hv([mid_x_r, mid_y], ease_dx, -ease_dy),
        vert_r,
        // bottom hook arc, right side -> under the apex -> tip.
        // End angle -(180 + tip_deg) mirrors the top tip exactly, so
        // both mouth gaps are identical for any tip angle.
        arc([cx, cy_bot], hook_r, 0, -(180 + tip_deg))
    );

    linear_extrude(height = depth_z)
        stroke2d(path, strip_r);
}

// Stroke a polyline as a constant-width strip with round end caps:
// hull chains of circles between consecutive path points.
module stroke2d(pts, r) {
    for (i = [0 : len(pts) - 2])
        hull() {
            translate(pts[i])     circle(r);
            translate(pts[i + 1]) circle(r);
        }
}

// ================= INSTANTIATION =================
s_cable_organizer();
