// Pen sample — Montblanc-inspired cigar pen (three Blueprint objects).
//
// Customizer: show_barrel / show_cap / show_cartridge each hide only that object.
// Export: one mesh file per object (STL or 3MF).
//
// Mechanical demo only — no ink, spring, or click mechanism.
//
// Coordinates (each object in print pose):
//   barrel     tip at z=0, mouth at z=barrel_length
//   cap        dome on the bed at z=0, open mouth at z=cap_total_h (mouth up)
//   cartridge  tip at z=0, body upward
// Assembly flips the cap 180° onto the barrel mouth; cartridge shoulder seats
// at the bore ledge (z=tip_nose_h) so the tip protrudes below the nose.

include <../../lib/fdm.scad>;

/* [Objects] */
show_barrel     = true;
show_cap        = true;
show_cartridge  = true;

/* [Export] */
export_format = "STL"; // [STL, 3MF]

/* [Barrel] */
barrel_length     = 125;
barrel_max_d      = 13.6;  // mm — cigar belly (near cap OD for a continuous look)
barrel_mouth_d    = 11.2;  // mm — mouth OD under the cap
barrel_grip_d     = 11.5;
barrel_inner_d    = 8.2;
tip_hole_d        = 2.8;
tip_nose_h        = 13.5; // mm — longer nose → tip sticks out a bit less
grip_band_h       = 2.6;
grip_band_raise   = 0.22;

/* [Cap] */
cap_clearance     = 0.18;
cap_wall          = 1.15;
cap_length        = 58;
cap_crown_h       = 7.0;   // mm — elliptical dome height
cap_overlap       = 22;
crown_disc_d      = 4.4;
crown_disc_h      = 0.5;
ring_h            = 1.7;
ring_raise        = 0.28;
ring_gap          = 1.1;
clip_width        = 3.2;
clip_thick        = 1.5;  // mm — leaf thickness
clip_length       = 40;
clip_gap          = 0.6;  // mm — air gap between skirt OD and leaf inner face
clip_angle        = 1.5;  // deg — tip the leaf slightly toward the skirt
clip_ball_d       = 2.5;

/* [Cartridge] */
cartridge_body_d   = 7.4;
cartridge_body_h   = 102;
cartridge_tip_d    = 2.4;
cartridge_tip_h    = 16;
cartridge_shoulder = 1.5;
cartridge_nose_h   = 6.5;
ink_window_d       = 0;

/* [Hidden] */
bool_epsilon = helper_epsilon;
fn_body      = 160;
fn_band      = 96;
cap_inner_d  = barrel_mouth_d + 2 * cap_clearance;
cap_outer_d  = cap_inner_d + 2 * cap_wall;  // ~13.86 — matches barrel belly
cap_total_h  = cap_length;
color_index_barrel     = 0;
color_index_cap        = 1;
color_index_cartridge  = 2;

cartridge_assemble_z = tip_nose_h - cartridge_tip_h;
cap_assemble_z = barrel_length - cap_overlap + cap_total_h;

assert(cartridge_tip_h > tip_nose_h, "cartridge tip must be longer than tip_nose_h to protrude");
assert(cap_overlap < cap_length - cap_crown_h - 2, "cap_overlap must leave the crown clear");
assert(clip_length < cap_length - cap_crown_h - 8, "clip must end above the open mouth");

function smootherstep(x) =
    let (u = min(1, max(0, x)))
    u * u * u * (u * (u * 6 - 15) + 10);

function barrel_r_at(z) =
    let (
        t = z / barrel_length,
        // Rounded nose: elliptical dome from a small tip into the grip
        nose_h  = tip_nose_h * 1.35,
        r_tip0  = tip_hole_d / 2 + 0.35,  // small tip radius (not a flat stump)
        r_grip  = barrel_grip_d / 2,
        r_max   = barrel_max_d / 2,
        r_mouth = barrel_mouth_d / 2,
        // Quarter-ellipse over the nose: r_tip0 at z=0 → r_grip at z=nose_h
        r_nose  = (z >= nose_h) ? r_grip :
                  r_tip0 + (r_grip - r_tip0) * sqrt(max(0, 1 - pow((nose_h - z) / nose_h, 2))),
        t_nose  = nose_h / barrel_length
    )
        z < nose_h ? r_nose :
        t < 0.48 ? r_grip + (r_max - r_grip) * smootherstep((t - t_nose) / max(0.001, 0.48 - t_nose)) :
                   r_max + (r_mouth - r_max) * smootherstep((t - 0.48) / 0.52);

