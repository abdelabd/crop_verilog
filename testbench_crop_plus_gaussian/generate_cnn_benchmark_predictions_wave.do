onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /generate_cnn_benchmark_predictions/ap_start
add wave -noupdate /generate_cnn_benchmark_predictions/ap_rst_n
add wave -noupdate /generate_cnn_benchmark_predictions/ap_ready
add wave -noupdate /generate_cnn_benchmark_predictions/ap_idle
add wave -noupdate /generate_cnn_benchmark_predictions/ap_done
add wave -noupdate /generate_cnn_benchmark_predictions/ap_clk
add wave -noupdate /generate_cnn_benchmark_predictions/input_mem
add wave -noupdate /generate_cnn_benchmark_predictions/output_mem
add wave -noupdate -label in_VALID /generate_cnn_benchmark_predictions/conv2d_1_input_V_data_0_V_TVALID
add wave -noupdate -label in_READY /generate_cnn_benchmark_predictions/conv2d_1_input_V_data_0_V_TREADY
add wave -noupdate -label in_DATA /generate_cnn_benchmark_predictions/conv2d_1_input_V_data_0_V_TDATA
add wave -noupdate -label out_4_VALID /generate_cnn_benchmark_predictions/layer9_out_V_data_4_V_TVALID
add wave -noupdate -label out_4_READY /generate_cnn_benchmark_predictions/layer9_out_V_data_4_V_TREADY
add wave -noupdate -label out_4_DATA /generate_cnn_benchmark_predictions/layer9_out_V_data_4_V_TDATA
add wave -noupdate -label out_3_VALID /generate_cnn_benchmark_predictions/layer9_out_V_data_3_V_TVALID
add wave -noupdate -label out_3_READY /generate_cnn_benchmark_predictions/layer9_out_V_data_3_V_TREADY
add wave -noupdate -label out_3_DATA /generate_cnn_benchmark_predictions/layer9_out_V_data_3_V_TDATA
add wave -noupdate -label out_2_VALID /generate_cnn_benchmark_predictions/layer9_out_V_data_2_V_TVALID
add wave -noupdate -label out_2_READY /generate_cnn_benchmark_predictions/layer9_out_V_data_2_V_TREADY
add wave -noupdate -label out_2_DATA /generate_cnn_benchmark_predictions/layer9_out_V_data_2_V_TDATA
add wave -noupdate -label out_1_VALID /generate_cnn_benchmark_predictions/layer9_out_V_data_1_V_TVALID
add wave -noupdate -label out_1_READY /generate_cnn_benchmark_predictions/layer9_out_V_data_1_V_TREADY
add wave -noupdate -label out_1_DATA /generate_cnn_benchmark_predictions/layer9_out_V_data_1_V_TDATA
add wave -noupdate -label out_0_VALID /generate_cnn_benchmark_predictions/layer9_out_V_data_0_V_TVALID
add wave -noupdate -label out_0_READY /generate_cnn_benchmark_predictions/layer9_out_V_data_0_V_TREADY
add wave -noupdate -label out_0_DATA /generate_cnn_benchmark_predictions/layer9_out_V_data_0_V_TDATA
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {244 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 276
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
WaveRestoreZoom {0 ps} {426 ps}
