// 3×18650 clamp-in cell holder — single-piece FDM tray with snap lips.
//
// Customizer: Window → Customizer, tweak user groups below, F5 to preview.
// Design constants live under [Hidden] — edit in the .scad if needed.
//
// How the clamp works:
//   Each cell sits in a full cylindrical pocket (axis along Y). The tray solid
//   above the equator is cleared through the top so a cell can drop in; only
//   narrow curved snap tabs are added back. Tips sit on the pocket curve just
//   past mid-height (clamp_gap ≈ cell_diameter − 2×1.3 mm) so the cell cams
//   the tabs open on insertion, then they catch the shoulders without sitting
//   loose.
//
// Print orientation: flat on the tray base (cell axes along Y, openings +Z).
// Tab undersides follow the cell arc (support-free); tip where that arc meets
// the top incline is rounded (lip_tip_radius) so the catch does not dig into
// cells. Use a brim if needed.
//
// Base mount: two M4 countersunk holes through the floor under each cell
// (along the cell axis). Seat flat-head screws before inserting cells.
//
// Mechanical holder only — not battery protection, wiring, or pack electronics.

include <../lib/fdm.scad>;

/* [Cell] */
cell_diameter    = 18.0;  // mm — nominal 18650 diameter
cell_length      = 65.0;  // mm — nominal 18650 length
cell_count       = 3;     // [1:1:6] number of cells side by side
radial_clearance = 0.35;  // mm — added to diameter for the pocket
length_clearance = 0.60;  // mm — total axial play inside the tray

/* [Clamp] */
// Mouth between tab tips. Default ≈ cell_diameter − 2.6 mm (~1.3 mm
// interference per side): enough flex to snap in, still retains once seated.
clamp_gap       = 17;  // mm — clear gap between opposing tab tips
lip_top_angle   = 45;  // deg — tip→rim face from horizontal
lip_tip_radius  = 0.6; // mm — fillet where cell-arc catch meets tip→rim face
lip_side_radius = 0;   // mm — tab end-edge fillet (0 = sharp; minkowski is slow in STL preview)

/* [Case] */
wall             = 2.0;  // mm — outer wall & min divider (~5× 0.4 mm nozzle)
floor_thickness  = 2.0;  // mm — tray floor thickness
rim_height       = 4.6;  // mm — wall height above cell equator (independent of tip)
corner_radius    = 1.2;  // mm — outer tray corner radius (plan view)
top_chamfer         = 0.6;  // mm — chamfer on case top outer edges
bottom_chamfer      = 0.6;  // mm — chamfer on case bottom outer edges
pocket_top_chamfer       = 0.4;  // mm — chamfer on cell-pocket top inner edges
inside_corner_radius     = 0.8;  // mm — circular radius at inside pocket plan corners
enable_pocket_end_radius = true; // end-wall beads + rounded plan corners / gap stubs
pocket_end_radius        = 0.8;  // mm — circular radius where cell cylinder meets end walls

/* [Mount] */
screw_clearance      = 4.5;  // mm — clearance for M4 (loose)
screw_exit_chamfer   = 0.4;  // mm — small 45° chamfer on hole at tray underside

/* [Hidden] */
// Design constants (tuned for print/strength; uncommon to customize)
pitch_extra   = 0.8;   // mm — extra center-to-center beyond pocket_d + wall
end_wall      = 2.0;   // mm — stop walls at each end of the cells (= wall)
lip_length    = 4.0;   // mm — narrow tab length along the cell axis (flexure)
lip_inset     = 14.0;  // mm — tab setback from each end stop
lip_root      = 2.0;   // mm — tab anchor into side wall (≤ wall; no extra pad)
lip_thick     = 3.6;   // mm — how far the cell-arc underside sits below the tip
screw_cs_d    = 9.0;   // mm — M4 flat-head countersink outer diameter
screw_cs_h    = 2.0;   // mm — countersink depth (≈ floor; flush with pocket floor)
mount_y_inset = 14.0;  // mm — hole setback from each pocket end (along Y)
nozzle        = 0.4;   // mm — informational (prefer walls as n× nozzle)
fragments     = 64;    // circle resolution ($fn)
bool_epsilon  = 0.2;   // mm — through-cut overshoot for clean differences

