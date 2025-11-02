if {![namespace exists ::IMEX]} { namespace eval ::IMEX {} }
set ::IMEX::dataVar [file dirname [file normalize [info script]]]
set ::IMEX::libVar ${::IMEX::dataVar}/libs

create_library_set -name fast\
   -timing\
    [list ${::IMEX::libVar}/mmmc/fast.lib]
create_library_set -name slow_lib_set\
   -timing\
    [list ${::IMEX::libVar}/mmmc/slow.lib]
create_library_set -name slow\
   -timing\
    [list ${::IMEX::libVar}/mmmc/slow.lib]
create_library_set -name fast_lib_set\
   -timing\
    [list ${::IMEX::libVar}/mmmc/fast.lib]
create_rc_corner -name rc\
   -preRoute_res 1\
   -postRoute_res 1\
   -preRoute_cap 1\
   -postRoute_cap 1\
   -postRoute_xcap 1\
   -preRoute_clkres 0\
   -preRoute_clkcap 0\
   -qx_tech_file ${::IMEX::libVar}/mmmc/rc/gpdk090_9l.tch
create_rc_corner -name default_rc_corner\
   -preRoute_res 1\
   -postRoute_res 1\
   -preRoute_cap 1\
   -postRoute_cap 1\
   -postRoute_xcap 1\
   -preRoute_clkres 0\
   -preRoute_clkcap 0
create_delay_corner -name min\
   -library_set fast\
   -rc_corner rc
create_delay_corner -name slow_corner\
   -library_set slow_lib_set
create_delay_corner -name max\
   -library_set slow\
   -rc_corner rc
create_delay_corner -name fast_corner\
   -library_set fast_lib_set
create_constraint_mode -name outputfft\
   -sdc_files\
    [list ${::IMEX::libVar}/mmmc/fft4.sdc]
create_constraint_mode -name func_mode\
   -sdc_files\
    [list /dev/null]
create_analysis_view -name setup_view -constraint_mode func_mode -delay_corner slow_corner
create_analysis_view -name hold_view -constraint_mode func_mode -delay_corner fast_corner
set_analysis_view -setup [list setup_view] -hold [list hold_view]
