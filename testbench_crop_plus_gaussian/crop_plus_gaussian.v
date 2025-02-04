module crop_plus_gaussian #( // Has all the same inputs and outputs as myproject.v
    parameter PIXEL_BIT_WIDTH = 12,
    parameter IN_ROWS = 40,
    parameter IN_COLS = 40,
    parameter OUT_ROWS = 20,
    parameter OUT_COLS = 20,
    parameter Y_1 = 10,
    parameter X_1 = 10)
    (
        crop_input_TDATA,
        cnn_output_0_TDATA,
        cnn_output_1_TDATA,
        cnn_output_2_TDATA,
        cnn_output_3_TDATA,
        cnn_output_4_TDATA,
        ap_clk,
        ap_rst_n,
        crop_input_TVALID,
        crop_input_TREADY,
        ap_start,
        cnn_output_0_TVALID,
        cnn_output_0_TREADY,
        cnn_output_1_TVALID,
        cnn_output_1_TREADY,
        cnn_output_2_TVALID,
        cnn_output_2_TREADY,
        cnn_output_3_TVALID,
        cnn_output_3_TREADY,
        cnn_output_4_TVALID,
        cnn_output_4_TREADY,
        ap_done,
        ap_ready,
        ap_idle
    );

    // I/O
    input wire [PIXEL_BIT_WIDTH - 1:0] crop_input_TDATA;
    output wire [PIXEL_BIT_WIDTH - 1:0] cnn_output_0_TDATA;
    output wire [PIXEL_BIT_WIDTH - 1:0] cnn_output_1_TDATA;
    output wire [PIXEL_BIT_WIDTH - 1:0] cnn_output_2_TDATA;
    output wire [PIXEL_BIT_WIDTH - 1:0] cnn_output_3_TDATA;
    output wire [PIXEL_BIT_WIDTH - 1:0] cnn_output_4_TDATA;
    input wire ap_clk;
    input wire ap_rst_n;
    input wire crop_input_TVALID;
    output wire crop_input_TREADY;
    input wire ap_start;
    output wire cnn_output_0_TVALID;
    input wire cnn_output_0_TREADY;
    output wire cnn_output_1_TVALID;
    input wire cnn_output_1_TREADY;
    output wire cnn_output_2_TVALID;
    input wire cnn_output_2_TREADY;
    output wire cnn_output_3_TVALID;
    input wire cnn_output_3_TREADY;
    output wire cnn_output_4_TVALID;
    input wire cnn_output_4_TREADY;
    output wire ap_done;
    output wire ap_ready;
    output wire ap_idle;

    // Intermediate: crop <==> CNN
    wire [PIXEL_BIT_WIDTH - 1:0] crop_output_TDATA;
    wire crop_output_TVALID;
    wire cnn_input_TREADY;


    // First, wire up the crop_plus_fifo
    crop_plus_fifo #(
        .PIXEL_BIT_WIDTH(PIXEL_BIT_WIDTH),
        .IN_ROWS(IN_ROWS),
        .IN_COLS(IN_COLS),
        .OUT_ROWS(OUT_ROWS),
        .OUT_COLS(OUT_COLS),
        .Y_1(Y_1),
        .X_1(X_1)
    ) crop_plus_fifo_inst (
        .clk       (ap_clk),
        .reset     (~ap_rst_n),
        .pixel_in  (crop_input_TDATA),
        .pixel_out (crop_output_TDATA),
        .in_ready  (crop_input_TREADY),
        .in_valid  (crop_input_TVALID),
        .out_ready (cnn_input_TREADY),
        .out_valid (crop_output_TVALID)
    );


    myproject_small myproject_small_inst (
		  .conv2d_1_input_V_data_0_V_TDATA(crop_output_TDATA),
          .layer9_out_V_data_0_V_TDATA(cnn_output_0_TDATA),
		  .layer9_out_V_data_1_V_TDATA(cnn_output_1_TDATA),
		  .layer9_out_V_data_2_V_TDATA(cnn_output_2_TDATA),
		  .layer9_out_V_data_3_V_TDATA(cnn_output_3_TDATA),
		  .layer9_out_V_data_4_V_TDATA(cnn_output_4_TDATA),
        .ap_clk(ap_clk),
        .ap_rst_n(ap_rst_n),

        .conv2d_1_input_V_data_0_V_TVALID(crop_output_TVALID),
        .conv2d_1_input_V_data_0_V_TREADY(cnn_input_TREADY),
		  
        .layer9_out_V_data_0_V_TVALID(cnn_output_0_TVALID),
        .layer9_out_V_data_0_V_TREADY(cnn_output_0_TREADY),
		  
		  .layer9_out_V_data_1_V_TVALID(cnn_output_1_TVALID),
        .layer9_out_V_data_1_V_TREADY(cnn_output_1_TREADY),
		
		  .layer9_out_V_data_2_V_TVALID(cnn_output_2_TVALID),
        .layer9_out_V_data_2_V_TREADY(cnn_output_2_TREADY),
		  
		  .layer9_out_V_data_3_V_TVALID(cnn_output_3_TVALID),
        .layer9_out_V_data_3_V_TREADY(cnn_output_3_TREADY),
		  
		  .layer9_out_V_data_4_V_TVALID(cnn_output_4_TVALID),
        .layer9_out_V_data_4_V_TREADY(cnn_output_4_TREADY),
		  
        .ap_start(ap_start),
        .ap_done(ap_done),
        .ap_ready(ap_ready),
        .ap_idle(ap_idle)
	);
	








endmodule