// Derived
pocket_d      = cell_diameter + radial_clearance;
pocket_r      = pocket_d / 2;
pocket_l      = cell_length + length_clearance;
pitch         = pocket_d + wall + pitch_extra;
span_x        = (cell_count - 1) * pitch;
equator_z     = floor_thickness + pocket_r;
// Tip of each finger lies on the pocket circle at x = ±clamp_gap/2
lip_crest_h   = sqrt(pocket_r * pocket_r - (clamp_gap / 2) * (clamp_gap / 2));
tray_outer_x  = span_x + pocket_d + 2 * wall;  // side walls match end_wall thickness
tray_outer_y  = pocket_l + 2 * end_wall;
tray_outer_z  = floor_thickness + pocket_r + rim_height;
finger_reach  = (pocket_d - clamp_gap) / 2;
phi_tip       = acos((clamp_gap / 2) / pocket_r);  // deg from +X to finger tip
// Bottom of tab on the same circle, set by lip_thick (curved underside)
phi_bot       = asin(max(0.05, min(0.98, (lip_crest_h - lip_thick) / pocket_r)));
// Tip→rim face: rise from tip crest up to fixed rim_height
lip_top_rise  = rim_height - lip_crest_h;
lip_top_span  = pocket_r + lip_root - clamp_gap / 2;
lip_top_run   = min(lip_top_span, lip_top_rise / tan(lip_top_angle));
// Pocket floor rises above the floor plane away from the cell centerline;
// lift the countersink wide end so the flat-head cone is not pinched.
screw_cs_rise = pocket_r - sqrt(pocket_r * pocket_r - (screw_cs_d / 2) * (screw_cs_d / 2));
screw_cs_top  = floor_thickness + screw_cs_rise + bool_epsilon;
// Plan-corner rounding rides the same enable as end-wall beads.
plan_corner_r = enable_pocket_end_radius ? inside_corner_radius : 0;
$fn           = fragments;

function cell_center_x(i) = -span_x / 2 + i * pitch;

module cell_pocket(i) {
    // Full cylindrical cavity (defines the seat and side walls)
    translate([cell_center_x(i), 0, equator_z])
        rotate([90, 0, 0])
            cylinder(d = pocket_d, h = pocket_l + bool_epsilon, center = true);
}

module cell_upper_clearance(i) {
    // Clear above the equator. Plan corners use plan_corner_r (tied to
    // enable_pocket_end_radius) — true circular radii, not a hulled blend.
    translate([cell_center_x(i), 0, equator_z])
        linear_extrude(height = rim_height + bool_epsilon)
            rounded_rect(
                [pocket_d + bool_epsilon, pocket_l + bool_epsilon],
                plan_corner_r,
                center = true
            );
}

module pocket_corner_beads(i) {
    // Positive void-corner beads at the plan corners — short stubs only,
    // from where the end torus stops (equator) up just enough to fill the
    // gap. Upper rounded_rect + top chamfer cover the rest of the height.
    rf     = plan_corner_r;
    fnr    = max(12, fragments / 4);
    half_x = (pocket_d + bool_epsilon) / 2;
    half_y = (pocket_l + bool_epsilon) / 2;
    z0     = equator_z;
    h_max  = max(0, rim_height - pocket_top_chamfer);
    // Short stub: tall enough to close the torus-tip gap, stop below top chamfer.
    h      = min(4 * rf, h_max);
    if (rf > 0 && h > 0) {
        cx = cell_center_x(i);
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([
                cx + sx * (half_x - rf),
                sy * (half_y - rf),
                z0
            ])
                linear_extrude(height = h)
                    difference() {
                        translate([sx > 0 ? 0 : -rf, sy > 0 ? 0 : -rf])
                            square([rf, rf]);
                        circle(r = rf, $fn = fnr);
                    }
        }
    }
}

