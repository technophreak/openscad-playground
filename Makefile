# OpensCAD — FDM design playground
# Usage:
#   make exports
#   make part PART=samples/pen/pen
#   make part PART=samples/pen/pen OBJECT=barrel
#   make exports FORMAT=3MF
#   make clean
#
# Or call the exporter directly:
#   powershell -File scripts/export-meshes.ps1 -Part samples/pen/pen

OPENSCAD ?=
FORMAT   ?=
PART     ?=
OBJECT   ?=

.PHONY: all exports stls clean part help

all: exports

help:
	@echo "Targets:"
	@echo "  make exports                           Export every Blueprint object under samples/ and designs/"
	@echo "  make part PART=samples/pen/pen         Export all objects of one design"
	@echo "  make part PART=samples/pen/pen OBJECT=barrel"
	@echo "  make exports FORMAT=3MF                Override Customizer export_format (STL or 3MF)"
	@echo "  make clean                             Remove generated meshes under exports/"
	@echo ""
	@echo "Override CLI:  make exports OPENSCAD=C:/path/to/openscad.exe"
	@echo "(make stls is an alias for make exports)"

exports:
	powershell -NoProfile -File scripts/export-meshes.ps1 $(if $(OPENSCAD),-OpenSCAD "$(OPENSCAD)") $(if $(FORMAT),-Format $(FORMAT))

stls: exports

part:
	powershell -NoProfile -File scripts/export-meshes.ps1 -Part "$(PART)" $(if $(OBJECT),-Object $(OBJECT)) $(if $(OPENSCAD),-OpenSCAD "$(OPENSCAD)") $(if $(FORMAT),-Format $(FORMAT))

clean:
	powershell -NoProfile -Command "Remove-Item -Recurse -Force -ErrorAction SilentlyContinue exports/samples,exports/designs; Remove-Item -Force -ErrorAction SilentlyContinue exports/*.stl,exports/*.3mf"
