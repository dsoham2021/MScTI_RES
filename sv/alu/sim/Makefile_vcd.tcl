open_vcd vga_wave.vcd
log_vcd [get_objects -r *]
run all
close_vcd
exit