module pocket_end_radius_beads(i) {
    // Positive void-corner beads at cylinder / end wall. Lower semicircle
    // to the equator (plan-corner beads continue upward from there).
    rf  = pocket_end_radius;
    fnr = max(12, fragments / 4);
    end_half = (pocket_l + bool_epsilon) / 2;
    if (rf > 0) {
        for (sy = [-1, 1]) {
            translate([cell_center_x(i), sy * end_half, equator_z])
                rotate([sy > 0 ? 90 : -90, 0, 0])
                    rotate([0, 0, sy > 0 ? 180 : 0])
                        rotate_extrude(angle = 180, convexity = 4)
                            difference() {
                                translate([pocket_r - rf, 0])
                                    square([rf, rf]);
                                translate([pocket_r - rf, rf])
                                    circle(r = rf, $fn = fnr);
                            }
        }
    }
}

module pocket_top_chamfer_cutter(i) {
    // 45° inner chamfer at the top rim (hull of opening → expanded top).
    // Match upper-clearance overshoot so the cutter starts on the real wall.
    ch = pocket_top_chamfer;
    if (ch > 0) {
        translate([cell_center_x(i), 0, tray_outer_z - ch])
            hull() {
                linear_extrude(height = helper_epsilon)
                    rounded_rect(
                        [pocket_d + bool_epsilon, pocket_l + bool_epsilon],
                        plan_corner_r,
                        center = true
                    );
                translate([0, 0, ch])
                    linear_extrude(height = helper_epsilon)
                        rounded_rect(
                            [
                                pocket_d + bool_epsilon + 2 * ch,
                                pocket_l + bool_epsilon + 2 * ch
                            ],
                            plan_corner_r,
                            center = true
                        );
            }
    }
}

module snap_finger_2d(side) {
    // Curved tab: entire cell-facing edge (catch + underside) is one arc of
    // the pocket circle — prints support-free and roots stronger. Bulk grows
    // outward into the wall and up into the rim only.
    // Tip→rim face angle is lip_top_angle (then a flat land to the outer wall).
    // Convex tip (arc / incline) is filleted with lip_tip_radius for cell-safe catch.
    // side: +1 = +X, -1 = −X.
    s      = side;
    r      = pocket_r;
    a_bot  = phi_bot;
    a_tip  = phi_tip;
    steps  = max(6, ceil(fragments * abs(a_tip - a_bot) / 360));
    da     = (a_tip - a_bot) / steps;
    z_bot  = r * sin(a_bot);
    z_top  = rim_height;
    tip_x  = s * r * cos(a_tip);
    land_x = tip_x + s * lip_top_run;
    wall_x = s * (r + lip_root);

    // Continuous cell-radius arc from underside up to the tip
    arc = [for (i = [0 : steps]) [s * r * cos(a_bot + i * da), r * sin(a_bot + i * da)]];
    outline = concat(arc, [[land_x, z_top], [wall_x, z_top], [wall_x, z_bot]]);

    if (lip_tip_radius > 0) {
        // Shrink/expand rounds convex corners (tip) without changing the pocket arc radius
        offset(r = lip_tip_radius)
            offset(r = -lip_tip_radius)
                polygon(outline);
    } else {
        polygon(outline);
    }
}

