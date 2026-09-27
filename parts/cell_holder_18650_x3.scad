// 3×18650 clamp-in cell holder — single-piece FDM tray with snap fingers.
//
// Customizer: Window → Customizer, tweak groups below, F5 to preview.
//
// How the clamp works:
//   Each cell sits in a lower cylindrical cradle. Short snap fingers protrude
//   past the equator at two stations along each cell. Push a cell in from
//   above; the fingers flex outward and snap back to retain it.
//
// Print orientation: flat on the tray base (cell axes along Y, openings +Z).
// Finger lead-ins are chamfered for support-free printing. Use a brim if needed.
//
// Mechanical holder only — not battery protection, wiring, or pack electronics.

include <../lib/fdm.scad>;

/* [Cell] */
cell_d           = 18.0;  // mm — nominal 18650 diameter
cell_l           = 65.0;  // mm — nominal 18650 length
cell_count       = 3;     // [1:1:6] number of cells side by side
radial_clearance = 0.35;  // mm — added to diameter for the pocket
length_clearance = 0.60;  // mm — total axial play inside the tray

/* [Layout] */
wall         = 2.0;  // mm — outer wall & min divider (~5× 0.4 mm nozzle)
floor_t      = 2.0;  // mm — tray floor thickness
pitch_extra  = 0.8;  // mm — extra center-to-center beyond pocket_d + wall
end_wall     = 2.0;  // mm — stop walls at each end of the cells
fillet       = 1.2;  // mm — outer tray corner radius (plan view)
side_pad     = 1.6;  // mm — extra solid beside outer cells (finger root strength)

/* [Clamp] */
clamp_gap          = 13.2;  // mm — clear gap between opposing finger tips
finger_height      = 3.6;   // mm — how far fingers rise above the equator
finger_thickness   = 1.6;   // mm — radial thickness of each flex finger
finger_length      = 12.0;  // mm — finger length along the cell axis
finger_inset       = 10.0;  // mm — finger setback from each end stop
lead_in_depth      = 1.2;   // mm — insertion chamfer depth on finger tip
lead_in_height     = 2.4;   // mm — insertion chamfer height on finger tip

/* [Print] */
nozzle       = 0.4;  // mm — informational (prefer walls as n× nozzle)
fragments    = 64;   // [24:8:128] circle resolution ($fn)
bool_epsilon = 0.2;  // mm — through-cut overshoot for clean differences

/* [Hidden] */
pocket_d     = cell_d + radial_clearance;
pocket_r     = pocket_d / 2;
pocket_l     = cell_l + length_clearance;
pitch        = pocket_d + wall + pitch_extra;
span_x       = (cell_count - 1) * pitch;
tray_outer_x = span_x + pocket_d + 2 * (wall + side_pad);
tray_outer_y = pocket_l + 2 * end_wall;
tray_outer_z = floor_t + pocket_r + finger_height;
equator_z    = floor_t + pocket_r;
finger_reach = (pocket_d - clamp_gap) / 2;  // how far each tip intrudes past mouth
$fn          = fragments;

function cell_center_x(i) = -span_x / 2 + i * pitch;

module cell_lower_pocket(i) {
    // Seat only at/below the equator
    intersection() {
        translate([cell_center_x(i), 0, equator_z])
            rotate([90, 0, 0])
                cylinder(d = pocket_d, h = pocket_l + bool_epsilon, center = true);
        translate([cell_center_x(i), 0, equator_z / 2])
            cube(
                [pocket_d + bool_epsilon, pocket_l + bool_epsilon, equator_z + bool_epsilon],
                center = true
            );
    }
}

module cell_top_opening(i) {
    // Open the top to the full pocket width; fingers are added back afterward
    translate([cell_center_x(i), 0, equator_z + finger_height / 2 + bool_epsilon / 2])
        cube(
            [pocket_d + bool_epsilon, pocket_l + bool_epsilon, finger_height + bool_epsilon],
            center = true
        );
}

module snap_finger(side) {
    // One flex finger; local origin at cell center on the floor plane
    // side: +1 = +X, -1 = −X
    tip_x = side * (clamp_gap / 2);
    // Finger body sits from tip outward by finger_thickness + a root into the wall
    root_extra = wall * 0.5;
    x_mid = tip_x + side * (finger_thickness / 2);
    difference() {
        translate([x_mid, 0, equator_z + finger_height / 2])
            cube(
                [finger_thickness + root_extra, finger_length, finger_height],
                center = true
            );
        // Insertion / print chamfer on the tip (faces the mouth)
        translate([tip_x, 0, equator_z + finger_height - lead_in_height])
            rotate([90, 0, 0])
                linear_extrude(height = finger_length + bool_epsilon, center = true)
                    polygon([
                        [0, lead_in_height],
                        [side * lead_in_depth, lead_in_height],
                        [0, 0]
                    ]);
    }
}

module fingers_for_cell(i) {
    cx = cell_center_x(i);
    for (y_sign = [-1, 1]) {
        y = y_sign * (pocket_l / 2 - finger_inset - finger_length / 2);
        translate([cx, y, 0]) {
            snap_finger(+1);
            snap_finger(-1);
        }
    }
}

module cell_holder_18650_x3() {
    assert(clamp_gap < pocket_d, "clamp_gap must be < pocket_d for retention");
    assert(finger_reach > 0, "fingers need positive inward reach");
    assert(cell_count >= 1, "cell_count must be >= 1");

    union() {
        difference() {
            translate([0, 0, tray_outer_z / 2])
                rounded_box(
                    [tray_outer_x, tray_outer_y, tray_outer_z],
                    fillet,
                    center = true
                );

            for (i = [0 : cell_count - 1]) {
                cell_lower_pocket(i);
                cell_top_opening(i);
            }
        }

        for (i = [0 : cell_count - 1])
            fingers_for_cell(i);
    }
}

cell_holder_18650_x3();
