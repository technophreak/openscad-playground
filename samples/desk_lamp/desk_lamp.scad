// Desk lamp — leaning stand + conical shade for a battery LED puck.
//
// Customizer: Window → Customizer, tweak groups below, F5 to preview.
// Objects: show_stand / show_shade. Export: STL or 3MF (one file per object).
//
// Mechanical holder only — no cord, bulb socket, or wiring.
// Outer edges use fillets for a soft, rounded look.

include <../../lib/fdm.scad>;

/* [Objects] */
show_stand = true;  // preview / export the base and neck
show_shade = true;  // preview / export the conical shade

/* [Export] */
export_format = "STL"; // [STL, 3MF]

/* [Stand] */
base_diameter    = 90;   // mm — circular base diameter
base_height      = 10;   // mm — base disc thickness
base_fillet      = 2.4;  // mm — fillet on base top/bottom outer rim
neck_lean        = 18;   // deg — lean from vertical toward the desk
neck_height      = 140;  // mm — neck length along its axis
neck_bottom_d    = 16;   // mm — neck diameter at the base
neck_top_d       = 11;   // mm — neck diameter below the peg
neck_base_fillet = 4.5;  // mm — fillet easing the stem into the base top
stem_fillet      = 12;   // mm — stronger = longer easing where stem narrows and meets the peg
peg_diameter     = 10;   // mm — friction peg diameter
peg_length       = 12;   // mm — peg length into the shade socket
peg_clearance    = 0.10; // mm — socket oversize vs peg diameter (snug friction fit)
peg_notches        = 1;    // raised retainer the shade sits on
peg_notch_height   = 3.0;  // mm — how far the retainer protrudes from the peg
peg_notch_width    = 2.0;  // mm — retainer thickness along the peg (seat)
peg_notch_span     = 5;    // % — each retainer covers this much of the circumference
peg_notch_from_tip = 10;   // mm — seat face distance from peg tip (shade crown rests here)

/* [Shade] */
shade_mouth_d     = 100;  // mm — wide mouth diameter
shade_crown_d     = 48;   // mm — outer diameter at the crown
shade_height      = 55;   // mm — cone height (crown to mouth)
shade_wall        = 1.8;  // mm — shell wall thickness
shade_lip         = 2.4;  // mm — rounded lip radius at the mouth
shade_edge_fillet = 1.2;  // mm — fillet on crown outer rim
puck_diameter     = 35;   // mm — battery LED puck diameter
puck_height       = 10;   // mm — puck seat depth
crown_thickness   = 14;   // mm — crown solid depth (socket + puck seat)

/* [Hidden] */
bool_epsilon = helper_epsilon;
fn_body      = default_fragments;
fn_fillet    = 48;
socket_d     = peg_diameter + 2 * peg_clearance;
socket_depth = peg_length + 0.5;
color_index_stand = 0;
color_index_shade = 1;
neck_fairing_pad = 4;    // mm — extra diameter of the root flare at the base
// Derived from stem_fillet (Customizer); peg join stays shorter than the peg itself.
neck_fairing_h   = stem_fillet * 2.8;
peg_fairing_h    = min(peg_length - 0.5, stem_fillet * 0.9);
stem_root_r      = (neck_bottom_d + neck_fairing_pad) / 2;
// Upright root tall enough that the elbow pipe cannot reach down into the base cove.
root_stump_h     = stem_root_r + neck_base_fillet + 4;

// Attach point kept inboard so root radius + cove stay inside the base rim.
attach_y = -base_diameter / 2 + stem_root_r + neck_base_fillet + base_fillet + 2;
lean_origin_y = attach_y;
lean_origin_z = base_height + root_stump_h;

// Circular-arc bend (toroidal path) built as a sphere chain so joins fillet
// continuously into the upright stump and the slanted taper.
stem_elbow_r  = 125; // mm — bend centerline radius (larger = gentler)
elbow_steps   = 8;   // sphere samples along the arc (smooth filleted bend)
elbow_end_y   = lean_origin_y + stem_elbow_r * (1 - cos(neck_lean));
elbow_end_z   = lean_origin_z + stem_elbow_r * sin(neck_lean);

function stem_blend(a, b, t) = a + (b - a) * t;
// Smootherstep ease — flatter ends, rounder middle (stronger fillet look).
function stem_ease(t) =
    let (u = max(0, min(1, t)))
        u * u * u * (u * (u * 6 - 15) + 10);

// Point on the elbow centerline at angle phi (0 = upright start, neck_lean = end).
function elbow_pos(phi) = [
    lean_origin_y + stem_elbow_r * (1 - cos(phi)),
    lean_origin_z + stem_elbow_r * sin(phi)
];

