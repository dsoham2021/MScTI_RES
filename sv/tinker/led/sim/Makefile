SRC_PATH      = ../rtl
TB_PATH       = ../tb
CONSTR_PATH   = ../constr
BUILD_PATH    = ./build

TOP            = led_top
TB_TOP         = tb_top

PART           = xc7a35tcpg236-1

SNAPSHOT       = led_tb_snapshot

XSIM_VCD       = Makefile_vcd.tcl
XSIM_WDB       = Makefile_wdb.tcl

VIVADO_SCRIPT  = vivado_build.tcl

RTL_SRCS = \
	$(SRC_PATH)/pul_gen.sv \
	$(SRC_PATH)/led_binary.sv \
	$(SRC_PATH)/led_rotate.sv \
	$(SRC_PATH)/led_scanner.sv \
	$(SRC_PATH)/led_random.sv \
	$(SRC_PATH)/led_top.sv

TB_SRCS = \
	$(TB_PATH)/tb_top.sv

XDC_FILE = \
	$(CONSTR_PATH)/basys3.xdc

.PHONY: sim_vcd sim_gui bitstream clean

########################################
# Simulation
########################################

compile:
	xvlog -sv $(RTL_SRCS) $(TB_SRCS)

elaborate: compile
	xelab -debug typical -top $(TB_TOP) -snapshot $(SNAPSHOT)

sim_vcd: elaborate
	xsim $(SNAPSHOT) -tclbatch $(XSIM_VCD)

sim_gui: elaborate
	xsim $(SNAPSHOT) -tclbatch $(XSIM_WDB)
	xsim --gui $(SNAPSHOT).wdb

########################################
# FPGA Build
########################################

bitstream:
	mkdir -p $(BUILD_PATH)
	vivado -mode batch -source $(VIVADO_SCRIPT)

########################################
# Cleanup
########################################

clean:
	rm -rf xsim.dir
	rm -rf .Xil
	rm -rf *.jou *.log *.pb *.str
	rm -rf *.vcd *.wdb
	rm -rf $(BUILD_PATH)