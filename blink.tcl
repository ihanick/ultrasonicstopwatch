# Copyright (C) 1991-2013 Altera Corporation
# Your use of Altera Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License 
# Subscription Agreement, Altera MegaCore Function License 
# Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the 
# applicable agreement for further details.

# Quartus II 32-bit Version 13.0.1 Build 232 06/12/2013 Service Pack 1 SJ Web Edition
# File: blink.tcl
# Generated on: Fri Nov 27 10:08:36 2015

package require ::quartus::project

set_location_assignment PIN_12 -to clk
set_location_assignment PIN_1 -to clk_out
set_instance_assignment -name RESERVE_PIN AS_OUTPUT_DRIVING_AN_UNSPECIFIED_SIGNAL -to clk_out
set_instance_assignment -name RESERVE_PIN AS_INPUT_TRI_STATED -to clk