// Radius along straight-stem distance s (mm from elbow end).
function stem_radius_at(s) =
    let (
        r_mid  = neck_bottom_d / 2,
        r_top  = neck_top_d / 2,
        r_peg  = peg_diameter / 2,
        s_peg0 = neck_height,
        s_peg1 = neck_height + peg_fairing_h
    )
        s <= 0 ? stem_root_r :
        // Root → mid: long eased narrowing after the elbow
        s < neck_fairing_h ?
            stem_blend(stem_root_r, r_mid, stem_ease(s / neck_fairing_h)) :
        // Mid → top: long eased taper along the rod
        s < neck_height ?
            stem_blend(r_mid, r_top,
                stem_ease((s - neck_fairing_h) / max(0.001, neck_height - neck_fairing_h))) :
        // Top rod → peg: eased shoulder into the friction peg
        s < s_peg1 ?
            stem_blend(r_top, r_peg, stem_ease((s - s_peg0) / peg_fairing_h)) :
        r_peg;

function stem_pos_at(s) = [
    elbow_end_y + s * sin(neck_lean),
    elbow_end_z + s * cos(neck_lean)
];

peg_tip_along = neck_height + peg_length;
peg_tip_yz = stem_pos_at(peg_tip_along);
peg_tip_y = peg_tip_yz[0];
peg_tip_z = peg_tip_yz[1];

// Dense samples at the two strong fillets: root narrowing + peg shoulder.
stem_s_samples = [
    0,
    neck_fairing_h * 0.20,
    neck_fairing_h * 0.40,
    neck_fairing_h * 0.60,
    neck_fairing_h * 0.80,
    neck_fairing_h,
    neck_height * 0.25,
    neck_height * 0.45,
    neck_height * 0.65,
    neck_height * 0.82,
    neck_height * 0.93,
    neck_height,
    neck_height + peg_fairing_h * 0.25,
    neck_height + peg_fairing_h * 0.50,
    neck_height + peg_fairing_h * 0.75,
    neck_height + peg_fairing_h
];

// Arc bend as hulled spheres — filleted into stump below and stem above.
module stem_elbow() {
    // Ease out of the upright stump (stay above the base cove)
    hull() {
        translate([0, lean_origin_y, lean_origin_z - 3])
            sphere(r = stem_root_r, $fn = fn_fillet);
        translate([0, lean_origin_y, lean_origin_z])
            sphere(r = stem_root_r, $fn = fn_fillet);
        p0 = elbow_pos(neck_lean / elbow_steps);
        translate([0, p0[0], p0[1]])
            sphere(r = stem_root_r, $fn = fn_fillet);
    }
    // Toroidal path
    for (i = [0 : elbow_steps - 1]) {
        p0 = elbow_pos(neck_lean * i / elbow_steps);
        p1 = elbow_pos(neck_lean * (i + 1) / elbow_steps);
        hull() {
            translate([0, p0[0], p0[1]])
                sphere(r = stem_root_r, $fn = fn_fillet);
            translate([0, p1[0], p1[1]])
                sphere(r = stem_root_r, $fn = fn_fillet);
        }
    }
    // Ease into the slanted taper (extra stations so the narrowing fillets)
    for (i = [0 : 3]) {
        s0 = neck_fairing_h * i / 4;
        s1 = neck_fairing_h * (i + 1) / 4;
        // First station sits on the elbow end
        p0 = i == 0 ? elbow_pos(neck_lean) : stem_pos_at(s0);
        p1 = stem_pos_at(s1);
        r0 = i == 0 ? stem_root_r : stem_radius_at(s0);
        hull() {
            translate([0, p0[0], p0[1]])
                sphere(r = r0, $fn = fn_fillet);
            translate([0, p1[0], p1[1]])
                sphere(r = stem_radius_at(s1), $fn = fn_fillet);
        }
    }
}

// Straight tapered stem after the elbow (sphere chain along the lean).
module smooth_stem() {
    n = len(stem_s_samples);
    union() {
        for (i = [0 : n - 2]) {
            s0 = stem_s_samples[i];
            s1 = stem_s_samples[i + 1];
            p0 = stem_pos_at(s0);
            p1 = stem_pos_at(s1);
            hull() {
                translate([0, p0[0], p0[1]])
                    sphere(r = stem_radius_at(s0), $fn = fn_fillet);
                translate([0, p1[0], p1[1]])
                    sphere(r = stem_radius_at(s1), $fn = fn_fillet);
            }
        }
    }
}

// Disc with filleted top and bottom outer rim (lathed).
// 2D profile must stay at X >= 0 for rotate_extrude.
module filleted_disc(d, h, fillet) {
    r = d / 2;
    f = min(fillet, h / 2 - 0.05, r - 0.05);
    rotate_extrude($fn = fn_body)
        hull() {
            translate([f, f])
                circle(r = f, $fn = fn_fillet);
            translate([f, h - f])
                circle(r = f, $fn = fn_fillet);
            translate([r - f, f])
                circle(r = f, $fn = fn_fillet);
            translate([r - f, h - f])
                circle(r = f, $fn = fn_fillet);
        }
}

// Upright stump + concave cove into the base top (lathed at attach_y).
module root_stump_profile() {
    sr = stem_root_r;
    rf = neck_base_fillet;
    stump_top = base_height + root_stump_h;

    union() {
        square([sr, stump_top]);
        translate([sr, base_height])
            difference() {
                square([rf, rf]);
                translate([rf, rf])
                    circle(r = rf, $fn = fn_fillet);
            }
    }
}