module lathe_cap_skirt() {
    // Straight skirt only (dome is a separate hemisphere)
    h = cap_length - cap_crown_h;
    translate([0, 0, cap_crown_h])
        cylinder(d = cap_outer_d, h = h, $fn = fn_body);
}

// Domed crown: tip at z=0 (bed), equator at z=cap_crown_h.
// Lower hemisphere — tip points toward -Z when assembled after the 180° flip is outward/+Z.
module cap_dome() {
    dome_r = cap_outer_d / 2;
    translate([0, 0, cap_crown_h])
        scale([1, 1, cap_crown_h / dome_r])
            intersection() {
                sphere(r = dome_r, $fn = fn_body);
                translate([0, 0, -dome_r])
                    cube([dome_r * 2 + 2, dome_r * 2 + 2, dome_r * 2], center = true);
            }
}

module lathe_barrel() {
    steps = 120;
    pts = [for (i = [0:steps]) let (z = i * barrel_length / steps) [barrel_r_at(z), z]];
    rotate_extrude($fn = fn_body)
        polygon(concat([[0, 0]], pts, [[0, barrel_length]]));
}

// Soft circular bead (torus profile) — blends into the body with no hard edges.
module smooth_band(body_r, h, raise) {
    r_minor = h / 2;
    r_center = body_r + raise - r_minor;
    rotate_extrude($fn = fn_body)
        translate([max(r_center, body_r * 0.5), 0])
            circle(r = r_minor, $fn = fn_band);
}

module pen_barrel() {
    difference() {
        union() {
            lathe_barrel();

            band_z = tip_nose_h + 9;
            translate([0, 0, band_z + grip_band_h / 2])
                smooth_band(barrel_r_at(band_z), grip_band_h, grip_band_raise + 0.15);
        }

        translate([0, 0, tip_nose_h - bool_epsilon])
            cylinder(d = barrel_inner_d, h = barrel_length - tip_nose_h + 2 * bool_epsilon, $fn = fn_body);

        translate([0, 0, -bool_epsilon])
            cylinder(d = tip_hole_d, h = tip_nose_h + 2 * bool_epsilon, $fn = fn_body);

        translate([0, 0, barrel_length - 1.0])
            cylinder(d1 = barrel_inner_d, d2 = barrel_inner_d + 1.4, h = 1.0 + bool_epsilon, $fn = fn_body);
    }
}

module clip_flat(w, t) {
    // Thin capsule: inner face at x=0, outer face at x=t (constant thickness)
    hull() {
        for (sy = [-1, 1])
            translate([t / 2, sy * (w - t) / 2, 0])
                sphere(d = t, $fn = 48);
    }
}

module pen_cap_clip() {
    // Origin on OD at the crown band centerline.
    // clip_gap = air between skirt and leaf inner face (does not change leaf thickness).
    g = clip_gap;
    t = clip_thick;
    L = clip_length;
    z_ball = L - clip_ball_d * 0.4;

    // Root: keyed into the wall, then out to the leaf stand-off
    hull() {
        translate([-0.25, 0, -1.4])
            clip_flat(clip_width * 1.08, t * 1.1);
        translate([g, 0, 0.4])
            clip_flat(clip_width, t);
    }

    // Leaf at constant thickness; only the tip returns toward the skirt
    hull() {
        translate([g, 0, 0.4])
            clip_flat(clip_width, t);
        translate([g, 0, L * 0.55])
            clip_flat(clip_width * 0.9, t);
        translate([g * 0.35, 0, L * 0.82])
            clip_flat(clip_width * 0.72, t);
        translate([0.35, 0, z_ball])
            sphere(d = clip_ball_d, $fn = 64);
    }
}

module pen_cap() {
    // Print pose: dome tip at z=0, mouth at z=cap_length.
    crown_band_z = cap_crown_h - 0.3;  // band sits in the lower dome / skirt join
    crown_band_h = 4;
    ring1_z = cap_length - 5.0 - 2 * ring_h - ring_gap;
    ring2_z = ring1_z + ring_h + ring_gap;

