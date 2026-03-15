TOP = unic_cass_wrapper_1p4x1p4
TOP_DESIGN = user_project_wrapper_1p4x1p4
TAG ?= unic_cass_wrapper_1p4x1p4_run
HOME_DIR = ../../
PROJECT_DIR = $(HOME_DIR)/unic_cass_wrapper_digital
LIBRELANE_DIR ?= $(HOME_DIR)/librelane
PDK_ROOT = $(HOME_DIR)/IHP-Open-PDK
PDK=ihp-sg13g2

CONFIG_FILE = $(PROJECT_DIR)/$(TOP)/config.json

.PHONY: all
all: librelane drc

librelane: final/gds/$(TOP).gds
.PHONY: librelane

final/gds/$(TOP).gds:
	# Run librelane to generate the layout
	nix-shell --pure $(LIBRELANE_DIR) --run "PDK_ROOT=$(PDK_ROOT) PDK=$(PDK) librelane --run-tag $(TAG) --overwrite --manual-pdk $(CONFIG_FILE)"

	# copy final results to top directory
	rm -rf $(PROJECT_DIR)/$(TOP)/final
	cp -r $(PROJECT_DIR)/$(TOP)/runs/$(TAG)/final $(PROJECT_DIR)/$(TOP)

.PHONY: view_results
view_results: 
	# View the results in KLayout
	nix-shell --pure $(LIBRELANE_DIR) --run "PDK_ROOT=$(PDK_ROOT) PDK=$(PDK) librelane --last-run --manual-pdk $(CONFIG_FILE) --flow OpenInOpenROAD"

.PHONY: drc
drc: 
	# Run DRC on the generated GDS
	python $(PDK_ROOT)/$(PDK)/libs.tech/klayout/tech/drc/run_drc.py --path final/gds/$(TOP_DESIGN).gds --run_dir final/drc --no_density --disable_extra_rules --no_recommended

.PHONY:
metal-filler: final/gds_filler/$(TOP)_filler.gds 

final/gds_filler/$(TOP)_filler.gds: final/gds/$(TOP).gds
	# Run metal filler generation
	mkdir -p final/gds_filler/
	cp final/gds/$(TOP).gds final/gds_filler/$(TOP)_filler.gds
	nix-shell --pure $(LIBRELANE_DIR) --run "klayout -zz -r $(PDK_ROOT)/$(PDK)/libs.tech/klayout/tech/scripts/filler.py -rd output_file=final/gds_filler/$(TOP)_filler.gds.gz final/gds_filler/$(TOP).gds"

.PHONY:
detailed-filler: final/gds_filler/$(TOP)_detailed_filler.gds

final/gds_filler/$(TOP)_detailed_filler.gds: final/gds_filler/$(TOP)_filler.gds
	# Run detailed metal filler generation (this is done with magic)
	cp final/gds_filler/$(TOP)_klayout_fill.gds.gz final/gds_filler/${TOP}.gds.gz
	nix-shell --pure $(LIBRELANE_DIR) --run "$(PDK_ROOT)/$(PDK)/libs.tech/magic/generate_fill.py final/gds_filler/${TOP}.gds.gz -dist"
	cp final/gds/${TOP}_fill_pattern.gds.gz final/gds_filler/
	rm final/gds/${TOP}_fill_pattern.gds.gz

