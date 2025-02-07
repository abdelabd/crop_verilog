onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /crop_filter_testbench/reset
add wave -noupdate /crop_filter_testbench/clk
add wave -noupdate /crop_filter_testbench/idx_in
add wave -noupdate /crop_filter_testbench/idx_out
add wave -noupdate /crop_filter_testbench/output_benchmark_mem
add wave -noupdate /crop_filter_testbench/img_input_mem
add wave -noupdate /crop_filter_testbench/crop_Y1_mem
add wave -noupdate /crop_filter_testbench/crop_X1_mem
add wave -noupdate /crop_filter_testbench/output_mem
add wave -noupdate /crop_filter_testbench/last_idx_out
add wave -noupdate -label dut::x /crop_filter_testbench/dut/x
add wave -noupdate -label dut::y /crop_filter_testbench/dut/y
add wave -noupdate -label dut::pass_filter /crop_filter_testbench/dut/pass_filter
add wave -noupdate /crop_filter_testbench/idx_in
add wave -noupdate /crop_filter_testbench/last_idx_in
add wave -noupdate /crop_filter_testbench/idx_out
add wave -noupdate /crop_filter_testbench/finished
add wave -noupdate /crop_filter_testbench/pixel_in_TVALID
add wave -noupdate /crop_filter_testbench/pixel_in_TREADY
add wave -noupdate /crop_filter_testbench/pixel_in_TDATA
add wave -noupdate /crop_filter_testbench/crop_Y1_TVALID
add wave -noupdate /crop_filter_testbench/crop_Y1_TREADY
add wave -noupdate /crop_filter_testbench/crop_Y1_TDATA
add wave -noupdate /crop_filter_testbench/crop_X1_TVALID
add wave -noupdate /crop_filter_testbench/crop_X1_TREADY
add wave -noupdate /crop_filter_testbench/crop_X1_TDATA
add wave -noupdate /crop_filter_testbench/pixel_out_TVALID
add wave -noupdate /crop_filter_testbench/pixel_out_TREADY
add wave -noupdate /crop_filter_testbench/pixel_out_TDATA
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {208850000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 50
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {21322916250 ps} {66332741250 ps}
