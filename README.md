# OpensCAD

A Blueprint workspace for parametric OpenSCAD parts aimed at FDM printing.

Confirmed design decisions live in each design’s `BLUEPRINT.md` so later iterations cannot quietly drop them — the usual failure mode of a long chat with no locked spec. One design folder can hold several objects; each object has its own section in that Blueprint and its own Customizer checkbox.

## Setup

Follow [docs/setup-environment.md](docs/setup-environment.md). Quick script:

```powershell
powershell -File scripts/setup-environment.ps1
```

That installs the OpenSCAD Cursor extensions and ensures an OpenSCAD **Nightly** CLI when none is present (minimum **2025.01.01**).

## Layout

```
samples/cell_holder_18650_x3/   Shipped cell-holder sample
  BLUEPRINT.md                   Specs for this sample only
  cell_holder_18650_x3.scad
samples/desk_lamp/               Shipped desk-lamp sample
  BLUEPRINT.md                   Specs for this sample only
  desk_lamp.scad
samples/pen/                     Shipped pen sample (three objects)
  BLUEPRINT.md                   barrel, cap, and cartridge
  pen.scad                       show_barrel, show_cap, show_cartridge
designs/<name>/                  Your designs, one folder each
  BLUEPRINT.md                   Specs for that design only
  <name>.scad
lib/                             Shared OpenSCAD helpers (not a design)
exports/                         Generated meshes — .stl and .3mf (gitignored)
docs/                            Scope and toolchain setup
.cursor/rules/                   Agent authoring rules (not part geometry)
scripts/                         Environment setup and mesh export
Makefile                         make exports / make part
```

## Try a sample

Open `samples/pen/pen.scad` in the **OpenSCAD** desktop app → **Window → Customizer** → **F5**.

The pen is the walk-through for several objects in one design: `show_barrel`, `show_cap`, and `show_cartridge` each hide only that object’s geometry. `export_format` chooses **STL** or **3MF**.

Also shipped:

| Sample | Path |
|--------|------|
| 3×18650 holder | `samples/cell_holder_18650_x3/cell_holder_18650_x3.scad` |
| Desk lamp | `samples/desk_lamp/desk_lamp.scad` |
| Pen | `samples/pen/pen.scad` |

In-editor preview: open a `.scad` and press **Ctrl+Shift+V**, or Command Palette → **Show OpenSCAD Preview**. Object colors need 3MF preview + lazy union + `scripts/openscad-cli.exe` (built by the setup script). Reload the Cursor window after setup; leave the Colors toggle on.

## Blueprint shape (objects stay locked)

Each design directory has one Blueprint. Several objects live as separate sections so a later change to one cannot rewrite the others:

```markdown
## Design
1. Shared relationship between objects…

## Objects

### barrel
1. Rules for the barrel only…

### cap
1. Rules for the cap only…
```

Tell an agent which design you mean by opening a file in that folder, and which object by its `###` name. Specs for that object stay in that section; other objects stay as already confirmed.

## Start a new design

1. Create `designs/<name>/`.
2. Add `BLUEPRINT.md` (see [designs/README.md](designs/README.md)).
3. Add `<name>.scad` with `include <../../lib/fdm.scad>;`, one `show_<object>` per Blueprint object, and `export_format`.
4. Do not copy a sample Blueprint unless you mean to fork that sample.

## Export meshes

Each Blueprint object exports as its own file so the slicer loads separate parts:

```bash
make exports
make part PART=samples/pen/pen
make part PART=samples/pen/pen OBJECT=barrel
make exports FORMAT=3MF
```

Or:

```powershell
powershell -File scripts/export-meshes.ps1 -Part samples/pen/pen
```

STL and 3MF both land under `exports/` (same tree). Examples: `exports/samples/pen/pen_barrel.stl`, `pen_cap.stl`, `pen_cartridge.stl` (or `.3mf`).

Override the OpenSCAD binary if needed:

```bash
make exports OPENSCAD="C:/Program Files/OpenSCAD/openscad.exe"
```
