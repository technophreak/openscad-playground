# OpensCAD — FDM part playground
# Usage: make stls   |  make clean  |  make part PART=cable_clip

OPENSCAD ?= openscad
PARTS_DIR := parts
STL_DIR   := stls
PARTS     := $(wildcard $(PARTS_DIR)/*.scad)
STLS      := $(patsubst $(PARTS_DIR)/%.scad,$(STL_DIR)/%.stl,$(PARTS))

.PHONY: all stls clean part help install-openscad

all: stls

help:
	@echo "Targets:"
	@echo "  make stls                 Render all parts/*.scad → stls/*.stl"
	@echo "  make part PART=name       Render one part (e.g. PART=cell_holder_18650_x3)"
	@echo "  make install-openscad     Ensure openscad CLI (Cloud/CI helper)"
	@echo "  make clean                Remove generated STLs"
	@echo ""
	@echo "Override CLI:  make stls OPENSCAD=/path/to/openscad"

install-openscad:
	bash scripts/install-openscad.sh

stls: $(STLS)

$(STL_DIR)/%.stl: $(PARTS_DIR)/%.scad lib/fdm.scad
	@mkdir -p $(STL_DIR)
	@echo "Rendering $< → $@"
	$(OPENSCAD) -o $@ $<

part:
	@test -n "$(PART)" || (echo "Set PART=name (e.g. PART=cable_clip)"; exit 1)
	@mkdir -p $(STL_DIR)
	$(OPENSCAD) -o $(STL_DIR)/$(PART).stl $(PARTS_DIR)/$(PART).scad

clean:
	rm -f $(STL_DIR)/*.stl
