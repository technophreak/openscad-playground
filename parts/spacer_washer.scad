// Parametric spacer / washer for M2–M6 hardware.
// Customizer: Window → Customizer, tweak groups below, F5 to preview.

include <../lib/fdm.scad>;

/* [Geometry] */
inner_d  = 3.4;  // mm — clearance for M3 screw (loose fit)
outer_d  = 8.0;  // mm — requested outer diameter
height   = 3.2;  // mm — spacer thickness / standoff height
wall_min = 2.0;  // mm — enforced minimum radial wall

/* [Print] */
nozzle       = 0.4;  // mm — informational
fragments    = 72;   // [24:8:128] circle resolution ($fn)
bool_epsilon = 0.1;  // mm — through-cut overshoot for the bore

/* [Hidden] */
od  = max(outer_d, inner_d + 2 * wall_min);
$fn = fragments;

module spacer_washer() {
    difference() {
        cylinder(d = od, h = height, center = false);
        translate([0, 0, -bool_epsilon / 2])
            cylinder(d = inner_d, h = height + bool_epsilon, center = false);
    }
}

spacer_washer();
