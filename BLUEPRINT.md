# Blueprint

**Home for part-design specifications only** — geometry, fit, FDM print intent, and other confirmed product constraints for the parts themselves.

Do **not** put agent workflow, Customizer authoring conventions, parameter naming style, tooling, or IDE setup here. Those belong in `.cursor/rules/` and `docs/setup-environment.md`.

**Process:** Agents must propose exact wording (or the exact delete/conflict resolution), then wait for the user to manually confirm each item (or an explicitly listed set) before adding, changing, or removing anything here. Conflicts with existing entries require the same propose → confirm → apply flow before code or Blueprint is altered.

## Specifications

1. **Clamp-in cell pocket.** Cell pockets are a full cylinder (axis along Y). Tray solid above the equator in each pocket column is cleared through the top so a cell can insert; only snap tabs are unioned back into that opening. Do not leave a rim that pinches the cylindrical aperture shut.

2. **Snap tabs follow the pocket circle.** Each tab’s cell-facing edge (catch and underside) is one continuous arc of the pocket radius. Tab bulk grows only into the wall and rim—not into the cell beyond that arc. Tab undersides stay on that arc for support-free printing and stronger roots. Where that arc meets the tip→rim face, round the catch with `lip_tip_radius` so the tip does not dig into cells.

3. **Snap fit target.** `clamp_gap` (mouth between opposing tips) must be less than `cell_diameter` so the cell is retained. Default is about `cell_diameter − 2.6` mm (~1.3 mm interference per side): enough flex to snap in, not so open that the cell sits loose. Narrow tabs (short along the cell axis) at two stations per cell.

4. **Uniform outer wall thickness.** Side walls (parallel to the cell axes) use the same thickness as the end walls (perpendicular to the cell axes)—`wall` / `end_wall`, with no extra side pad. Tab roots (`lip_root`) must fit within that side-wall thickness.

5. **Mechanical holder only.** The 18650 holder is a mechanical tray/clamp only—not battery protection, wiring, or pack electronics.

6. **Print orientation (cell holder).** Print flat on the tray base: cell axes along Y, openings +Z. Prefer geometry that needs no support on the tabs (curved undersides, rounded tip catch). Brim optional.

7. **Independent case height and tip→rim angle.** Wall height above the cell equator (`rim_height`) is independent of tip crest / `clamp_gap`. The tip→rim face angle (`lip_top_angle`) is independent of case height: steepen the face without growing the tray. `rim_height` must stay above the tip crest.

8. **Under-cell wood mounts.** Two M4 clearance holes (`screw_clearance`) with flat-head countersink through the floor under each cell, spaced along the cell axis. The countersink wide end clears the curved pocket floor so the screw taper is not pinched. Add a small 45° exit chamfer (`screw_exit_chamfer`) on the tray underside of each hole. Seat screws before inserting cells.

9. **Case outer edge chamfers.** Independent `top_chamfer` and `bottom_chamfer` on the tray’s outer perimeter, plus plan-view `corner_radius`. Apply top/bottom chamfers to the finished outer shell after snap tabs are unioned with the case, so clamp roots at the walls do not protrude past the chamfered edges.

10. **Pocket top inner chamfer.** Independent `pocket_top_chamfer` (smaller than the outer top chamfer) on the top inner rim of each cell opening. Apply on the finished shell with the outer edge chamfers. The chamfer opening follows the same plan corner radius as the pocket clearance.

11. **Inside pocket corner radius.** When pocket end-radius features are enabled (`enable_pocket_end_radius`), each cell opening above the equator uses a true circular plan-corner radius (`inside_corner_radius`), not a stretched fillet blend—built into the pocket upper clearance (and matched on the pocket-top chamfer profiles). Where that radius meets the end-wall bead at the equator, close the junction with the short positive stubs in (13). When the enable is off, plan corners stay sharp (rectangular clearance).

12. **Pocket end-wall radius.** Where each cell cylinder meets the end-stop walls, add a positive void-corner radius bead (`pocket_end_radius`) along the lower semicircle up to the equator. Union after the pocket cuts (not a subtractive solid-corner cut into the wall). Gated with plan-corner rounding by `enable_pocket_end_radius`.

13. **Plan-corner gap beads at the end-torus tip.** At each pocket plan corner, a short positive void-corner bead (`inside_corner_radius`) starts at the equator where the end-wall bead stops and rises only far enough to close that gap—stop below the pocket-top chamfer. Do not run these stubs the full rim height; the upper `rounded_rect` clearance and top chamfer cover the rest. Same enable as (11) and (12).

14. **Snap tab side-edge fillets.** Round the snap-tab edges (including the short ends along the cell axis, visible inside the pocket) with `lip_side_radius` via erode-then-minkowski so the cell-facing arc stays on the pocket circle. Keep the radius small enough that the tip/root thickness is not collapsed.

15. **Screw exit chamfer.** Each under-cell mount hole has a small 45° chamfer (`screw_exit_chamfer`) on the tray underside only—independent of the pocket-side flat-head countersink.
