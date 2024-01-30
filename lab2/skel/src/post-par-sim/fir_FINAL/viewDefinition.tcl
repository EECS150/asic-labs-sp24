if {![namespace exists ::IMEX]} { namespace eval ::IMEX {} }
set ::IMEX::dataVar [file dirname [file normalize [info script]]]
set ::IMEX::libVar ${::IMEX::dataVar}/libs

create_library_set -name ss_100C_1v60.setup_set\
   -timing\
    [list ${::IMEX::libVar}/mmmc/sky130_fd_sc_hd__ss_100C_1v60.lib\
    ${::IMEX::libVar}/mmmc/sramgen_sram_32x32m2w8_replica_v1_tt_025C_1v80.lib\
    ${::IMEX::libVar}/mmmc/sramgen_sram_64x32m4w32_replica_v1_tt_025C_1v80.lib\
    ${::IMEX::libVar}/mmmc/sramgen_sram_512x32m4w8_replica_v1_tt_025C_1v80.lib\
    ${::IMEX::libVar}/mmmc/sramgen_sram_1024x32m8w8_replica_v1_tt_025C_1v80.lib\
    ${::IMEX::libVar}/mmmc/sramgen_sram_1024x32m8w32_replica_v1_tt_025C_1v80.lib\
    ${::IMEX::libVar}/mmmc/sramgen_sram_1024x64m8w32_replica_v1_tt_025C_1v80.lib\
    ${::IMEX::libVar}/mmmc/sramgen_sram_2048x32m8w8_replica_v1_tt_025C_1v80.lib\
    ${::IMEX::libVar}/mmmc/sramgen_sram_4096x8m8w8_replica_v1_tt_025C_1v80.lib\
    ${::IMEX::libVar}/mmmc/sramgen_sram_4096x32m8w8_replica_v1_tt_025C_1v80.lib]
create_library_set -name ff_n40C_1v95.hold_set\
   -timing\
    [list ${::IMEX::libVar}/mmmc/sky130_fd_sc_hd__ff_n40C_1v95_ccsnoise.lib\
    ${::IMEX::libVar}/mmmc/sramgen_sram_32x32m2w8_replica_v1_tt_025C_1v80.lib\
    ${::IMEX::libVar}/mmmc/sramgen_sram_64x32m4w32_replica_v1_tt_025C_1v80.lib\
    ${::IMEX::libVar}/mmmc/sramgen_sram_512x32m4w8_replica_v1_tt_025C_1v80.lib\
    ${::IMEX::libVar}/mmmc/sramgen_sram_1024x32m8w8_replica_v1_tt_025C_1v80.lib\
    ${::IMEX::libVar}/mmmc/sramgen_sram_1024x32m8w32_replica_v1_tt_025C_1v80.lib\
    ${::IMEX::libVar}/mmmc/sramgen_sram_1024x64m8w32_replica_v1_tt_025C_1v80.lib\
    ${::IMEX::libVar}/mmmc/sramgen_sram_2048x32m8w8_replica_v1_tt_025C_1v80.lib\
    ${::IMEX::libVar}/mmmc/sramgen_sram_4096x8m8w8_replica_v1_tt_025C_1v80.lib\
    ${::IMEX::libVar}/mmmc/sramgen_sram_4096x32m8w8_replica_v1_tt_025C_1v80.lib]
create_timing_condition -name ff_n40C_1v95.hold_cond\
   -library_sets [list ff_n40C_1v95.hold_set]
create_timing_condition -name ss_100C_1v60.setup_cond\
   -library_sets [list ss_100C_1v60.setup_set]
create_rc_corner -name ff_n40C_1v95.hold_rc\
   -pre_route_res 1\
   -post_route_res 1\
   -pre_route_cap 1\
   -post_route_cap 1\
   -post_route_cross_cap 1\
   -pre_route_clock_res 0\
   -pre_route_clock_cap 0\
   -temperature -40
create_rc_corner -name ss_100C_1v60.setup_rc\
   -pre_route_res 1\
   -post_route_res 1\
   -pre_route_cap 1\
   -post_route_cap 1\
   -post_route_cross_cap 1\
   -pre_route_clock_res 0\
   -pre_route_clock_cap 0\
   -temperature 100
create_delay_corner -name ss_100C_1v60.setup_delay\
   -timing_condition {ss_100C_1v60.setup_cond}\
   -rc_corner ss_100C_1v60.setup_rc
create_delay_corner -name ff_n40C_1v95.hold_delay\
   -timing_condition {ff_n40C_1v95.hold_cond}\
   -rc_corner ff_n40C_1v95.hold_rc
create_constraint_mode -name my_constraint_mode\
   -sdc_files\
    [list ${::IMEX::dataVar}/mmmc/modes/my_constraint_mode/my_constraint_mode.sdc]
create_analysis_view -name ss_100C_1v60.setup_view -constraint_mode my_constraint_mode -delay_corner ss_100C_1v60.setup_delay -latency_file ${::IMEX::dataVar}/mmmc/views/ss_100C_1v60.setup_view/latency.sdc
create_analysis_view -name ff_n40C_1v95.hold_view -constraint_mode my_constraint_mode -delay_corner ff_n40C_1v95.hold_delay -latency_file ${::IMEX::dataVar}/mmmc/views/ff_n40C_1v95.hold_view/latency.sdc
set_analysis_view -setup [list ss_100C_1v60.setup_view] -hold [list ff_n40C_1v95.hold_view]
