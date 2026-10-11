# Blueprint

This file is the only spec for the OpenSCAD files in this directory.
Confirmed entries stay in force until a change is proposed and confirmed.

Do **not** put agent workflow, Customizer authoring conventions, parameter naming style, tooling, or IDE setup here. Those belong in `.cursor/rules/` and `docs/setup-environment.md`.

**Process:** Agents must propose exact wording (or the exact delete/conflict resolution), then wait for the user to manually confirm each item (or an explicitly listed set) before adding, changing, or removing anything here.

## Design

1. **Three objects, one pen.** Barrel, cap, and cartridge share one axis. The cap slips over the top of the barrel. The cartridge sits inside the barrel and its tip exits the barrel's tip hole. No ink, no spring, and no click mechanism.
2. **Luxury cigar silhouette.** Montblanc-inspired proportions: soft cigar barrel, domed cap crown with a small outer snowcap disc, decorative bands, and a flat pocket clip. Mechanical demo only.

## Objects

### barrel

1. **Body.** Hollow tube, open at the top, with a tip hole at the writing end sized so the cartridge tip can pass and the cartridge shoulder cannot.
2. **Print orientation.** Mouth up, tip on the bed. No support.
3. **Rounded nose and band.** The writing end is a rounded elliptical nose, not a flat stump. A smooth circular-bead decorative band sits near the section.

### cap

1. **Fit.** Cup that slips over the barrel mouth with small clearance. Closed with a domed crown; a small snowcap disc sits on the outside of the tip (sunk into the crown, not floating). It does not enclose the writing tip.
2. **Print orientation.** Mouth up. No support.
3. **Pocket clip.** Flat clip mounted on a crown band near the dome, leaf toward the mouth, slight inward tip angle, small air gap from the skirt, ball tip. Not a full ring and not recessed into the skirt.
4. **Bands.** Smooth circular-bead rings: one at the crown (clip mount) and a twin pair near the open mouth.

### cartridge

1. **Ink piece.** Slim body inside the barrel, shoulder seated on the tip-hole ledge, smooth transitions, ballpoint tip with its equator flush with the tip face. The tip protrudes only a short distance past the barrel nose.
2. **Print orientation.** Standing on the tip end. No support.
