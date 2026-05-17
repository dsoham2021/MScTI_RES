set TOP vga_top
set PART xc7a35tcpg236-1

set BUILD_DIR build

file mkdir $BUILD_DIR

read_verilog -sv ../rtl/vga_pkg.sv
read_verilog -sv ../rtl/vga_clk.sv
read_verilog -sv ../rtl/vga_top.sv


read_xdc ../constr/basys3.xdc

synth_design -top $TOP -part $PART

opt_design
place_design
route_design

report_timing_summary -file $BUILD_DIR/timing_summary.rpt
report_utilization -file $BUILD_DIR/utilization.rpt

write_bitstream -force $BUILD_DIR/$TOP.bit