`timescale 1 ns / 1 ps 

module myproject_testbench();

    //////////////////////// User parameters ////////////////////////
    localparam FP_TOTAL = 16;
    localparam FP_FRAC = 0;
    localparam FP_INT = FP_TOTAL - FP_FRAC - 1;

    localparam IN_ROWS         = 100;
    localparam IN_COLS         = 160;
    localparam OUT_ROWS        = 48;
    localparam OUT_COLS        = 48;
    localparam Y_1             = 10;
    localparam X_1             = 10;
    localparam NUM_CROPS       = 1; 

	//////////////////////// DUT signals ////////////////////////
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

	//////////////////////// DUT module ////////////////////////
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
	

	//////////////////////// Generate clock ////////////////////////
	parameter CLOCK_PERIOD = 10;
	initial begin
		 ap_clk = 0;
		 forever #(CLOCK_PERIOD/2) ap_clk = ~ap_clk; // 100MHz clock
	end

	integer cc_counter; // cycle counter
    always_ff @(posedge clk) begin
        if (reset) begin
            cc_counter <= 0;
        end
        else begin
            cc_counter <= cc_counter + 1;
        end
    end

    //////////////////////// Randomize handshake signals ////////////////////////

    // 1. valid-ready = 00
    // 2. valid-ready = 10
    // 3. valid-ready = 01
    // 4. valid-ready = 11 (both random)

	always_ff @(posedge clk) begin
        if (cc_counter < 2*OUT_ROWS*OUT_COLS) begin
            conv2d_input_V_data_0_V_TVALID <= 1'b0;
        end
        else if (cc_counter < 4*OUT_ROWS*OUT_COLS) begin
            conv2d_input_V_data_0_V_TVALID <= 1'b1;
        end
        else if (cc_counter < 6*OUT_ROWS*OUT_COLS) begin
            conv2d_input_V_data_0_V_TVALID <= 1'b0;
        end
        else begin
            conv2d_input_V_data_0_V_TVALID <= $urandom%2;
        end
	end

	// output-ready

	always_ff @(posedge clk) begin
        if (cc_counter < 2*OUT_ROWS*OUT_COLS) begin
            layer15_out_V_data_0_V_TREADY <= 1'b0;
			layer15_out_V_data_1_V_TREADY <= 1'b0;
			layer15_out_V_data_2_V_TREADY <= 1'b0;
			layer15_out_V_data_3_V_TREADY <= 1'b0;
			layer15_out_V_data_4_V_TREADY <= 1'b0;
        end
        else if (cc_counter < 4*OUT_ROWS*OUT_COLS) begin
            layer15_out_V_data_0_V_TREADY <= 1'b0;
			layer15_out_V_data_1_V_TREADY <= 1'b0;
			layer15_out_V_data_2_V_TREADY <= 1'b0;
			layer15_out_V_data_3_V_TREADY <= 1'b0;
			layer15_out_V_data_4_V_TREADY <= 1'b0;
        end
        else if (cc_counter < 6*OUT_ROWS*OUT_COLS) begin
            layer15_out_V_data_0_V_TREADY <= 1'b1;
			layer15_out_V_data_1_V_TREADY <= 1'b1;
			layer15_out_V_data_2_V_TREADY <= 1'b1;
			layer15_out_V_data_3_V_TREADY <= 1'b1;
			layer15_out_V_data_4_V_TREADY <= 1'b1;
        end
        else begin
			layer15_out_V_data_0_V_TREADY <= $urandom%2;
			layer15_out_V_data_1_V_TREADY <= $urandom%2;
			layer15_out_V_data_2_V_TREADY <= $urandom%2;
			layer15_out_V_data_3_V_TREADY <= $urandom%2;
			layer15_out_V_data_4_V_TREADY <= $urandom%2;
        end
	end
	
	//////////////////////// I/O data ////////////////////////

	// I/O memory
	reg [FP_TOTAL-1:0] input_mem [OUT_ROWS*OUT_COLS-1:0];
    reg [FP_TOTAL-1:0] output_mem [4:0];
	logic [FP_TOTAL-1:0] output_benchmark_mem [OUT_ROWS*OUT_COLS-1:0];

    logic [FP_TOTAL-1:0] output_mem_refresh  [4:0];
    genvar ii;
    for (ii=0; ii<5; ii++) begin
        assign output_mem_refresh[ii] = 0;
    end

	// Indices to track read/write progress
	integer i;
	integer img_idx;
	
	// File pointers
	integer input_file, input_read_file, output_file, output_benchmark_file;

	// Sequentially read in input data
	always_ff @(posedge ap_clk) begin
		if (~ap_rst_n) begin
			img_idx <= 0;
		end	
		else if (conv2d_input_V_data_0_V_TVALID & conv2d_input_V_data_0_V_TREADY) begin
			img_idx <= img_idx + 1;
			conv2d_input_V_data_0_V_TDATA <= input_mem[img_idx];
		end	
	end
	
	// Sequentially read out output data
	always_ff @(posedge ap_clk) begin
		if (layer15_out_V_data_0_V_TVALID & layer15_out_V_data_0_V_TREADY) begin
			output_mem[0] <= layer15_out_V_data_0_V_TDATA;
			assert(layer15_out_V_data_0_V_TDATA == output_benchmark_mem[0]);
		end
	
		if (layer15_out_V_data_1_V_TVALID & layer15_out_V_data_1_V_TREADY) begin
			output_mem[1] <= layer15_out_V_data_1_V_TDATA;
			assert(layer15_out_V_data_1_V_TDATA == output_benchmark_mem[1]);
		end
		
		if (layer15_out_V_data_2_V_TVALID & layer15_out_V_data_2_V_TREADY) begin
			output_mem[2] <= layer15_out_V_data_2_V_TDATA;
			assert(layer15_out_V_data_2_V_TDATA == output_benchmark_mem[2]);
		end
		
		if (layer15_out_V_data_3_V_TVALID & layer15_out_V_data_3_V_TREADY) begin
			output_mem[3] <= layer15_out_V_data_3_V_TDATA;
			assert(layer15_out_V_data_3_V_TDATA == output_benchmark_mem[3]);
		end
		
		if (layer15_out_V_data_4_V_TVALID & layer15_out_V_data_4_V_TREADY) begin
			output_mem[4] <= layer15_out_V_data_4_V_TDATA;
			assert(layer15_out_V_data_4_V_TDATA == output_benchmark_mem[4]);
		end
	end
	
	// Run through signal protocol to run module
	initial begin

		//////////////////////// 1. Load input and benchmark data ////////////////////////
	    
		// input data
		$display("input_file location = %0d", $sformatf("tb_data/img_postcrop_INDEX_%0dx%0d_to_%0dx%0dx%0d.bin",
            IN_ROWS, IN_COLS,
            OUT_ROWS, OUT_COLS,
            NUM_CROPS));
		$readmemb($sformatf("tb_data/img_postcrop_INDEX_%0dx%0d_to_%0dx%0dx%0d.bin",
            IN_ROWS, IN_COLS,
            OUT_ROWS, OUT_COLS,
            NUM_CROPS), input_mem);

		// Output benchmark, against which to compare for assertions
		$readmemb($sformatf("tb_data/vout_postcrop_benchmark_INDEX_%0dx%0d_to_%0dx%0dx%0d.bin",
            IN_ROWS, IN_COLS,
            OUT_ROWS, OUT_COLS,
            NUM_CROPS), output_benchmark_mem);

		//////////////////////// 2. Wait for computation to complete ////////////////////////

		// Turn on reset, turn off start
		ap_rst_n = 0; // active low
		ap_start = 0;
		
		// Turn off reset
		#20;
		ap_rst_n = 1;
		
		// Toggle start
		#10;
		ap_start = 1;
		#10;
		ap_start = 0;
		 
        wait(ap_done);
		#(1000*CLOCK_PERIOD);

        //////////////////////// 3. Save output, close files ////////////////////////
        // Input-read
		input_read_file = $fopen("tb_data/img_postcrop_INDEX_READIN_100x160_to_48x48x1.bin", "wb");
		if (input_read_file == 0) begin
			$display("Error: Could not open input-read file for writing.");
			$stop;
		end
		else begin
			$display("Could indeed open input-read file for writing.");
		end
		for (i=0; i<OUT_ROWS*OUT_COLS; i=i+1) begin
            $fwrite(input_read_file, "%b\n", input_mem[i]);
        end

		// Output
		$display("output_file location = %0d", $sformatf("tb_data/ap_fixed_%0d_%0d/vout_INDEX_%0dx%0d_to_%0dx%0dx%0d.bin",
            FP_TOTAL,
            FP_INT,
            IN_ROWS, IN_COLS,
            OUT_ROWS, OUT_COLS,
            NUM_CROPS));
		output_file = $fopen("tb_data/vout_postcrop_INDEX_100x160_to_48x48x1.bin", "wb");
		if (output_file == 0) begin
			$display("Error: Could not open output file for writing.");
			$stop;
		end
		else begin
			$display("Could indeed open output file for writing.");
		end
		for (i=0; i<5; i=i+1) begin
            $fwrite(output_file, "%b\n", output_mem[i]);
        end

        $fclose(input_file);
        $fclose(input_read_file);
        $fclose(output_file);

		//////////////////////// 4. End sim ////////////////////////
        
        $display("\n\n[TB] Simulation complete.");
		$stop;
	end

endmodule