module snap_finger(side) {
    // Local origin at cell center on the floor plane. Round tab edges
    // (including ±Y ends inside the pocket): erode profile by rs, extrude
    // shorter, minkowski with a sphere — circular pocket arc is preserved
    // by offset±rs. Keep rs below tip/root thickness so the tip does not
    // collapse.
    rs  = lip_side_radius;
    fnr = max(16, fragments / 3);
    translate([0, 0, equator_z])
        rotate([90, 0, 0]) {
            if (rs > 0 && lip_length > 2 * rs) {
                minkowski() {
                    linear_extrude(
                        height = lip_length - 2 * rs,
                        center = true
                    )
                        offset(r = -rs)
                            snap_finger_2d(side);
                    sphere(r = rs, $fn = fnr);
                }
            } else {
                linear_extrude(height = lip_length, center = true)
                    snap_finger_2d(side);
            }
        }
}

module fingers_for_cell(i) {
    cx = cell_center_x(i);
    for (y_sign = [-1, 1]) {
        y = y_sign * (pocket_l / 2 - lip_inset - lip_length / 2);
        translate([cx, y, 0]) {
            snap_finger(+1);
            snap_finger(-1);
        }
    }
}

module mount_holes() {
    // Two M4 countersinks per cell under the pocket floor (along Y).
    // Shaft spans the full tray height so the cut opens on the base.
    // Cone continues above the floor plane to clear the curved pocket seat.
    // Small exit chamfer on the underside (z=0) eases screw start / print edge.
    cs_z0 = screw_cs_top - screw_cs_h;
    ch    = screw_exit_chamfer;
    for (i = [0 : cell_count - 1], sy = [-1, 1]) {
        y = sy * (pocket_l / 2 - mount_y_inset);
        translate([cell_center_x(i), y, 0]) {
            translate([0, 0, -bool_epsilon])
                mounting_hole(
                    screw_clearance,
                    tray_outer_z + 2 * bool_epsilon,
                    fragments = fragments
                );
            translate([0, 0, cs_z0])
                cylinder(
                    d1 = screw_clearance,
                    d2 = screw_cs_d,
                    h = screw_cs_h + bool_epsilon,
                    $fn = fragments
                );
            if (ch > 0)
                translate([0, 0, -bool_epsilon])
                    cylinder(
                        d1 = screw_clearance + 2 * ch,
                        d2 = screw_clearance,
                        h = ch + bool_epsilon,
                        $fn = fragments
                    );
        }
    }
}

