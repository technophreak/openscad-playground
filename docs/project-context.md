# OpensCAD — project context

## Goal
Experiment with OpenSCAD to design parametric 3D parts and export meshes for FDM printing. Confirmed design decisions live in each design’s Blueprint so later iterations cannot quietly drop them.

## Where things live
- **Part design specifications** → `BLUEPRINT.md` inside each design directory under `samples/` or `designs/` (product geometry/fit/print intent only; object containers under `## Objects`)
- **Tooling / IDE environment** → [`setup-environment.md`](./setup-environment.md) (keep general; bindings in `.vscode/` + `scripts/`)
- **Agent authoring / workflow** → `.cursor/rules/` (Customizer structure, naming, Blueprint gate, per-design binding — not part geometry)

## Environment (summary)
- Follow the toolchain policy in `setup-environment.md` (OpenSCAD minimum `2025.01.01`; Nightly if missing or too old).
- Parametric work uses named top-level parameters; Customizer group split and naming are agent rules (`.cursor/rules/openscad-parameters.mdc`), not Blueprint.

## Blueprint
- Each design directory owns exactly one Blueprint. Agents must not apply another design’s Blueprint.
- Blueprint holds **part-design** specifications only, split into `## Design` (shared) and `###` object sections.
- Flow for **adds, changes, deletes, and conflicts**: agent proposes exact wording/action → user manually confirms each item (or a listed set) → only then update the file or conflicting design.
- Agent instructions and authoring conventions do not belong in Blueprint.

## Scope (current)
- Parametric `.scad` parts aimed at FDM (walls, tolerances, manifold solids)
- One mesh file per Blueprint object (STL or 3MF) via OpenSCAD CLI / Makefile
- Practical print notes; slicer left to the user (PrusaSlicer / Orca / Cura)
- Shipped example designs under `samples/`; user designs under `designs/`

## Out of scope (unless asked)
- Web UI, auth, databases
- Slicer profiles or printer firmware
- Large part libraries
