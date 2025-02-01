onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /fwft_fifo_testbench/reset
add wave -noupdate /fwft_fifo_testbench/clk
add wave -noupdate /fwft_fifo_testbench/input_mem
add wave -noupdate /fwft_fifo_testbench/output_mem
add wave -noupdate /fwft_fifo_testbench/idx_in
add wave -noupdate /fwft_fifo_testbench/idx_out
add wave -noupdate /fwft_fifo_testbench/in_data
add wave -noupdate /fwft_fifo_testbench/out_data
add wave -noupdate /fwft_fifo_testbench/out_valid
add wave -noupdate /fwft_fifo_testbench/out_ready
add wave -noupdate /fwft_fifo_testbench/in_valid
add wave -noupdate /fwft_fifo_testbench/in_ready
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {9930375 ps} 0}
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
WaveRestoreZoom {0 ps} {43795500 ps}
