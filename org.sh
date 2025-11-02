# 1. Create a proper 'reports' directory
mkdir -p reports

# 2. Move the synthesis and P&R reports into it
mv -v reports_syn_temp reports/synthesis
mv -v timingReports reports/pnr

# 3. Move the netlist into 'results' where it belongs
mv -v netlist/fft_4pt_netlist.v results/
rmdir netlist

# 4. Move ALL remaining clutter into 'tool_work'
mv -v Default.globals fft4.globals fft_4pt.enc fft_4pt.enc.dat \
    fft_4pt.gds.dat fft_4pt_output.sdc fft4.view ft4.view streamOut.map \
    outputs rtl/fv tool_work/

echo "✅ Final cleanup complete. Your repository is now organized."