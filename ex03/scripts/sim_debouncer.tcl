# Create project and add the debouncer files
create_project -force debouncer_sim ./debouncer_sim -part xc7a35tcpg236-1
add_files -fileset sources_1 ../src/debouncer.vhd
add_files -fileset sim_1 ../tb/debouncer_tb.vhd
set_property top debouncer_tb [get_filesets sim_1]

# Launch the simulator
launch_simulation

# Create a VCD file to store the waveform data
open_vcd debouncer.vcd

# Record every signal inside the testbench
log_vcd [get_objects -r /debouncer_tb/*]

# Run the simulation 
run all

# Safely close and write the VCD file
close_vcd
close_project