    difference() {
        union() {
            cap_dome();
            lathe_cap_skirt();

            // Snowcap sunk into the crown (~1 mm) so it sits in the tip, not floating
            translate([0, 0, 1.0])
                intersection() {
                    sphere(d = crown_disc_d, $fn = fn_body);
                    translate([0, 0, -crown_disc_d / 2])
                        cube([crown_disc_d + 2, crown_disc_d + 2, crown_disc_d], center = true);
                }

            // Crown band — clip mounts here
            translate([0, 0, crown_band_z])
                smooth_band(cap_outer_d / 2, crown_band_h, ring_raise + 0.2);

            for (z = [ring1_z + ring_h / 2, ring2_z + ring_h / 2])
                translate([0, 0, z])
                    smooth_band(cap_outer_d / 2, ring_h, ring_raise + 0.12);

            translate([cap_outer_d / 2, 0, crown_band_z + 0.7])
                rotate([0, clip_angle, 0])
                    pen_cap_clip();
        }

        bore_z0 = cap_crown_h + 1.0;
        translate([0, 0, bore_z0])
            cylinder(d = cap_inner_d, h = cap_length - bore_z0 + bool_epsilon, $fn = fn_body);

        translate([0, 0, cap_length - 1.2])
            cylinder(d1 = cap_inner_d, d2 = cap_inner_d + 1.2, h = 1.2 + bool_epsilon, $fn = fn_body);
    }
}

function cartridge_r_at(z) =
    let (
        tip_r  = cartridge_tip_d / 2,
        body_r = cartridge_body_d / 2,
        sh_r   = body_r + 0.12,
        z_pipe = cartridge_tip_h - cartridge_nose_h,
        z_nose = cartridge_tip_h,
        z_sh   = cartridge_tip_h + cartridge_shoulder,
        z_end  = z_sh + cartridge_body_h
    )
        z <= z_pipe ? tip_r :
        z <= z_nose ? tip_r + (body_r - tip_r) *
            smootherstep((z - z_pipe) / max(0.001, cartridge_nose_h)) :
        z <= z_sh   ? body_r + (sh_r - body_r) *
            sin(90 * (z - z_nose) / max(0.001, cartridge_shoulder)) :
        z <= z_end - 5 ? body_r :
        z <= z_end ? body_r * (1 - 0.08 * smootherstep((z - (z_end - 5)) / 5)) :
                     0;

module pen_cartridge() {
    // Same overall length / diameters; smooth lathe + ballpoint tip.
    total_h = cartridge_tip_h + cartridge_shoulder + cartridge_body_h;
    steps = 80;
    pts = [for (i = [0:steps]) let (z = i * total_h / steps) [cartridge_r_at(z), z]];

    difference() {
        union() {
            rotate_extrude($fn = fn_body)
                polygon(concat([[0, 0]], pts, [[0, total_h]]));

            // Ballpoint: equator flush with the tip face (z=0), hemisphere outward
            intersection() {
                sphere(d = cartridge_tip_d, $fn = 64);
                translate([0, 0, -cartridge_tip_d / 2])
                    cube([cartridge_tip_d + 2, cartridge_tip_d + 2, cartridge_tip_d], center = true);
            }
        }

        if (ink_window_d > 0) {
            translate([0, 0, cartridge_tip_h + cartridge_shoulder + 2])
                cylinder(d = ink_window_d, h = cartridge_body_h - 6, $fn = 32);
        }
    }
}

if (show_barrel)
    preview_object(color_index_barrel)
        pen_barrel();

if (show_cartridge) {
    if (show_barrel)
        preview_object(color_index_cartridge)
            translate([0, 0, cartridge_assemble_z])
                pen_cartridge();
    else
        preview_object(color_index_cartridge)
            pen_cartridge();
}

if (show_cap) {
    if (show_barrel)
        preview_object(color_index_cap)
            translate([0, 0, cap_assemble_z])
                rotate([180, 0, 0])
                    pen_cap();
    else
        preview_object(color_index_cap)
            pen_cap();
}

assert(show_barrel || show_cap || show_cartridge, "enable at least one object");
