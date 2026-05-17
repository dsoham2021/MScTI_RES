read_vhdl ../src/bram_image_pkg.vhd
read_vhdl ../src/top_vga.vhd
read_xdc ../constraints/basys3_ex2.xdc

synth_design -top top_vga -part xc7a35tcpg236-1
opt_design
place_design
route_design
write_bitstream -force top_vga.bit
