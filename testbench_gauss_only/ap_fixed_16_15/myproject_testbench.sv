`timescale 1 ns / 1 ps 

module myproject_testbench();

    localparam FP_TOTAL = 16;
    localparam FP_FRAC = 0; // adjust if needed
    localparam FP_INT = FP_TOTAL - FP_FRAC - 1;

    localparam IN_ROWS         = 100;
    localparam IN_COLS         = 160;
    localparam OUT_ROWS        = 48;
    localparam OUT_COLS        = 48;
    localparam Y_1             = 10;
    localparam X_1             = 10;
    localparam NUM_CROPS = 1; // how many “crops”/frames you want to process

	// Parameters for the HLS module
	reg ap_clk; //input
	reg ap_rst_n; //input
	reg ap_start; //input
	wire ap_done; //output
	wire ap_idle; //output
	wire ap_ready; //output

	// Image data input to the HLS module
	logic [FP_TOTAL-1:0] conv2d_input_V_data_0_V_TDATA; //input
	logic conv2d_input_V_data_0_V_TVALID; //input: data valid to be sent
    wire conv2d_input_V_data_0_V_TREADY; //output: myproject ready to receive data
		  
	// output[0]
	wire [FP_TOTAL-1:0] layer15_out_V_data_0_V_TDATA; //output
	wire layer15_out_V_data_0_V_TVALID; // output: myproject output valid to be sent
    reg layer15_out_V_data_0_V_TREADY; //input: receiver ready to receive myproject output
	 
	// output[1]
	wire [FP_TOTAL-1:0] layer15_out_V_data_1_V_TDATA; //output
	wire layer15_out_V_data_1_V_TVALID; // output: myproject output valid to be sent
    reg layer15_out_V_data_1_V_TREADY; //input: receiver ready to receive myproject output
	
	// output[2]
	wire [FP_TOTAL-1:0] layer15_out_V_data_2_V_TDATA; //output
	wire layer15_out_V_data_2_V_TVALID; // output: myproject output valid to be sent
    reg layer15_out_V_data_2_V_TREADY; //input: receiver ready to receive myproject output
	
	// output[3]
	wire [FP_TOTAL-1:0] layer15_out_V_data_3_V_TDATA; //output
	wire layer15_out_V_data_3_V_TVALID; // output: myproject output valid to be sent
    reg layer15_out_V_data_3_V_TREADY; //input: receiver ready to receive myproject output
	
	// output[4]
	wire [FP_TOTAL-1:0] layer15_out_V_data_4_V_TDATA; //output
	wire layer15_out_V_data_4_V_TVALID; // output: myproject output valid to be sent
    reg layer15_out_V_data_4_V_TREADY; //input: receiver ready to receive myproject output

	// Instantiate the HLS module (Replace 'hls_module' with actual module name)
	myproject dut (
		  .conv2d_input_V_data_0_V_TDATA(conv2d_input_V_data_0_V_TDATA),
          .layer15_out_V_data_0_V_TDATA(layer15_out_V_data_0_V_TDATA),
		  .layer15_out_V_data_1_V_TDATA(layer15_out_V_data_1_V_TDATA),
		  .layer15_out_V_data_2_V_TDATA(layer15_out_V_data_2_V_TDATA),
		  .layer15_out_V_data_3_V_TDATA(layer15_out_V_data_3_V_TDATA),
		  .layer15_out_V_data_4_V_TDATA(layer15_out_V_data_4_V_TDATA),
        .ap_clk(ap_clk),
        .ap_rst_n(ap_rst_n),
        .conv2d_input_V_data_0_V_TVALID(conv2d_input_V_data_0_V_TVALID),
        .conv2d_input_V_data_0_V_TREADY(conv2d_input_V_data_0_V_TREADY),
		  
        .layer15_out_V_data_0_V_TVALID(layer15_out_V_data_0_V_TVALID),
        .layer15_out_V_data_0_V_TREADY(layer15_out_V_data_0_V_TREADY),
		  
		  .layer15_out_V_data_1_V_TVALID(layer15_out_V_data_1_V_TVALID),
        .layer15_out_V_data_1_V_TREADY(layer15_out_V_data_1_V_TREADY),
		
		  .layer15_out_V_data_2_V_TVALID(layer15_out_V_data_2_V_TVALID),
        .layer15_out_V_data_2_V_TREADY(layer15_out_V_data_2_V_TREADY),
		  
		  .layer15_out_V_data_3_V_TVALID(layer15_out_V_data_3_V_TVALID),
        .layer15_out_V_data_3_V_TREADY(layer15_out_V_data_3_V_TREADY),
		  
		  .layer15_out_V_data_4_V_TVALID(layer15_out_V_data_4_V_TVALID),
        .layer15_out_V_data_4_V_TREADY(layer15_out_V_data_4_V_TREADY),
		  
        .ap_start(ap_start),
        .ap_done(ap_done),
        .ap_ready(ap_ready),
        .ap_idle(ap_idle)
	);
	

	// Clock generation
	parameter CLOCK_PERIOD = 10;
	initial begin
		 ap_clk = 0;
		 forever #(CLOCK_PERIOD/2) ap_clk = ~ap_clk; // 100MHz clock
	end

	// Image data array
	reg [FP_TOTAL-1:0] input_mem [OUT_ROWS*OUT_COLS-1:0];
    reg [FP_TOTAL-1:0] output_mem [4:0];
	integer img_idx;
	integer i;
//
//	// File handling
	integer input_file;
	integer input_read_file;
	integer output_file;

	// Sequentially read in image data
	always_ff @(posedge ap_clk) begin
		if (~ap_rst_n) begin
			img_idx <= 0;
		end	
		else if (conv2d_input_V_data_0_V_TVALID & conv2d_input_V_data_0_V_TREADY) begin
			img_idx <= img_idx + 1;
			conv2d_input_V_data_0_V_TDATA <= input_mem[img_idx];
			$fwrite(input_read_file, "%b\n", conv2d_input_V_data_0_V_TDATA);
		end	
	end
	
	// Sequentially read out output data
	always_ff @(posedge ap_clk) begin
		if (layer15_out_V_data_0_V_TVALID & layer15_out_V_data_0_V_TREADY) begin
			$fwrite(output_file, "%b\n", layer15_out_V_data_0_V_TDATA);
		end
	
		if (layer15_out_V_data_1_V_TVALID & layer15_out_V_data_1_V_TREADY) begin
			$fwrite(output_file, "%b\n", layer15_out_V_data_1_V_TDATA);
		end
		
		if (layer15_out_V_data_2_V_TVALID & layer15_out_V_data_2_V_TREADY) begin
			$fwrite(output_file, "%b\n", layer15_out_V_data_2_V_TDATA);
		end
		
		if (layer15_out_V_data_3_V_TVALID & layer15_out_V_data_3_V_TREADY) begin
			$fwrite(output_file, "%b\n", layer15_out_V_data_3_V_TDATA);
		end
		
		if (layer15_out_V_data_4_V_TVALID & layer15_out_V_data_4_V_TREADY) begin
			$fwrite(output_file, "%b\n", layer15_out_V_data_4_V_TDATA);
		end
	end
	
	// randomize the input-valid signal
	always_ff @(posedge ap_clk) begin
		conv2d_input_V_data_0_V_TVALID <= $urandom%2;
	end

	// randomize the output-ready signal
	always_ff @(posedge ap_clk) begin
		layer15_out_V_data_0_V_TREADY <= $urandom%2;
		layer15_out_V_data_1_V_TREADY <= $urandom%2;
		layer15_out_V_data_2_V_TREADY <= $urandom%2;
		layer15_out_V_data_3_V_TREADY <= $urandom%2;
		layer15_out_V_data_4_V_TREADY <= $urandom%2;
	end
	
	// Run through the signal protocol to read in the data
	initial begin
	
		 // Turn on reset, turn off start
		ap_rst_n = 0; // active low
		ap_start = 0;
		
		// Turn on input-valid, output-ready 
//		conv2d_input_V_data_0_V_TVALID = 1;
//		layer15_out_V_data_0_V_TREADY = 1;
//		layer15_out_V_data_1_V_TREADY = 1;
//		layer15_out_V_data_2_V_TREADY = 1;
//		layer15_out_V_data_3_V_TREADY = 1;
//		layer15_out_V_data_4_V_TREADY = 1;

		 // Turn off reset
		 #20;
		 ap_rst_n = 1;

		 // Load image data from binary file
		 $readmemb($sformatf("tb_data/img_postcrop_INDEX_%0dx%0d_to_%0dx%0dx%0d.bin",
            IN_ROWS, IN_COLS,
            OUT_ROWS, OUT_COLS,
            NUM_CROPS), input_mem);
		
		 // Open the files to which we want to write
		 input_read_file = $fopen("tb_data/img_postcrop_INDEX_READIN_100x160_to_48x48x1.bin", "wb");
		 if (input_read_file == 0) begin
			  $display("Error: Could not open input-read file for writing.");
			  $stop;
		 end
		 else begin
			  $display("Could indeed open input-read file for writing.");
		 end
		 
		 output_file = $fopen("tb_data/vout_postcrop_INDEX_100x160_to_48x48x1.bin", "wb");
		 if (output_file == 0) begin
			  $display("Error: Could not open output file for writing.");
			  $stop;
		 end
		 else begin
			  $display("Could indeed open output file for writing.");
		 end

		 // Start the HLS module
		 #10;
		 ap_start = 1;
		 #10;
		 ap_start = 0;
		 


//		
//		 // Close the output file
//		 $fclose(output_file);
//
//		 // End simulation
//		 #20;
        wait(ap_done);
		#(1000*CLOCK_PERIOD);
		 //#800000;


		$display("input_file location = %0d", $sformatf("tb_data/ap_fixed_%0d_%0d/img_postcrop_INDEX_%0dx%0d_to_%0dx%0dx%0d.bin",
            FP_TOTAL,
            FP_INT,
            IN_ROWS, IN_COLS,
            OUT_ROWS, OUT_COLS,
            NUM_CROPS));
        
         $display("output_file location = %0d", $sformatf("tb_data/ap_fixed_%0d_%0d/vout_INDEX_%0dx%0d_to_%0dx%0dx%0d.bin",
            FP_TOTAL,
            FP_INT,
            IN_ROWS, IN_COLS,
            OUT_ROWS, OUT_COLS,
            NUM_CROPS));


		 $stop;
	end

endmodule