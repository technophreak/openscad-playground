# Agent instructions pack (no part designs)

Drop-in update for an agent working from an older copy of this repo's conventions.

## Included
- `.cursor/rules/` — agent authoring / workflow (Blueprint gate, Customizer params, project pointers)
- `docs/project-context.md` — goals and scope (not part geometry)
- `docs/setup-environment.md` — toolchain / IDE policy
- `.vscode/` — editor settings, tasks, extensions
- `scripts/setup-environment.ps1` — environment setup script
- `lib/fdm.scad` — shared FDM helpers (not a product part)
- `Makefile`, `README.md`, `.gitignore` — repo tooling

## Excluded on purpose
- `BLUEPRINT.md` and any part-design specifications
- `parts/`, `stls/`, `refs/`, media, and other product geometry

## How to apply over old instructions
1. Unpack into the target repo root (or merge the folders).
2. Replace existing `.cursor/rules/*.mdc` with these files.
3. Refresh `docs/setup-environment.md`, `docs/project-context.md`, `.vscode/`, and `scripts/` from this pack.
4. Keep the target repo's own `BLUEPRINT.md` and `parts/` unless the user says otherwise — this pack does not ship product design.

Generated: 20260927
