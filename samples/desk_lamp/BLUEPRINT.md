# Blueprint

This file is the only spec for the OpenSCAD files in this directory.
Confirmed entries stay in force until a change is proposed and confirmed.

Do **not** put agent workflow, Customizer authoring conventions, parameter naming style, tooling, or IDE setup here. Those belong in `.cursor/rules/` and `docs/setup-environment.md`.

**Process:** Agents must propose exact wording (or the exact delete/conflict resolution), then wait for the user to manually confirm each item (or an explicitly listed set) before adding, changing, or removing anything here.

## Design

1. **Two objects, one design.** The lamp is a stand and a separate shade. They join with a friction peg on the neck into a blind socket in the shade crown. No fasteners and no wiring.
2. **Soft stem joins.** The stem eases into the base with a cove fillet, bends with a smooth upright→lean transition, and tapers with eased narrowing into the peg. No sharp shoulders at those joins.

## Objects

### stand

1. **Leaning cantilever.** The neck is a taper leaning forward from the rear of a low circular base so the shade hangs over the desk. The lean stays small enough to print base-down without support (about 18° from vertical).
2. **Print orientation.** Base on the bed. No support.
3. **Seat notch, not a full rim.** A short raised square seat on the peg (about 5% of the circumference, not a full ring) stops the shade from sliding down. No tip rim and no full circumferential collar.
4. **Rounded base.** The circular base has filleted top and bottom outer edges.

### shade

1. **Shell.** Thin conical shell, wide mouth down when assembled, with a small lip at the mouth. The crown is thick enough for the blind peg socket on the outside and a round puck seat on the inside. The socket does not break into the light cavity.
2. **Puck light.** Circular seat for a self-contained battery LED puck, default about 35 mm diameter and 10 mm deep. Mechanical holder only, not a wired fixture.
3. **Print orientation.** Narrow crown on the bed, mouth up. No support.
4. **Rounded edges.** Mouth lip and crown outer rim are rounded. The peg socket stays a simple snug blind hole with a light lead-in (no retainer groove required).