module cell_holder_18650_x3() {
    assert(clamp_gap < cell_diameter, "clamp_gap must be < cell_diameter to retain the cell");
    assert(clamp_gap < pocket_d, "clamp_gap must be < pocket_d for retention");
    assert(clamp_gap > 0, "clamp_gap must be > 0");
    assert(lip_top_angle > 0 && lip_top_angle < 90, "lip_top_angle must be between 0 and 90 deg");
    assert(rim_height > lip_crest_h, "rim_height must be above the finger tip (raise rim or widen clamp_gap)");
    assert(lip_top_rise > 0 && lip_top_run > 0, "tip→rim face needs positive rise and run");
    assert(lip_tip_radius >= 0 && lip_tip_radius < lip_top_rise, "lip_tip_radius must fit below the rim land");
    assert(lip_side_radius >= 0, "lip_side_radius must be >= 0");
    assert(
        lip_side_radius == 0 || lip_side_radius * 2 < lip_length,
        "lip_side_radius must fit within lip_length"
    );
    assert(finger_reach > 0, "tabs need positive inward reach");
    assert(lip_crest_h > 0, "clamp_gap too large for cylindrical finger tips");
    assert(phi_bot > 0 && phi_bot < phi_tip, "lip_thick must leave a curved tab span on the cell arc");
    assert(lip_root > 0 && lip_root <= wall, "lip_root must fit within side wall thickness");
    assert(lip_thick > 0, "lip_thick must be > 0");
    if (lip_side_radius > 0)
        assert(
            lip_side_radius < lip_root && lip_side_radius < lip_thick,
            "lip_side_radius must fit in the tab root / thickness"
        );
    assert(cell_count >= 1, "cell_count must be >= 1");
    assert(screw_clearance > 0, "screw_clearance must be > 0");
    assert(screw_cs_d > screw_clearance, "countersink must be larger than screw clearance");
    assert(screw_cs_h > 0, "screw_cs_h must be > 0");
    assert(screw_cs_d < pocket_d, "countersink must fit inside the cell pocket");
    assert(screw_cs_top > floor_thickness, "countersink must clear the curved pocket floor");
    assert(screw_exit_chamfer >= 0, "screw_exit_chamfer must be >= 0");
    assert(
        screw_exit_chamfer < floor_thickness && screw_exit_chamfer < screw_clearance,
        "screw_exit_chamfer must fit in the floor and hole"
    );
    assert(mount_y_inset > screw_cs_d / 2, "mount_y_inset must clear the pocket end");
    assert(mount_y_inset < pocket_l / 2 - screw_cs_d / 2, "mount holes must not overlap at cell mid-length");
    assert(top_chamfer >= 0 && bottom_chamfer >= 0, "edge chamfers must be >= 0");
    assert(pocket_top_chamfer >= 0, "pocket_top_chamfer must be >= 0");
    assert(
        top_chamfer + bottom_chamfer < tray_outer_z,
        "top_chamfer + bottom_chamfer must be less than case height"
    );
    assert(
        top_chamfer < min(tray_outer_x, tray_outer_y) / 2
            && bottom_chamfer < min(tray_outer_x, tray_outer_y) / 2,
        "edge chamfers must fit within the case plan size"
    );
    assert(
        pocket_top_chamfer < rim_height && pocket_top_chamfer < wall,
        "pocket_top_chamfer must fit in the rim / wall land"
    );
    assert(inside_corner_radius >= 0, "inside_corner_radius must be >= 0");
    assert(
        inside_corner_radius < min(wall, end_wall) && inside_corner_radius < pocket_r,
        "inside_corner_radius must fit in the walls and pocket"
    );
    if (enable_pocket_end_radius) {
        assert(pocket_end_radius >= 0, "pocket_end_radius must be >= 0");
        assert(
            pocket_end_radius < end_wall && pocket_end_radius < pocket_r,
            "pocket_end_radius must fit in the end wall and pocket"
        );
    }

    // Chamfer the finished outer shell (case + tabs) so clamp roots at the
    // walls do not stick out past the case top/bottom edge chamfers.
    // When enable_pocket_end_radius: end-wall beads, rounded plan corners
    // (rounded_rect + top chamfer), and short positive corner gap stubs.
    difference() {
        union() {
            difference() {
                translate([0, 0, tray_outer_z / 2])
                    rounded_box(
                        [tray_outer_x, tray_outer_y, tray_outer_z],
                        corner_radius,
                        center = true
                    );

                for (i = [0 : cell_count - 1]) {
                    cell_pocket(i);
                    cell_upper_clearance(i);
                }
                mount_holes();
            }

            if (enable_pocket_end_radius) {
                for (i = [0 : cell_count - 1])
                    pocket_end_radius_beads(i);
                for (i = [0 : cell_count - 1])
                    pocket_corner_beads(i);
            }
            for (i = [0 : cell_count - 1])
                fingers_for_cell(i);
        }

        if (bottom_chamfer > 0) {
            translate([0, 0, bottom_chamfer])
                mirror([0, 0, 1])
                    edge_chamfer_cutter(
                        [tray_outer_x, tray_outer_y],
                        corner_radius,
                        bottom_chamfer
                    );
        }
        if (top_chamfer > 0) {
            translate([0, 0, tray_outer_z - top_chamfer])
                edge_chamfer_cutter(
                    [tray_outer_x, tray_outer_y],
                    corner_radius,
                    top_chamfer
                );
        }
        for (i = [0 : cell_count - 1])
            pocket_top_chamfer_cutter(i);
    }
}

cell_holder_18650_x3();
