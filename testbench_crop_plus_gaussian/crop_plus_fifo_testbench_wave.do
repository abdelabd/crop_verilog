onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /crop_plus_fifo_testbench/reset
add wave -noupdate /crop_plus_fifo_testbench/clk
add wave -noupdate /crop_plus_fifo_testbench/idx_in
add wave -noupdate /crop_plus_fifo_testbench/idx_out
add wave -noupdate /crop_plus_fifo_testbench/last_idx_out
add wave -noupdate /crop_plus_fifo_testbench/img_input_mem
add wave -noupdate /crop_plus_fifo_testbench/output_mem
add wave -noupdate /crop_plus_fifo_testbench/output_benchmark_mem
add wave -noupdate -label dut::fifo::count /crop_plus_fifo_testbench/dut/fifo_sync_inst/count
add wave -noupdate -label dut::crop_filter::pass_filter /crop_plus_fifo_testbench/dut/crop_filter_inst/pass_filter
add wave -noupdate /crop_plus_fifo_testbench/run_counter
add wave -noupdate /crop_plus_fifo_testbench/cc_counter
add wave -noupdate /crop_plus_fifo_testbench/pixel_out_TVALID
add wave -noupdate /crop_plus_fifo_testbench/pixel_out_TREADY
add wave -noupdate /crop_plus_fifo_testbench/pixel_out_TDATA
add wave -noupdate /crop_plus_fifo_testbench/pixel_in_TVALID
add wave -noupdate /crop_plus_fifo_testbench/pixel_in_TREADY
add wave -noupdate /crop_plus_fifo_testbench/pixel_in_TDATA
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1228055000 ps} 0}
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
WaveRestoreZoom {2656831338 ps} {5626793088 ps}
