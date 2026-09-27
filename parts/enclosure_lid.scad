// Simple rectangular enclosure lid with a lip and four corner screw holes.
// Customizer: Window → Customizer, tweak groups below, F5 to preview.

include <../lib/fdm.scad>;

/* [Size] */
outer_x  = 80.0;  // mm — lid outer X
outer_y  = 60.0;  // mm — lid outer Y
lid_top  = 2.4;   // mm — top plate thickness (~3× nozzle)
lip_h    = 4.0;   // mm — downward lip height
lip_wall = 2.0;   // mm — lip wall thickness
fit_gap  = 0.3;   // mm — clearance so lip slips over box walls

/* [Mount] */
fillet          = 3.0;  // mm — outer corner radius
screw_d         = 3.4;  // mm — M3 clearance
hole_inset      = 6.0;  // mm — hole center inset from outer edges
inner_fillet_min = 0.1; // mm — floor for inner lip fillet after wall/gap

/* [Print] */
nozzle       = 0.4;  // mm — informational
fragments    = 48;   // [24:8:128] circle / arc resolution ($fn)
bool_epsilon = 0.2;  // mm — through-cut overshoot

/* [Hidden] */
inner_x      = outer_x - 2 * (lip_wall + fit_gap);
inner_y      = outer_y - 2 * (lip_wall + fit_gap);
inner_fillet = max(inner_fillet_min, fillet - lip_wall - fit_gap);
$fn          = fragments;

module enclosure_lid() {
    difference() {
        union() {
            translate([0, 0, lid_top / 2])
                rounded_box([outer_x, outer_y, lid_top], fillet, center = true);

            translate([0, 0, -lip_h / 2])
                difference() {
                    rounded_box([outer_x, outer_y, lip_h], fillet, center = true);
                    rounded_box(
                        [inner_x, inner_y, lip_h + bool_epsilon],
                        inner_fillet,
                        center = true
                    );
                }
        }

        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([
                sx * (outer_x / 2 - hole_inset),
                sy * (outer_y / 2 - hole_inset),
                -bool_epsilon / 2
            ])
                mounting_hole(
                    screw_d,
                    lid_top + lip_h + bool_epsilon,
                    fragments = fragments
                );
        }
    }
}

enclosure_lid();
