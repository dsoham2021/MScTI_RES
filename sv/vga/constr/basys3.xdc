############################################################
## Clock (100 MHz onboard clock)
############################################################

set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name clk -waveform {0 5} [get_ports clk]


# ------------------------ Reset (BTNC, active low) -------------------------

set_property PACKAGE_PIN U18 [get_ports n_rst]
set_property IOSTANDARD LVCMOS33 [get_ports n_rst]
set_property PULLUP true [get_ports n_rst]   ;# button pulls low when pressed



############################################################
## VGA Output Signals
############################################################

## Red
set_property PACKAGE_PIN G19 [get_ports {r[0]}]
set_property PACKAGE_PIN H19 [get_ports {r[1]}]
set_property PACKAGE_PIN J19 [get_ports {r[2]}]
set_property PACKAGE_PIN N19 [get_ports {r[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {r[*]}]

## Green
set_property PACKAGE_PIN J17 [get_ports {g[0]}]
set_property PACKAGE_PIN H17 [get_ports {g[1]}]
set_property PACKAGE_PIN G17 [get_ports {g[2]}]
set_property PACKAGE_PIN D17 [get_ports {g[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {g[*]}]

## Blue
set_property PACKAGE_PIN N18 [get_ports {b[0]}]
set_property PACKAGE_PIN L18 [get_ports {b[1]}]
set_property PACKAGE_PIN K18 [get_ports {b[2]}]
set_property PACKAGE_PIN J18 [get_ports {b[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {b[*]}]


############################################################
## Sync signals
############################################################

set_property PACKAGE_PIN P19 [get_ports hsync]
set_property IOSTANDARD LVCMOS33 [get_ports hsync]

set_property PACKAGE_PIN R19 [get_ports vsync]
set_property IOSTANDARD LVCMOS33 [get_ports vsync]