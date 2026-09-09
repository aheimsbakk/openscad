// Passive phone-amplifier horn. A phone slides lengthwise into the rear
// slot; its long bottom-edge loudspeaker fires axially into an exponential
// flared waveguide that lofts from the rectangular throat to an octagonal
// mouth. The flare rate derives from Webster's horn equation for an
// exponential horn (m = 4*pi*fc/c); width and height growth rates split m
// so the cross-section morphs toward the mouth aspect ratio while the
// acoustic area law is preserved. The bottom stays flat over the whole
// length so the horn rests on a table and the inserted phone lies flat.
// Prints in one piece, bottom down, no supports needed.

include <../../lib/BOSL2/std.scad>

// ================= PARAMETERS =================
/* [Phone slot] */
// Phone width across the slot opening
phone_w = 85; // [50:0.5:120]
// Phone thickness (slot inner height)
phone_t = 15; // [8:0.5:25]
// Clearance added around the phone inside the slot
slot_clr = 0.4; // [0.2:0.05:1.0]

/* [Horn acoustics] */
// Design cutoff frequency in Hz; lower = slower flare and smaller mouth
fc = 500; // [300:25:800]
// Horn flare length in mm; mouth size grows with length
horn_len = 200; // [100:10:300]
// Speed of sound in m/s (dry air, 20 C)
sound_speed = 343;
// Mouth width-to-height aspect ratio
ar_mouth = 2.2; // [1.5:0.1:3.0]

/* [Construction] */
// Wall thickness
wall = 1.2; // [0.8:0.1:3]
// Straight throat channel length in front of the slot opening
channel_len = 25; // [15:1:60]
// Loft sections along the flare (outline smoothness)
flare_steps = 32; // [8:4:64]
// Octagon corner cut as a fraction of half the mouth height
octagon_frac = 0.45; // [0.2:0.05:0.49]
// Show a translucent phone ghost in previews
show_phone = true;

module __Customizer_Limit__ () {}

// ---- derived values ----
// Flare constant of Webster's exponential-horn equation, in 1/mm.
flare_m = 4 * PI * fc / (sound_speed * 1000);
// Throat area is the phone face itself: the phone seals the slot.
throat_area = phone_w * phone_t;
ar_throat = phone_w / phone_t;
// Slot opening: clearance on both sides and on top; the phone floor
// rests directly on the inner floor.
slot_w = phone_w + 2 * slot_clr;
slot_h = phone_t + slot_clr;
// Minimum corner cut that keeps 8 distinct loft vertices at the throat,
// where the chamfer has not started yet.
cmin = 0.01;
// Uniform wall offset of a 45 deg corner cut grows by wall*(2-sqrt(2)).
chamfer_wall = wall * (2 - sqrt(2));
// Cutoff wavelength used for the mouth reflection check.
mouth_lambda = sound_speed * 1000 / fc;

// Exponential flare dimensions at distance u into the flare.
// Acoustic area: S(u) = S0 * exp(m*u). Width and height rates a and b
// satisfy a + b = m (area law) and a - b = ln(AR_mouth/AR_throat)/L,
// so the section aspect ratio moves logarithmically toward ar_mouth.
// Corner cut ramps linearly from ~0 at the throat to the mouth value.
function flare_dims(u) =
    let(
        area = throat_area * exp(flare_m * u),
        ar = ar_throat * pow(ar_mouth / ar_throat, u / horn_len),
        w = sqrt(area * ar),
        h = sqrt(area / ar),
        c = max(cmin, octagon_frac * h / 2 * u / horn_len)
    ) [w, h, c];

// Octagon section as 3D points: flat floor at zbot, symmetric in Y,
// 45 deg corner cuts, placed at axis position xpos (X = horn axis,
// Y = width, Z = height). Feeding 3D profiles to skin() avoids any
// post-rotation of the finished solid.
function octagon_pts(w, h, c, zbot, xpos) =
    [ for (p = [
        [-w / 2 + c, zbot], [w / 2 - c, zbot],
        [w / 2, zbot + c], [w / 2, zbot + h - c],
        [w / 2 - c, zbot + h], [-w / 2 + c, zbot + h],
        [-w / 2, zbot + h - c], [-w / 2, zbot + c]
    ]) [xpos, p[0], p[1]] ];

function outer_flare(x, u) =
    let(d = flare_dims(u))
    octagon_pts(d[0] + 2 * wall, d[1] + 2 * wall, d[2] + chamfer_wall, 0, x);

function inner_flare(x, u) =
    let(d = flare_dims(u))
    octagon_pts(d[0], d[1], d[2], wall, x);

function outer_channel(x) =
    octagon_pts(slot_w + 2 * wall, slot_h + 2 * wall, cmin + chamfer_wall, 0, x);

function inner_channel(x) =
    octagon_pts(slot_w, slot_h, cmin, wall, x);

module phone_horn() {
    assert(octagon_frac < 0.5, "octagon_frac must stay below 0.5 or the octagon degenerates.");

    flare_us = [for (i = [0:flare_steps]) i * horn_len / flare_steps];
    flare_xs = [for (u = flare_us) channel_len + u];
    mouth = flare_dims(horn_len);

    outer_profiles = concat(
        [outer_channel(0), outer_channel(channel_len)],
        [for (i = [1:flare_steps]) outer_flare(flare_xs[i], flare_us[i])]
    );
    // Cavity extends past both open ends so the skin caps fall outside
    // the shell. The step from the slot rect to the first flare section
    // forms a 0.4 mm lip around the perimeter that the phone face butts
    // against, fixing the insertion depth at the flare start.
    cavity_profiles = concat(
        [inner_channel(-(wall + 1)), inner_channel(channel_len)],
        [for (i = [1:flare_steps]) inner_flare(flare_xs[i], flare_us[i])],
        [inner_flare(channel_len + horn_len + wall + 1, horn_len + wall + 1)]
    );

    difference() {
        skin(outer_profiles, slices = 0, method = "direct");
        skin(cavity_profiles, slices = 0, method = "direct");
    }

    // Translucent phone ghost to visualize the insertion, preview only.
    if ($preview && show_phone) {
        %translate([channel_len - 60, -phone_w / 2, wall])
            cube([62, phone_w, phone_t]);
    }
}

// Mouth perimeter must reach the cutoff wavelength, otherwise the mouth
// itself reflects energy back into the horn. Echo the check; no hard
// assert, since a shortened horn may be a deliberate trade-off.
mouth_dims = flare_dims(horn_len);
mouth_perim = 2 * (mouth_dims[0] + mouth_dims[1]) - (8 - 4 * sqrt(2)) * mouth_dims[2];
echo(str("Mouth inner: ", mouth_dims[0], " x ", mouth_dims[1], " mm"));
echo(str("Mouth perimeter: ", mouth_perim, " mm | cutoff wavelength: ", mouth_lambda, " mm"));
if (mouth_perim < mouth_lambda) {
    echo("WARNING: mouth perimeter is below the cutoff wavelength; increase horn_len or lower fc.");
}

phone_horn();
