// Shared FDM-friendly helpers for OpensCAD parts.
// Include from a design under samples/ or designs/ with:
//   include <../../lib/fdm.scad>;

// Default mesh density when a caller does not pass fragments=.
default_fragments = 48;
// Tiny overshoot used only inside helper boolean cleanup (not a part dimension).
helper_epsilon    = 0.01;

// Stable preview palette for Blueprint objects (F5 color only; not written into STL).
// Assign each object a fixed color_index_<object> and wrap with preview_object(index).
// Cool tones first; warm coral/peach later so default index 0/1 are not tan/salmon.
preview_palette = [
    [0.65, 0.78, 0.90], // 0 pastel blue
    [0.68, 0.86, 0.72], // 1 pastel green
    [0.62, 0.86, 0.88], // 2 pastel teal
    [0.82, 0.72, 0.90], // 3 pastel purple
    [0.78, 0.78, 0.82], // 4 pastel slate
    [0.96, 0.86, 0.62], // 5 pastel amber
    [0.96, 0.78, 0.68], // 6 pastel peach
    [0.93, 0.68, 0.66], // 7 pastel coral
];

function preview_color(index) =
    preview_palette[abs(index) % len(preview_palette)];

// Preview-only color wrapper. Use one stable color_index_* per Blueprint object.
module preview_object(index) {
    color(preview_color(index))
        children();
}

// Rounded rectangle extruded along Z (2D fillet → manifold solid).
module rounded_rect(size, radius, center = true) {
    w = size[0];
    h = size[1];
    r = min(radius, min(w, h) / 2);
    offset(r = r)
        offset(delta = -r)
            square([w, h], center = center);
}

module rounded_box(size, radius, center = true) {
    linear_extrude(height = size[2], center = center)
        rounded_rect([size[0], size[1]], radius, center = true);
}

// 45° perimeter chamfer cutter: z=0 is the full outline, z=chamfer is inset.
// Difference this from a solid to chamfer a top (or mirrored bottom) edge.
module edge_chamfer_cutter(size_xy, corner_radius, chamfer) {
    eps = helper_epsilon;
    if (chamfer > 0) {
        difference() {
            translate([0, 0, -eps])
                linear_extrude(height = chamfer + 2 * eps)
                    offset(delta = eps)
                        rounded_rect(size_xy, corner_radius, center = true);
            hull() {
                linear_extrude(height = eps)
                    rounded_rect(size_xy, corner_radius, center = true);
                translate([0, 0, chamfer])
                    linear_extrude(height = eps)
                        offset(delta = -chamfer)
                            rounded_rect(size_xy, corner_radius, center = true);
            }
        }
    }
}

// Rounded box with optional independent top / bottom outer-edge chamfers.
module chamfered_rounded_box(
    size,
    corner_radius,
    bottom_chamfer = 0,
    top_chamfer = 0,
    center = false
) {
    z0 = center ? -size[2] / 2 : 0;
    difference() {
        rounded_box(size, corner_radius, center = center);

        if (bottom_chamfer > 0) {
            translate([0, 0, z0 + bottom_chamfer])
                mirror([0, 0, 1])
                    edge_chamfer_cutter([size[0], size[1]], corner_radius, bottom_chamfer);
        }
        if (top_chamfer > 0) {
            translate([0, 0, z0 + size[2] - top_chamfer])
                edge_chamfer_cutter([size[0], size[1]], corner_radius, top_chamfer);
        }
    }
}

// Cylinder with optional countersink (flat-head screw seat).
module countersunk_hole(d, h, cs_d = undef, cs_h = undef, center = false, fragments = undef) {
    fn = is_undef(fragments) ? default_fragments : fragments;
    cd = is_undef(cs_d) ? d * 2 : cs_d;
    ch = is_undef(cs_h) ? (cd - d) / 2 : cs_h;
    union() {
        cylinder(d = d, h = h, center = center, $fn = fn);
        translate([0, 0, center ? h / 2 - ch : h - ch])
            cylinder(d1 = d, d2 = cd, h = ch, center = false, $fn = fn);
    }
}

// Simple through-hole.
module mounting_hole(d, h, center = false, fragments = undef) {
    fn = is_undef(fragments) ? default_fragments : fragments;
    cylinder(d = d, h = h, center = center, $fn = fn);
}

// Fillet along +Z edge of a cube corner (positive volume).
// Prefer 2D offset fillets on extruded profiles for reliable manifolds.
module cylinder_fillet(r, h, fragments = undef) {
    fn = is_undef(fragments) ? default_fragments : fragments;
    eps = helper_epsilon;
    difference() {
        translate([-eps, -eps, 0])
            cube([r + eps, r + eps, h]);
        translate([r, r, -eps])
            cylinder(r = r, h = h + 2 * eps, $fn = fn);
    }
}