// Straight peg with flat tip.
module peg_shaft() {
    h_shaft = peg_length - peg_fairing_h;
    if (h_shaft > 0.2) {
        p = stem_pos_at(neck_height + peg_fairing_h);
        translate([0, p[0], p[1]])
            rotate([-neck_lean, 0, 0]) {
                cylinder(d = peg_diameter, h = h_shaft, $fn = fn_body);
                // Small tip chamfer
                translate([0, 0, max(0, h_shaft - 0.7)])
                    cylinder(
                        d1 = peg_diameter,
                        d2 = peg_diameter - 1.0,
                        h = 0.7,
                        $fn = fn_body
                    );
            }
    }
}

// Raised square seat the shade sits on — placed peg_notch_from_tip below the tip.
// Short arc only (peg_notch_span % of circumference), not a full rim.
module peg_seat_notch() {
    notch_deg = 360 * peg_notch_span / 100;
    if (peg_notches > 0 && notch_deg > 0) {
        for (i = [0 : peg_notches - 1]) {
            // Tip-facing face of the seat at this path distance from the tip
            s = neck_height + peg_length - peg_notch_from_tip - i * (peg_notch_width + 1.0);
            p = stem_pos_at(s);
            r_local = stem_radius_at(max(0, s));
            translate([0, p[0], p[1]])
                rotate([-neck_lean, 0, 0])
                    rotate([0, 0, i * (360 / max(1, peg_notches))])
                        // Seat slab below the face so the shade rests on z=0 local
                        translate([0, 0, -peg_notch_width])
                            rotate_extrude(angle = notch_deg, $fn = max(8, fn_body / 4))
                                translate([r_local, 0])
                                    square([peg_notch_height, peg_notch_width]);
        }
    }
}

module lamp_stand() {
    // Soft-edged base centered on the origin
    filleted_disc(base_diameter, base_height, base_fillet);

    // Upright root with cove (lean begins above this)
    translate([0, attach_y, 0])
        rotate_extrude($fn = fn_body)
            root_stump_profile();

    // Arc bend (sphere-chain) filleted into stump and slanted stem
    stem_elbow();
    smooth_stem();
    peg_shaft();
    peg_seat_notch();
}

module lamp_shade() {
    // Print pose: crown at z=0, mouth at z=shade_height (mouth up).
    lip_r   = shade_lip;
    crown_f = min(shade_edge_fillet, crown_thickness / 3, shade_crown_d / 6);
    mouth_r = shade_mouth_d / 2;
    crown_r = shade_crown_d / 2;

    difference() {
        union() {
            // Outer cone
            cylinder(
                d1 = shade_crown_d,
                d2 = shade_mouth_d,
                h = shade_height,
                $fn = fn_body
            );

            // Rounded crown outer rim (torus resting on the bed)
            if (crown_f > 0) {
                rotate_extrude($fn = fn_body)
                    translate([crown_r - crown_f, crown_f])
                        circle(r = crown_f, $fn = fn_fillet);
            }

            // Rounded mouth lip (torus)
            translate([0, 0, shade_height - lip_r])
                rotate_extrude($fn = fn_body)
                    translate([mouth_r, 0])
                        circle(r = lip_r, $fn = fn_fillet);
        }

        // Inner cone cavity
        translate([0, 0, crown_thickness])
            cylinder(
                d1 = shade_crown_d - 2 * shade_wall,
                d2 = shade_mouth_d - 2 * shade_wall,
                h = shade_height - crown_thickness + lip_r + bool_epsilon,
                $fn = fn_body
            );

        // Soften the cavity mouth (inner fillet via conical lead-in)
        translate([0, 0, shade_height - lip_r])
            cylinder(
                d1 = shade_mouth_d - 2 * shade_wall,
                d2 = shade_mouth_d - 2 * shade_wall + 2 * lip_r,
                h = lip_r + bool_epsilon,
                $fn = fn_body
            );

        // Blind peg socket from the crown outside (snug friction fit)
        translate([0, 0, -bool_epsilon])
            cylinder(d = socket_d, h = socket_depth + bool_epsilon, $fn = fn_body);

        // Light entrance lead-in for assembly
        translate([0, 0, -bool_epsilon])
            cylinder(
                d1 = socket_d + 0.8,
                d2 = socket_d,
                h = 1.2,
                $fn = fn_body
            );

        // Puck seat from inside the crown
        translate([0, 0, crown_thickness - puck_height])
            cylinder(d = puck_diameter + 0.4, h = puck_height + bool_epsilon, $fn = fn_body);

        // Clear anything below the bed plane from the crown torus
        translate([0, 0, -20])
            cube([shade_mouth_d + 40, shade_mouth_d + 40, 40], center = true);
    }
}

if (show_stand)
    preview_object(color_index_stand)
        lamp_stand();

if (show_shade) {
    if (show_stand)
        preview_object(color_index_shade)
            translate([0, peg_tip_y, peg_tip_z])
                rotate([180, 0, 0])
                    lamp_shade();
    else
        preview_object(color_index_shade)
            lamp_shade();
}

assert(show_stand || show_shade, "enable show_stand and/or show_shade");
