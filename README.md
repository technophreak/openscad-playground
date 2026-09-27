# OpensCAD

Parametric OpenSCAD parts for FDM printing, with a simple CLI workflow to export STLs.

A normal local `openscad` install is all you need — whatever build you already have is fine.

## Layout

```
parts/          Parametric parts (edit these)
lib/            Shared helpers (fillets, holes)
scripts/        STL export + Cloud/CI install helpers
stls/           Generated STLs (gitignored)
Makefile        `make stls` / `make clean`
```

### Example parts

| Part | File | What it is |
|------|------|------------|
| Cable clip | `parts/cable_clip.scad` | Desk clip with snap channel + M3 mount |
| Spacer / washer | `parts/spacer_washer.scad` | Clearance spacer for M2–M6 hardware |
| Enclosure lid | `parts/enclosure_lid.scad` | Rectangular lid with lip + corner holes |
| 3×18650 holder | `parts/cell_holder_18650_x3.scad` | Clamp-in tray for three 18650 cells |

Every measurement is a named top-level parameter in Customizer groups (`/* [Group] */`). Derived values live under `/* [Hidden] */` so they do not clutter the panel.

## Install OpenSCAD

Use the OpenSCAD build you already have:

```bash
openscad --version
```

If you need a fresh install:

- **Ubuntu / Debian:** `sudo apt install openscad`
- **macOS (Homebrew):** `brew install openscad`
- **Windows / other:** [openscad.org/downloads](https://openscad.org/downloads.html)

**Cloud Agent / CI:** `.cursor/environment.json` runs `scripts/install-openscad.sh` (uses an existing `openscad` if present, otherwise the distro package). Optional Linux nightly AppImage: `OPENSCAD_USE_NIGHTLY=1 bash scripts/install-openscad.sh` or `bash scripts/install-openscad-nightly.sh` — not required for local work.

## Edit with Customizer (realtime preview)

1. Open a file under `parts/` in the **OpenSCAD desktop** app.
2. Show the panel: **Window → Customizer** (enable Customizer in Preferences if needed).
3. Tweak values in the groups (Cell, Clamp, Print, …).
4. Press **F5** for a fast preview after each change.
5. Press **F6** for a full render when you are ready to export.
6. Export from the GUI (**File → Export → Export as STL…**) or use the CLI below.

Customizer only picks up simple top-level assignments — keep new dimensions as named parameters in a `/* [Group] */` block, not buried inside modules.

## Export STLs (CLI)

```bash
make stls
```

Or `./scripts/export-stls.sh`. Single part:

```bash
make part PART=cell_holder_18650_x3
```

Override the binary if needed: `make stls OPENSCAD=/path/to/openscad`.

Meshes land in `stls/*.stl` (gitignored). Remove with `make clean`.

### 3×18650 clamp holder

- Defaults: **18 mm** Ø, **65 mm** L, **count = 3**; clearances are separate params.
- Cells snap in from above past lips formed by `clamp_gap` < pocket diameter.
- Tune `cell_d`, `cell_l`, `radial_clearance`, `clamp_gap`, `pitch_extra`, `wall`, etc. in Customizer.
- **Print flat** on the tray base (openings upward).

## FDM notes

- Keep solids **manifold** (closed; no zero-thickness faces).
- Avoid **knife edges**; give lips and channels real thickness.
- Prefer **wall thickness as a multiple of nozzle width** (e.g. 1.6 / 2.0 / 2.4 mm for a 0.4 mm nozzle).
- Expose **clearance** as its own parameter.

Shared helpers: `lib/fdm.scad`.

## Slice and print

1. Open an STL from `stls/` in **PrusaSlicer**, **OrcaSlicer**, or **Cura**.
2. Orient as noted in the part file (holder: flat on base).
3. Typical starting point: **0.2 mm layer**, **15–20% infill**, **2–3 perimeters**.
4. Export g-code for your printer and print.

## License

Parts and helpers in this repo are provided as-is for personal and project use. Adjust dimensions to your hardware before relying on a fit.
