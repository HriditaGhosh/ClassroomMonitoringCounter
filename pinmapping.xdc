## ================= CLOCK =================
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk -waveform {0 5} [get_ports clk]

## ================= RESET =================
set_property PACKAGE_PIN U18 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

## ================= IR SENSOR (PMOD JA) =================
## JA Pin 1 = S1 (Outer Sensor)
set_property PACKAGE_PIN J1 [get_ports s1_raw]
set_property IOSTANDARD LVCMOS33 [get_ports s1_raw]

## JA Pin 2 = S2 (Inner Sensor)
set_property PACKAGE_PIN L2 [get_ports s2_raw]
set_property IOSTANDARD LVCMOS33 [get_ports s2_raw]

## ================= BUZZER (PMOD JA Pin 3) =================
set_property PACKAGE_PIN J2 [get_ports buzzer]
set_property IOSTANDARD LVCMOS33 [get_ports buzzer]

## ================= MODE SWITCH =================
set_property PACKAGE_PIN V17 [get_ports mode]
set_property IOSTANDARD LVCMOS33 [get_ports mode]

set_property PACKAGE_PIN V16 [get_ports manual_light]
set_property IOSTANDARD LVCMOS33 [get_ports manual_light]

## ================= LED OUTPUTS =================
set_property PACKAGE_PIN U16 [get_ports red]
set_property IOSTANDARD LVCMOS33 [get_ports red]

set_property PACKAGE_PIN E19 [get_ports yellow]
set_property IOSTANDARD LVCMOS33 [get_ports yellow]

set_property PACKAGE_PIN U19 [get_ports green]
set_property IOSTANDARD LVCMOS33 [get_ports green]

set_property PACKAGE_PIN V19 [get_ports light]
set_property IOSTANDARD LVCMOS33 [get_ports light]

## ================= 7-SEG ANODES =================
set_property PACKAGE_PIN U2 [get_ports {an[0]}]
set_property PACKAGE_PIN U4 [get_ports {an[1]}]
set_property PACKAGE_PIN V4 [get_ports {an[2]}]
set_property PACKAGE_PIN W4 [get_ports {an[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[*]}]

## ================= 7-SEG SEGMENTS =================
set_property PACKAGE_PIN W7 [get_ports {seg[0]}]
set_property PACKAGE_PIN W6 [get_ports {seg[1]}]
set_property PACKAGE_PIN U8 [get_ports {seg[2]}]
set_property PACKAGE_PIN V8 [get_ports {seg[3]}]
set_property PACKAGE_PIN U5 [get_ports {seg[4]}]
set_property PACKAGE_PIN V5 [get_ports {seg[5]}]
set_property PACKAGE_PIN U7 [get_ports {seg[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[*]}]

