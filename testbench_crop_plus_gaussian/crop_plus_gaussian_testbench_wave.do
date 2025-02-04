onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /crop_plus_gaussian_testbench/ap_clk
add wave -noupdate /crop_plus_gaussian_testbench/ap_rst_n
add wave -noupdate /crop_plus_gaussian_testbench/ap_start
add wave -noupdate /crop_plus_gaussian_testbench/ap_ready
add wave -noupdate /crop_plus_gaussian_testbench/ap_idle
add wave -noupdate /crop_plus_gaussian_testbench/ap_done
add wave -noupdate /crop_plus_gaussian_testbench/input_mem
add wave -noupdate /crop_plus_gaussian_testbench/output_mem
add wave -noupdate /crop_plus_gaussian_testbench/crop_input_TVALID
add wave -noupdate /crop_plus_gaussian_testbench/crop_input_TREADY
add wave -noupdate /crop_plus_gaussian_testbench/crop_input_TDATA
add wave -noupdate /crop_plus_gaussian_testbench/cnn_output_4_TVALID
add wave -noupdate /crop_plus_gaussian_testbench/cnn_output_4_TREADY
add wave -noupdate /crop_plus_gaussian_testbench/cnn_output_4_TDATA
add wave -noupdate /crop_plus_gaussian_testbench/cnn_output_3_TVALID
add wave -noupdate /crop_plus_gaussian_testbench/cnn_output_3_TREADY
add wave -noupdate /crop_plus_gaussian_testbench/cnn_output_3_TDATA
add wave -noupdate /crop_plus_gaussian_testbench/cnn_output_2_TVALID
add wave -noupdate /crop_plus_gaussian_testbench/cnn_output_2_TREADY
add wave -noupdate /crop_plus_gaussian_testbench/cnn_output_2_TDATA
add wave -noupdate /crop_plus_gaussian_testbench/cnn_output_1_TVALID
add wave -noupdate /crop_plus_gaussian_testbench/cnn_output_1_TREADY
add wave -noupdate /crop_plus_gaussian_testbench/cnn_output_1_TDATA
add wave -noupdate /crop_plus_gaussian_testbench/cnn_output_0_TVALID
add wave -noupdate /crop_plus_gaussian_testbench/cnn_output_0_TREADY
add wave -noupdate /crop_plus_gaussian_testbench/cnn_output_0_TDATA
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
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
WaveRestoreZoom {0 ps} {1 ns}
