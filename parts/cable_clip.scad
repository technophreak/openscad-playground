// Desk cable clip — mounts with a single screw, clips cables of set diameter.
// Customizer: Window → Customizer, tweak groups below, F5 to preview.

include <../lib/fdm.scad>;

/* [Cable] */
cable_d         = 6.0;  // mm — cable outer diameter
cable_clearance = 0.4;  // mm — extra gap so cable snaps in easily

/* [Body] */
wall       = 2.4;   // mm — ~3× nozzle; keep ≥ 2× nozzle
width      = 12.0;  // mm — clip width along cable
base_extra = 8.0;   // mm — material beyond clip for screw mount
fillet     = 1.2;   // mm — outer corner radius

/* [Clamp] */
throat_ratio        = 0.72;  // fraction of opening width at the snap mouth
channel_flat_lift   = 0.15;  // fraction of opening — flat cut above center
channel_flat_height = 0.50;  // fraction of opening — flat cut height
throat_x_inset_frac = 0.10;  // fraction of wall — throat inset from +X face

/* [Mount] */
screw_d    = 3.4;  // mm — clearance for M3 (loose)
screw_cs_d = 6.2;  // mm — countersink outer diameter
screw_cs_h = 1.8;  // mm — countersink depth

/* [Print] */
nozzle       = 0.4;  // mm — informational; prefer wall = n × nozzle
fragments    = 64;   // [24:8:128] circle resolution ($fn)
bool_epsilon = 0.2;  // mm — through-cut overshoot

/* [Hidden] */
opening = cable_d + cable_clearance;
body_h  = opening + 2 * wall;
body_l  = opening + wall + base_extra;
throat  = opening * throat_ratio;
$fn     = fragments;

module cable_clip() {
    difference() {
        translate([0, 0, body_h / 2])
            rounded_box([body_l, width, body_h], fillet, center = true);

        translate([wall / 2, 0, wall + opening / 2])
            rotate([90, 0, 0])
                cylinder(d = opening, h = width + bool_epsilon, center = true);

        translate([body_l / 2 - wall * throat_x_inset_frac, 0, wall + opening / 2])
            cube([wall * 2 + bool_epsilon, throat, opening], center = true);

        translate([wall / 2, 0, wall + opening / 2 + opening * channel_flat_lift])
            cube(
                [opening, width + bool_epsilon, opening * channel_flat_height],
                center = true
            );

        translate([-body_l / 2 + base_extra / 2, 0, 0])
            countersunk_hole(
                screw_d,
                body_h + bool_epsilon,
                screw_cs_d,
                screw_cs_h,
                fragments = fragments
            );
    }
}

cable_clip();
