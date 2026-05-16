SRC_PATH    = ../rtl
TB_PATH     = ../tb
SNAPSHOT    = vga_tb_top_snapshot
XSIM_CFG    = Makefile_cfg_xsim.tcl

.PHONY: all compile elaborate simulate simulate_dump clean

all: simulate

compile:
	xvlog -sv \
		$(SRC_PATH)/vga_pkg.sv \
		$(SRC_PATH)/vga_top.sv \
		$(TB_PATH)/vga_tb.sv \

elaborate: compile
	xelab -debug typical -top vga_tb -snapshot $(SNAPSHOT)

simulate: elaborate
	xsim $(SNAPSHOT) -R

simulate_dump: elaborate
	xsim $(SNAPSHOT) -tclbatch $(XSIM_CFG)
	xsim --gui $(SNAPSHOT).wdb

clean:
	find . -type f ! -name 'Makefile' ! -name '*.tcl' ! -name '*.mem' -delete
	rm -rf xsim.dir