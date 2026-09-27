# OpensCAD — project context

## Goal
Experiment with OpenSCAD to design parametric 3D parts and export STLs for FDM printing.

## Environment
- **Marc’s existing local OpenSCAD install is accepted** — no need to upgrade or switch to nightly for day-to-day editing/export
- Any working `openscad` CLI is fine for STL export (`make stls`)
- Cloud/CI: `scripts/install-openscad.sh` installs distro OpenSCAD when missing (optional nightly via `OPENSCAD_USE_NIGHTLY=1`)
- Parametric adjustments for every provided measurement (named parameters at top of each `.scad`; no buried magic numbers)

## Blueprint
- Design implementations are recorded as rules in [Blueprint](/cursor/stores/self/docs/blueprint.md)
- No add / edit / delete of Blueprint rules without Marc’s confirmation
- Conflicting changes must be validated with Marc before applying
- Until rules are confirmed, agents may **propose** rule text in summaries/PR descriptions only

## Scope (current)
- Parametric `.scad` parts aimed at FDM (walls, tolerances, manifold solids)
- STL export via OpenSCAD CLI
- Practical print notes; slicer left to the user (PrusaSlicer / Orca / Cura)
- 3×18650 clamp-in cell holder among example parts

## Out of scope (unless asked)
- Web UI, auth, databases
- Slicer profiles or printer firmware
- Large part libraries
