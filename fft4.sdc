###############################################################
# SDC File for 4-point FFT Design
# Author: Gaurav
# Date: 27-Oct-2025
###############################################################

# ---- Clock Definition ----
create_clock -name clk -period 10.0 [get_ports clk] ;# 100 MHz clock

# ---- Input and Output Delays ----
set_input_delay  2.0 -clock clk [all_inputs]
set_output_delay 2.0 -clock clk [all_outputs]

# ---- Drive Strengths ----
set_driving_cell -lib_cell INVX1 [all_inputs]
set_load 0.1 [all_outputs]

# ---- Reset and Control Signals ----
set_dont_touch_network [get_ports {reset rst_n aresetn}]

# ---- Optional: Multicycle Path ----
# Uncomment if FFT requires more cycles between input & output
# set_multicycle_path 2 -setup -from [get_ports in_data*] -to [get_ports out_data*]
# set_multicycle_path 1 -hold  -from [get_ports in_data*] -to [get_ports out_data*]

