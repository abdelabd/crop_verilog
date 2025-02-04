onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /myproject_small_testbench/ap_clk
add wave -noupdate /myproject_small_testbench/ap_rst_n
add wave -noupdate /myproject_small_testbench/ap_start
add wave -noupdate /myproject_small_testbench/ap_ready
add wave -noupdate /myproject_small_testbench/ap_idle
add wave -noupdate /myproject_small_testbench/ap_done
add wave -noupdate /myproject_small_testbench/input_mem
add wave -noupdate /myproject_small_testbench/output_mem
add wave -noupdate /myproject_small_testbench/img_idx
add wave -noupdate /myproject_small_testbench/cc_counter
add wave -noupdate /myproject_small_testbench/run_counter
add wave -noupdate -label in_VALID /myproject_small_testbench/conv2d_1_input_V_data_0_V_TVALID
add wave -noupdate -label in_READY /myproject_small_testbench/conv2d_1_input_V_data_0_V_TREADY
add wave -noupdate -label in_DATA /myproject_small_testbench/conv2d_1_input_V_data_0_V_TDATA
add wave -noupdate -label out_4_VALID /myproject_small_testbench/layer9_out_V_data_4_V_TVALID
add wave -noupdate -label out_4_READY /myproject_small_testbench/layer9_out_V_data_4_V_TREADY
add wave -noupdate -label out_4_DATA /myproject_small_testbench/layer9_out_V_data_4_V_TDATA
add wave -noupdate -label out_3_VALID /myproject_small_testbench/layer9_out_V_data_3_V_TVALID
add wave -noupdate -label out_3_READY /myproject_small_testbench/layer9_out_V_data_3_V_TREADY
add wave -noupdate -label out_3_DATA /myproject_small_testbench/layer9_out_V_data_3_V_TDATA
add wave -noupdate -label out_2_VALID /myproject_small_testbench/layer9_out_V_data_2_V_TVALID
add wave -noupdate -label out_2_READY /myproject_small_testbench/layer9_out_V_data_2_V_TREADY
add wave -noupdate -label out_2_DATA /myproject_small_testbench/layer9_out_V_data_2_V_TDATA
add wave -noupdate -label out_1_VALID /myproject_small_testbench/layer9_out_V_data_1_V_TVALID
add wave -noupdate -label out_1_READY /myproject_small_testbench/layer9_out_V_data_1_V_TREADY
add wave -noupdate -label out_1_DATA /myproject_small_testbench/layer9_out_V_data_1_V_TDATA
add wave -noupdate -label out_0_VALID /myproject_small_testbench/layer9_out_V_data_0_V_TVALID
add wave -noupdate -label out_0_READY /myproject_small_testbench/layer9_out_V_data_0_V_TREADY
add wave -noupdate -label out_0_DATA /myproject_small_testbench/layer9_out_V_data_0_V_TDATA
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {55415000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 227
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
WaveRestoreZoom {0 ps} {136715250 ps}
