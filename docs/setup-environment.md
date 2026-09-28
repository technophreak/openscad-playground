# Environment setup (for agents)

General checklist for bringing this workspace’s **tooling** online. Prefer shared config under `.vscode/` and scripts under `scripts/`. Design specifications belong in `BLUEPRINT.md`, not here.

## Principles

1. **Recommend extensions** in `.vscode/extensions.json`; install missing ones with `cursor --install-extension <id>`.
2. **Commit workspace settings** in `.vscode/settings.json` (language associations, tool paths, pinned editor title actions).
3. **Declare a toolchain version policy**: minimum version; if missing install the preferred channel; if present and ≥ minimum keep it; if present but older, upgrade.
4. **Smoke-test** language mode, preview/build, and CLI — using any representative source file, not a single hard-coded feature.

## This workspace’s toolchain bindings

### OpenSCAD

| Case | Action |
|---|---|
| Not installed | Install **Nightly / development snapshot** (not stable 2021.01) |
| Installed and ≥ minimum | Keep it |
| Installed but below minimum | Install/upgrade to Nightly |

- **Minimum version:** `2025.01.01` (`YYYY.MM.DD` development builds)
- **Windows Nightly:** `winget install --id OpenSCAD.OpenSCAD.Nightly` or [development snapshots](https://openscad.org/downloads.html#snapshots)
- Common binaries: `OpenSCAD\openscad.exe`, `OpenSCAD (Nightly)\openscad.exe` (and `.com` siblings)
- Set `openscad.executablePath` in `.vscode/settings.json` to a binary that meets the minimum

### Cursor / editor

Ensure `.vscode/settings.json` includes patterns such as:

- Language association for project sources (here: `*.scad` → `scad`)
- Tool path + preview format (`openscad.executablePath`, `openscad.previewFormat`)
- Pinned title actions when an extension preview icon should stay visible (`cursor.general.pinnedTitleActions`, e.g. `openscad.showPanel`)

Ensure `.vscode/extensions.json` recommends the language + preview extensions for the stack (here: `leathong.openscad-language-support`, `thijsdaniels.vscode-openscad-preview`, and `AssetToolLabs.mesh-viewer-vscode` for exported STL/mesh preview).

### Scripted apply

```powershell
powershell -File scripts/setup-environment.ps1
```

### Smoke checks

1. Open a source file — editor language matches the association.
2. Run the in-IDE preview/build command for that language (here: **Show OpenSCAD Preview** / Ctrl+Shift+V).
3. Confirm pinned title actions appear when configured.
4. Optional: CLI/make export for one part.

## Out of scope for this doc

- Part geometry, tolerances, Customizer design rules → `BLUEPRINT.md`
- Product goals and scope → `docs/project-context.md`
