# Create work library
vlib work

# Compile Verilog
#     All Verilog files that are part of this design should have
#     their own "vlog" line below.
vlog "./crop_plus_gaussian_testbench.sv"
vlog "./crop_plus_gaussian.v"
vlog "./crop_plus_fifo.v"
vlog "./crop_filter.v"
vlog "./fwft_fifo.v"
vlog "./fifo_sync.v"
vlog "./start_for_relu_array_ap_fixed_2u_array_ap_fixed_16_15_5_3_0_2u_ReLU_config4_U0.v"
vlog "./myproject_mux_325_16_1_1.v"
vlog "./start_for_relu_array_ap_fixed_10u_array_ap_fixed_16_15_5_3_0_10u_relu_config8mb6.v"
vlog "./fifo_w16_d1936_A.v"
vlog "./dense_array_ap_fixed_2u_array_ap_fixed_16_15_5_3_0_10u_config7_s.v"
vlog "./pooling2d_cl_array_ap_fixed_2u_array_ap_fixed_16_15_5_3_0_2u_config5_s.v"
vlog "./dense_wrapper_ap_fixed_16_15_5_3_0_ap_fixed_16_15_5_3_0_config9_s_outidx.v"
vlog "./dense_array_ap_fixed_10u_array_ap_fixed_16_15_5_3_0_5u_config9_s.v"
vlog "./dense_resource_ap_fixed_ap_fixed_16_15_5_3_0_config2_mult_s.v"
vlog "./dense_wrapper_ap_fixed_16_15_5_3_0_ap_fixed_16_15_5_3_0_config9_s.v"
vlog "./relu_array_ap_fixed_2u_array_ap_fixed_16_15_5_3_0_2u_ReLU_config4_s.v"
vlog "./dense_wrapper_ap_fixed_16_15_5_3_0_ap_fixed_16_15_5_3_0_config7_s.v"
vlog "./start_for_pooling2d_cl_array_ap_fixed_2u_array_ap_fixed_16_15_5_3_0_2u_configlbW.v"
vlog "./start_for_dense_array_ap_fixed_2u_array_ap_fixed_16_15_5_3_0_10u_config7_U0.v"
vlog "./fifo_w16_d121_A.v"
vlog "./shift_line_buffer_array_ap_fixed_16_15_5_3_0_1u_config2_s.v"
vlog "./pooling2d_cl_array_ap_fixed_2u_array_ap_fixed_16_15_5_3_0_2u_config5_s_line_bfYi.v"
vlog "./myproject_mux_104_16_1_1.v"
vlog "./compute_output_buffer_2d_array_array_ap_fixed_16_15_5_3_0_2u_config2_s.v"
vlog "./fifo_w16_d1_A.v"
vlog "./myproject_mux_53_16_1_1.v"
vlog "./myproject_mux_2568_16_1_1.v"
vlog "./start_for_dense_array_ap_fixed_10u_array_ap_fixed_16_15_5_3_0_5u_config9_U0.v"
vlog "./dense_wrapper_ap_fixed_16_15_5_3_0_ap_fixed_16_15_5_3_0_config7_s_w7_V.v"
vlog "./conv_2d_cl_array_ap_fixed_1u_array_ap_fixed_16_15_5_3_0_2u_config2_s.v"
vlog "./myproject_mux_164_16_1_1.v"
vlog "./relu_array_ap_fixed_10u_array_ap_fixed_16_15_5_3_0_10u_relu_config8_s.v"
vlog "./myproject.v"
vlog "./dense_wrapper_ap_fixed_16_15_5_3_0_ap_fixed_16_15_5_3_0_config9_s_w9_V.v"
vlog "./shift_line_buffer_array_ap_fixed_16_15_5_3_0_1u_config2_s_line_buffer_Array_Vbkb.v"
vlog "./dense_resource_ap_fixed_ap_fixed_16_15_5_3_0_config2_mult_s_w2_V.v"
vlog "./myproject_mul_mul_16s_16s_17_1_1.v"
# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
vsim -voptargs="+acc" -t 1ps -lib work crop_plus_gaussian_testbench

# Source the wave do file
#     This should be the file that sets up the signal window for
#     the module you are testing.
do crop_plus_gaussian_testbench_wave.do

# Set the window types
view wave
view structure
view signals

# Run the simulation
run -all

# End
