###############################################################
# Cadence Genus Synthesis Script for 4-Point FFT
# Based on user-provided reference script
###############################################################

# -------------------------------------------------------------
# Library setup
# (!!! TODO: UPDATE THESE TWO LINES !!!)
# -------------------------------------------------------------
set_db init_lib_search_path {/home/install/FOUNDRY/digital/90nm/dig/lib/}
set_db library slow.lib


# -------------------------------------------------------------
# Read and elaborate the design
# -------------------------------------------------------------
# Read RTL source file
read_hdl {./fft4.v}

# Elaborate top-level module
elaborate fft_4pt

# -------------------------------------------------------------
# Timing Constraints (SDC)
# (!!! TODO: Customize your clock period and I/O delays !!!)
# -------------------------------------------------------------
puts "--- Applying Constraints ---"

# Clock definition (e.g., 10ns = 100MHz)
set CLK_PORT "clk"
set CLK_PERIOD 10.0
create_clock -name $CLK_PORT -period $CLK_PERIOD [get_ports $CLK_PORT]

# Clock uncertainty and latency
set_clock_uncertainty [expr $CLK_PERIOD * 0.05] [all_clocks]
set_clock_latency -source 0.5 [all_clocks]

# Input/Output Delays (Assume 40% of clock period)
set IO_DELAY [expr $CLK_PERIOD * 0.4]
set all_inputs_except_clk [remove_from_collection [all_inputs] [get_ports "$CLK_PORT rst_n"]]

set_input_delay $IO_DELAY -clock $CLK_PORT $all_inputs_except_clk
set_output_delay $IO_DELAY -clock $CLK_PORT [all_outputs]

# Set drive/load (Example values - update with your library's cells)
# set_driving_cell -lib_cell INVX2 $all_inputs_except_clk
# set_load [expr 4 * [get_db [get_lib_cells DFFX1] .pin_load "D"]] [all_outputs]

# Set reset to be ideal (not part of the timing path)
set_ideal_network [get_ports rst_n]


# -------------------------------------------------------------
# Synthesis effort settings
# -------------------------------------------------------------
set_db syn_generic_effort medium
set_db syn_map_effort medium
set_db syn_opt_effort medium

# -------------------------------------------------------------
# Run synthesis flow
# -------------------------------------------------------------
puts "--- Running Synthesis (Generic -> Map -> Opt) ---"
syn_generic
syn_map
syn_opt

# -------------------------------------------------------------
# Write out the synthesized results
# -------------------------------------------------------------
puts "--- Writing Outputs ---"
file mkdir ./outputs
write_hdl > ./outputs/fft_4pt_netlist.v
write_sdc > ./outputs/fft_4pt_output.sdc

# -------------------------------------------------------------
# Generate reports
# -------------------------------------------------------------
puts "--- Generating Reports ---"
file mkdir ./reports
report timing > ./reports/fft_4pt_timing.rpt
report power  > ./reports/fft_4pt_power.rpt
report area   > ./reports/fft_4pt_area.rpt

puts "--- Synthesis Complete ---"

# -------------------------------------------------------------
# Optional: Launch GUI for post-synthesis analysis
# -------------------------------------------------------------
gui_show
