read_vhdl ../src/debouncer.vhd
read_vhdl ../src/up_down_counter.vhd
read_vhdl ../src/top.vhd
read_xdc ../constraints/basys3_ex3.xdc

# Use 'top' as the root module
synth_design -top top -part xc7a35tcpg236-1
opt_design
place_design
route_design
write_bitstream -force top.bit