#!/bin/bash
#
# This script organizes the 4-bit-FFT-processor project directory by
# creating a clean folder structure and moving files into it.
#
# It is based on the 'tree' output provided.
#
# We use 'set -e' to stop the script if any command fails.
set -e

# --- SAFETY CHECK ---
echo "This script will organize your project files into these folders:"
echo "  - rtl/"
echo "  - tb/"
echo "  - scripts/"
echo "  - results/"
echo "  - reports/"
echo "  - tool_work/"
echo ""
echo "It will MOVE files from the root directory into these new folders."
echo "Current directory: $(pwd)"
echo ""
read -p "Are you sure you want to continue? (y/n) " -n 1 -r
echo    # move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Exiting without making any changes."
    exit 1
fi
# --- END SAFETY CHECK ---

echo ""
echo "Step 1: Creating new directory structure..."
mkdir -p rtl
mkdir -p tb
mkdir -p scripts
mkdir -p results
mkdir -p reports
mkdir -p tool_work

echo ""
echo "Step 2: Moving files..."

# --- RTL Source ---
echo "Moving RTL..."
mv -v fft4.v rtl/fft_4pt.v
mv -v fft2_4pt.v rtl/

# --- Testbench ---
echo "Moving Testbench..."
mv -v fft4_tb.v tb/tb_fft_4pt.v

# --- Scripts & Constraints ---
echo "Moving Scripts..."
mv -v fft4_genus.tcl scripts/synth.tcl
mv -v fft4.sdc scripts/constraints.sdc

# --- Final Results ---
echo "Moving Final Results..."
mv -v fft_4pt.gds results/
mv -v fft_4pt_netlist.v results/

# --- Reports ---
# We rename the existing 'reports' dir to 'syn_reports'
# and 'timingReports' to 'pnr_reports' inside the new 'reports' dir.
echo "Moving Reports..."
mv -v reports reports_syn_temp
mv -v reports_syn_temp reports/syn_reports
mv -v timingReports reports/pnr_reports
mv -v pvsUI_ipvs.log reports/

# --- Tool Work & Intermediate Files ---
echo "Moving Tool Work directories and files..."
mv -v fft_4pt.enc tool_work/
mv -v fft_4pt.enc.dat tool_work/
mv -v fft_4pt.gds.dat tool_work/
mv -v fv tool_work/
mv -v Default.globals tool_work/
mv -v fft4.globals tool_work/
mv -v fft_4pt_output.sdc tool_work/
mv -v fft4.view tool_work/
mv -v ft4.view tool_work/
mv -v streamOut.map tool_work/

# Move empty directories (if they exist)
if [ -d "netlist" ]; then
    mv -v netlist tool_work/
fi
if [ -d "outputs" ]; then
    mv -v outputs tool_work/
fi

echo ""
echo "✅ Organization complete!"
echo "The root directory is clean. You can now 'git add .' and commit."
echo "Don't forget to update your new 'README.md' file."