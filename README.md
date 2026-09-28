# OpensCAD

Parametric OpenSCAD parts for FDM printing.

## Setup

Agents (and humans) should follow [docs/setup-environment.md](docs/setup-environment.md). Quick script:

```powershell
powershell -File scripts/setup-environment.ps1
```

That installs the OpenSCAD Cursor extensions and ensures an OpenSCAD **Nightly** CLI when none is present (minimum **2025.01.01**; existing installs that meet the minimum are kept). Workspace settings pin the preview icon and point at OpenSCAD.

## Layout

```
parts/                  Parametric parts (edit these)
lib/                    Shared helpers
stls/                   Generated STLs (gitignored)
docs/project-context.md Goals / scope
docs/setup-environment.md Tooling setup (general)
BLUEPRINT.md            Design specifications
.vscode/                Extensions + settings
scripts/setup-environment.ps1
Makefile                make stls / make clean / make part
```


## Parts

| Part | File |
|------|------|
| Cable clip | `parts/cable_clip.scad` |
| Spacer / washer | `parts/spacer_washer.scad` |
| Enclosure lid | `parts/enclosure_lid.scad` |
| 3×18650 holder | `parts/cell_holder_18650_x3.scad` |

Open a `.scad` in the **OpenSCAD desktop app** → **Window → Customizer** → **F5**.

In-editor preview: open a `.scad` and press **Ctrl+Shift+V**, or Command Palette → **Show OpenSCAD Preview**.

Title-bar icon is pinned via workspace setting `cursor.general.pinnedTitleActions: ["openscad.showPanel"]`.

## Export STLs

```bash
make stls
make part PART=cell_holder_18650_x3
```

Override the binary if needed:

```bash
make stls OPENSCAD="C:/Program Files/OpenSCAD/openscad.exe"
```
