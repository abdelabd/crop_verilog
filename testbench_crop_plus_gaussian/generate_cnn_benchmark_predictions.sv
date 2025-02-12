`timescale 1 ns / 1 ps 

module generate_cnn_benchmark_predictions();

    //////////////////////// User parameters ////////////////////////
    localparam FP_TOTAL 		= 16;
    localparam FP_FRAC 			= 0;
    localparam FP_INT 			= FP_TOTAL - FP_FRAC - 1;

    localparam IN_ROWS         	= 100;
    localparam IN_COLS         	= 160;
    localparam OUT_ROWS        	= 48;
    localparam OUT_COLS        	= 48;
    localparam IMG_COL_BITWIDTH = 10;
    localparam IMG_ROW_BITWIDTH = 10;
    localparam NUM_CROPS       	= 1; 
	int Y1_range[3] 			= '{0, 37, 52};
	int X1_range[3] 			= '{0, 59, 112};

	//////////////////////// DUT signals ////////////////////////
	reg ap_clk; //input
	reg ap_rst_n; //input
	reg ap_start; //input
	wire ap_done; //output
	wire ap_idle; //output
	wire ap_ready; //output

	// Image data input to the HLS module
	logic [FP_TOTAL-1:0] conv2d_1_input_V_data_0_V_TDATA; //input
	logic conv2d_1_input_V_data_0_V_TVALID; //input: data valid to be sent
    wire conv2d_1_input_V_data_0_V_TREADY; //output: myproject ready to receive data
		  
	// output[0]
	wire [FP_TOTAL-1:0] layer9_out_V_data_0_V_TDATA; //output
	wire layer9_out_V_data_0_V_TVALID; // output: myproject output valid to be sent
    reg layer9_out_V_data_0_V_TREADY; //input: receiver ready to receive myproject output
	 
	// output[1]
	wire [FP_TOTAL-1:0] layer9_out_V_data_1_V_TDATA; //output
	wire layer9_out_V_data_1_V_TVALID; // output: myproject output valid to be sent
    reg layer9_out_V_data_1_V_TREADY; //input: receiver ready to receive myproject output
	
	// output[2]
	wire [FP_TOTAL-1:0] layer9_out_V_data_2_V_TDATA; //output
	wire layer9_out_V_data_2_V_TVALID; // output: myproject output valid to be sent
    reg layer9_out_V_data_2_V_TREADY; //input: receiver ready to receive myproject output
	
	// output[3]
	wire [FP_TOTAL-1:0] layer9_out_V_data_3_V_TDATA; //output
	wire layer9_out_V_data_3_V_TVALID; // output: myproject output valid to be sent
    reg layer9_out_V_data_3_V_TREADY; //input: receiver ready to receive myproject output
	
	// output[4]
	wire [FP_TOTAL-1:0] layer9_out_V_data_4_V_TDATA; //output
	wire layer9_out_V_data_4_V_TVALID; // output: myproject output valid to be sent
    reg layer9_out_V_data_4_V_TREADY; //input: receiver ready to receive myproject output

	//////////////////////// DUT module ////////////////////////
	myproject dut (
		  .conv2d_1_input_V_data_0_V_TDATA(conv2d_1_input_V_data_0_V_TDATA),
          .layer9_out_V_data_0_V_TDATA(layer9_out_V_data_0_V_TDATA),
		  .layer9_out_V_data_1_V_TDATA(layer9_out_V_data_1_V_TDATA),
		  .layer9_out_V_data_2_V_TDATA(layer9_out_V_data_2_V_TDATA),
		  .layer9_out_V_data_3_V_TDATA(layer9_out_V_data_3_V_TDATA),
		  .layer9_out_V_data_4_V_TDATA(layer9_out_V_data_4_V_TDATA),
        .ap_clk(ap_clk),
        .ap_rst_n(ap_rst_n),
        .conv2d_1_input_V_data_0_V_TVALID(conv2d_1_input_V_data_0_V_TVALID),
        .conv2d_1_input_V_data_0_V_TREADY(conv2d_1_input_V_data_0_V_TREADY),
		  
        .layer9_out_V_data_0_V_TVALID(layer9_out_V_data_0_V_TVALID),
        .layer9_out_V_data_0_V_TREADY(layer9_out_V_data_0_V_TREADY),
		  
		  .layer9_out_V_data_1_V_TVALID(layer9_out_V_data_1_V_TVALID),
        .layer9_out_V_data_1_V_TREADY(layer9_out_V_data_1_V_TREADY),
		
		  .layer9_out_V_data_2_V_TVALID(layer9_out_V_data_2_V_TVALID),
        .layer9_out_V_data_2_V_TREADY(layer9_out_V_data_2_V_TREADY),
		  
		  .layer9_out_V_data_3_V_TVALID(layer9_out_V_data_3_V_TVALID),
        .layer9_out_V_data_3_V_TREADY(layer9_out_V_data_3_V_TREADY),
		  
		  .layer9_out_V_data_4_V_TVALID(layer9_out_V_data_4_V_TVALID),
        .layer9_out_V_data_4_V_TREADY(layer9_out_V_data_4_V_TREADY),
		  
        .ap_start(ap_start),
        .ap_done(ap_done),
        .ap_ready(ap_ready),
        .ap_idle(ap_idle)
	);
	

	//////////////////////// Generate clock ////////////////////////
	parameter CLOCK_PERIOD = 10;
	initial begin
		 ap_clk = 0;
		 forever #(CLOCK_PERIOD/2) ap_clk = ~ap_clk; // 100MHz clock
	end

	integer cc_counter; // cycle counter
    always_ff @(posedge ap_clk) begin
        if (~ap_rst_n) begin
            cc_counter <= 0;
        end
        else begin
            cc_counter <= cc_counter + 1;
        end
    end

    //////////////////////// Set handshake signals ////////////////////////

    // input-valid
	always_ff @(posedge ap_clk) begin
        conv2d_1_input_V_data_0_V_TVALID <= 1'b1;
	end

	// output-ready
	always_ff @(posedge ap_clk) begin
        layer9_out_V_data_0_V_TREADY <= 1'b1;
        layer9_out_V_data_1_V_TREADY <= 1'b1;
        layer9_out_V_data_2_V_TREADY <= 1'b1;
        layer9_out_V_data_3_V_TREADY <= 1'b1;
        layer9_out_V_data_4_V_TREADY <= 1'b1;
	end
	
	//////////////////////// I/O data ////////////////////////

    string input_file_location;
    string input_read_file_location; 
    string output_file_location; 

	// I/O memory
	reg [FP_TOTAL-1:0] input_mem [OUT_ROWS*OUT_COLS-1:0];
    reg [FP_TOTAL-1:0] output_mem [4:0];

	// Indices to track read/write progress
	integer ii;
	integer img_idx;
	
	// File pointers
	integer input_file, input_read_file, output_file;

	// Sequentially read in input data
	always_ff @(posedge ap_clk) begin
		if (~ap_rst_n) begin
			img_idx <= 0;
		end	
		else if (conv2d_1_input_V_data_0_V_TVALID & conv2d_1_input_V_data_0_V_TREADY) begin
			img_idx <= img_idx + 1;
			conv2d_1_input_V_data_0_V_TDATA <= input_mem[img_idx];
		end	
	end
	
	// Sequentially read out output data
	always_ff @(posedge ap_clk) begin

        if (layer9_out_V_data_0_V_TVALID & layer9_out_V_data_0_V_TREADY) begin
            output_mem[0] <= layer9_out_V_data_0_V_TDATA;
        end

        if (layer9_out_V_data_1_V_TVALID & layer9_out_V_data_1_V_TREADY) begin
            output_mem[1] <= layer9_out_V_data_1_V_TDATA;
        end
    
        if (layer9_out_V_data_2_V_TVALID & layer9_out_V_data_2_V_TREADY) begin
            output_mem[2] <= layer9_out_V_data_2_V_TDATA;
        end
    
        if (layer9_out_V_data_3_V_TVALID & layer9_out_V_data_3_V_TREADY) begin
            output_mem[3] <= layer9_out_V_data_3_V_TDATA;
        end
    
        if (layer9_out_V_data_4_V_TVALID & layer9_out_V_data_4_V_TREADY) begin
            output_mem[4] <= layer9_out_V_data_4_V_TDATA;
        end

	end
	
	// Run through signal protocol to run module
	integer run_counter = 0;
	initial begin
		foreach(Y1_range[i]) begin
			foreach(X1_range[j]) begin
				
				input_file_location = $sformatf("tb_data/ap_fixed_%0d_%0d/%0dx%0d_to_%0dx%0dx%0d/Y1_%0d/X1_%0d/img_postcrop_INDEX.bin",
            							FP_TOTAL, FP_INT,
										IN_ROWS, IN_COLS,
            							OUT_ROWS, OUT_COLS, NUM_CROPS,
										Y1_range[i], X1_range[j]);
				input_read_file_location = $sformatf("tb_data/ap_fixed_%0d_%0d/%0dx%0d_to_%0dx%0dx%0d/Y1_%0d/X1_%0d/img_postcrop_INDEX_READIN.bin",
            							FP_TOTAL, FP_INT,
										IN_ROWS, IN_COLS,
            							OUT_ROWS, OUT_COLS, NUM_CROPS,
										Y1_range[i], X1_range[j]);
				output_file_location = $sformatf("tb_data/ap_fixed_%0d_%0d/%0dx%0d_to_%0dx%0dx%0d/Y1_%0d/X1_%0d/cnn_out.bin",
            							FP_TOTAL, FP_INT,
										IN_ROWS, IN_COLS,
            							OUT_ROWS, OUT_COLS, NUM_CROPS,
										Y1_range[i], X1_range[j]);


                //////////////////////// 1. Load input data ////////////////////////
		        $readmemb(input_file_location, input_mem);

                //////////////////////// 2. Wait for computation to complete ////////////////////////

                @(posedge ap_clk) ap_start <= 0; // start off to begin

                // toggle ~ap_rst_n
                @(posedge ap_clk) ap_rst_n <= 0; @(posedge ap_clk) ap_rst_n <= 1; // recall, ap_rst_n active low

                // Toggle start
                @(posedge ap_clk) ap_start <= 1; @(posedge ap_clk) ap_start <= 0; 
                
                //////////////////////// 3. Save output, close files ////////////////////////

                // wait(ap_done)
                // $display("\n\n[INFO] (Y1, X1) = (%0d, %0d) complete", Y1_range[i], X1_range[j]);
                @(negedge ap_done) begin
                    $display("\n\n[INFO] (Y1, X1) = (%0d, %0d) complete", Y1_range[i], X1_range[j]);

                    // Input-read
                    input_read_file = $fopen(input_read_file_location, "wb");
                    if (input_read_file == 0) begin
                        $display("Error: Could not open input-read file for writing.");
                        $stop;
                    end
                    for (ii=0; ii<OUT_ROWS*OUT_COLS; ii=ii+1) begin
                        $fwrite(input_read_file, "%b\n", input_mem[ii]);
                    end

                    // Output
                    output_file = $fopen(output_file_location, "wb");
                    if (output_file == 0) begin
                        $display("Error: Could not open output file for writing.");
                        $stop;
                    end
                    for (ii=0; ii<5; ii=ii+1) begin
                        $fwrite(output_file, "%b\n", output_mem[ii]);
                    end


                    $fclose(input_read_file);
                    $fclose(output_file);


                end

                
		    end

        end
        
		//////////////////////// 4. End sim ////////////////////////
        
        $display("\n\n[TB] Simulation complete; CNN benchmark predictions generated");
		$stop;
	end

endmodule