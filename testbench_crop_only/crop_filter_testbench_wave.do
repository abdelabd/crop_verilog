onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /crop_filter_testbench/reset
add wave -noupdate /crop_filter_testbench/clk
add wave -noupdate /crop_filter_testbench/idx_in
add wave -noupdate /crop_filter_testbench/idx_out
add wave -noupdate /crop_filter_testbench/input_mem
add wave -noupdate -expand /crop_filter_testbench/output_benchmark_mem
add wave -noupdate -expand /crop_filter_testbench/output_mem
add wave -noupdate /crop_filter_testbench/last_idx_out
add wave -noupdate /crop_filter_testbench/pixel_in
add wave -noupdate /crop_filter_testbench/pixel_out
add wave -noupdate /crop_filter_testbench/in_valid
add wave -noupdate /crop_filter_testbench/in_ready
add wave -noupdate /crop_filter_testbench/out_valid
add wave -noupdate /crop_filter_testbench/out_ready
add wave -noupdate -label dut::x /crop_filter_testbench/dut/x
add wave -noupdate -label dut::y /crop_filter_testbench/dut/y
add wave -noupdate -label dut::pass_filter /crop_filter_testbench/dut/pass_filter
add wave -noupdate -label dut::out_valid /crop_filter_testbench/dut/out_valid
add wave -noupdate /crop_filter_testbench/idx_in
add wave -noupdate /crop_filter_testbench/last_idx_in
add wave -noupdate /crop_filter_testbench/idx_out
add wave -noupdate /crop_filter_testbench/finished
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10088162 ps} 0}
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
WaveRestoreZoom {9024394 ps} {11075606 ps}
