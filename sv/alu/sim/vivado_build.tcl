set TOP led_top
set PART xc7a35tcpg236-1

set BUILD_DIR ../build

file mkdir $BUILD_DIR

read_verilog -sv ../rtl/pul_gen.sv
read_verilog -sv ../rtl/led_binary.sv
read_verilog -sv ../rtl/led_rotate.sv
read_verilog -sv ../rtl/led_scanner.sv
read_verilog -sv ../rtl/led_random.sv
read_verilog -sv ../rtl/led_top.sv


read_xdc ../constr/basys3.xdc

synth_design -top $TOP -part $PART

opt_design
place_design
route_design

report_timing_summary -file $BUILD_DIR/timing_summary.rpt
report_utilization -file $BUILD_DIR/utilization.rpt

write_bitstream -force $BUILD_DIR/$TOP.bit