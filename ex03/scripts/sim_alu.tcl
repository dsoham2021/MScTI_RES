# Create temporary local project env for the simulator
create_project -force alu_sim_proj ./alu_sim_proj -part xc7a35tcpg236-1

# Add design source and testbench files
add_files -fileset sources_1 ../src/alu.vhd
add_files -fileset sim_1 ../tb/alu_tb.vhd

# alu_tb is the top-level module to simulate
set_property top alu_tb [get_filesets sim_1]

# Compile, elaborate, and launch, run and close
launch_simulation
run all
close_project
