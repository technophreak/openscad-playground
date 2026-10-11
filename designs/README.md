# Your designs

Each design is one folder. That folder owns the only Blueprint that applies to its OpenSCAD files.

## Create a design

1. Create `designs/<name>/`.
2. Add `BLUEPRINT.md` using the shape below.
3. Add `<name>.scad` with `include <../../lib/fdm.scad>;`.
4. For every `###` object heading, add `show_<name>` in `/* [Objects] */`, and always include the export dropdown.

Do not copy a sample Blueprint unless you mean to fork that sample. Agents must use only this folder’s Blueprint.

## Empty Blueprint shape

```markdown
# Blueprint

This file is the only spec for the OpenSCAD files in this directory.
Confirmed entries stay in force until a change is proposed and confirmed.

## Design

1. ...

## Objects

### part_a

1. ...

### part_b

1. ...
```

## Customizer (required)

```scad
/* [Objects] */
show_part_a = true;
show_part_b = true;

/* [Export] */
export_format = "STL"; // [STL, 3MF]

/* [Hidden] */
color_index_part_a = 0;  // stable preview color — do not renumber lightly
color_index_part_b = 1;

if (show_part_a)
    preview_object(color_index_part_a)
        part_a();
```

Each checkbox hides that entire object. Wrap each object with `preview_object(color_index_*)` from `lib/fdm.scad` so F5 keeps a persistent color per object. Export writes one mesh file per Blueprint object under `exports/` (`exports/designs/<name>/<name>_<object>.stl` or `.3mf`).
