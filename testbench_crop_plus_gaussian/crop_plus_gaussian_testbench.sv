`timescale 1 ns / 1 ps 

module crop_plus_gaussian_testbench();

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
	logic [FP_TOTAL-1:0] crop_input_TDATA; //input
	logic crop_input_TVALID; //input: data valid to be sent
    wire crop_input_TREADY; //output: myproject ready to receive data
		  
	// output[0]
	wire [FP_TOTAL-1:0] cnn_output_0_TDATA; //output
	wire cnn_output_0_TVALID; // output: myproject output valid to be sent
    reg cnn_output_0_TREADY; //input: receiver ready to receive myproject output
	 
	// output[1]
	wire [FP_TOTAL-1:0] cnn_output_1_TDATA; //output
	wire cnn_output_1_TVALID; // output: myproject output valid to be sent
    reg cnn_output_1_TREADY; //input: receiver ready to receive myproject output
	
	// output[2]
	wire [FP_TOTAL-1:0] cnn_output_2_TDATA; //output
	wire cnn_output_2_TVALID; // output: myproject output valid to be sent
    reg cnn_output_2_TREADY; //input: receiver ready to receive myproject output
	
	// output[3]
	wire [FP_TOTAL-1:0] cnn_output_3_TDATA; //output
	wire cnn_output_3_TVALID; // output: myproject output valid to be sent
    reg cnn_output_3_TREADY; //input: receiver ready to receive myproject output
	
	// output[4]
	wire [FP_TOTAL-1:0] cnn_output_4_TDATA; //output
	wire cnn_output_4_TVALID; // output: myproject output valid to be sent
    reg cnn_output_4_TREADY; //input: receiver ready to receive myproject output

	//////////////////////// DUT module ////////////////////////
	crop_plus_gaussian #(
        .PIXEL_BIT_WIDTH(FP_TOTAL),
        .IN_ROWS(IN_ROWS),
        .IN_COLS(IN_COLS),
        .OUT_ROWS(OUT_ROWS),
        .OUT_COLS(OUT_COLS),
        .Y_1(Y_1),
        .X_1(X_1)
    )
    dut (
		  .crop_input_TDATA(crop_input_TDATA),
          .cnn_output_0_TDATA(cnn_output_0_TDATA),
		  .cnn_output_1_TDATA(cnn_output_1_TDATA),
		  .cnn_output_2_TDATA(cnn_output_2_TDATA),
		  .cnn_output_3_TDATA(cnn_output_3_TDATA),
		  .cnn_output_4_TDATA(cnn_output_4_TDATA),
        .ap_clk(ap_clk),
        .ap_rst_n(ap_rst_n),
        .crop_input_TVALID(crop_input_TVALID),
        .crop_input_TREADY(crop_input_TREADY),
		  
        .cnn_output_0_TVALID(cnn_output_0_TVALID),
        .cnn_output_0_TREADY(cnn_output_0_TREADY),
		  
		  .cnn_output_1_TVALID(cnn_output_1_TVALID),
        .cnn_output_1_TREADY(cnn_output_1_TREADY),
		
		  .cnn_output_2_TVALID(cnn_output_2_TVALID),
        .cnn_output_2_TREADY(cnn_output_2_TREADY),
		  
		  .cnn_output_3_TVALID(cnn_output_3_TVALID),
        .cnn_output_3_TREADY(cnn_output_3_TREADY),
		  
		  .cnn_output_4_TVALID(cnn_output_4_TVALID),
        .cnn_output_4_TREADY(cnn_output_4_TREADY),
		  
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

    //////////////////////// Randomize handshake signals ////////////////////////

    // 1. valid-ready = 00
    // 2. valid-ready = 10
    // 3. valid-ready = 01
    // 4. valid-ready = 11 (both random)

	always_ff @(posedge ap_clk) begin
        if (cc_counter < 1.5*OUT_ROWS*OUT_COLS) begin
            crop_input_TVALID <= 1'b0;
        end
        else if (cc_counter < 3*OUT_ROWS*OUT_COLS) begin
            crop_input_TVALID <= 1'b1;
        end
        else if (cc_counter < 4.5*OUT_ROWS*OUT_COLS) begin
            crop_input_TVALID <= 1'b0;
        end
        else begin
            crop_input_TVALID <= $urandom%2;
        end
	end

	// output-ready

	always_ff @(posedge ap_clk) begin
        if (cc_counter < 1.5*OUT_ROWS*OUT_COLS) begin
            cnn_output_0_TREADY <= 1'b0;
			cnn_output_1_TREADY <= 1'b0;
			cnn_output_2_TREADY <= 1'b0;
			cnn_output_3_TREADY <= 1'b0;
			cnn_output_4_TREADY <= 1'b0;
        end
        else if (cc_counter < 3*OUT_ROWS*OUT_COLS) begin
            cnn_output_0_TREADY <= 1'b0;
			cnn_output_1_TREADY <= 1'b0;
			cnn_output_2_TREADY <= 1'b0;
			cnn_output_3_TREADY <= 1'b0;
			cnn_output_4_TREADY <= 1'b0;
        end
        else if (cc_counter < 4.5*OUT_ROWS*OUT_COLS) begin
            cnn_output_0_TREADY <= 1'b1;
			cnn_output_1_TREADY <= 1'b1;
			cnn_output_2_TREADY <= 1'b1;
			cnn_output_3_TREADY <= 1'b1;
			cnn_output_4_TREADY <= 1'b1;
        end
        else begin
			cnn_output_0_TREADY <= $urandom%2;
			cnn_output_1_TREADY <= $urandom%2;
			cnn_output_2_TREADY <= $urandom%2;
			cnn_output_3_TREADY <= $urandom%2;
			cnn_output_4_TREADY <= $urandom%2;
        end
	end
	
	//////////////////////// I/O data ////////////////////////

    string input_file_location = $sformatf("tb_data/ap_fixed_%0d_%0d/img_precrop_INDEX_%0dx%0d_to_%0dx%0dx%0d.bin",
            FP_TOTAL, FP_INT,
			IN_ROWS, IN_COLS,
            OUT_ROWS, OUT_COLS,
            NUM_CROPS);
    string input_read_file_location = $sformatf("tb_data/ap_fixed_%0d_%0d/img_precrop_INDEX_READIN_%0dx%0d_to_%0dx%0dx%0d.bin",
		    FP_TOTAL, FP_INT,
			IN_ROWS, IN_COLS,
            OUT_ROWS, OUT_COLS,
            NUM_CROPS);
    string output_benchmark_file_location = $sformatf("tb_data/ap_fixed_%0d_%0d/cnn_pred_benchmark_INDEX_%0dx%0d_to_%0dx%0dx%0d.bin",
            FP_TOTAL, FP_INT,
			IN_ROWS, IN_COLS,
            OUT_ROWS, OUT_COLS,
            NUM_CROPS);
    string output_file_location = $sformatf("tb_data/ap_fixed_%0d_%0d/cpg_pred_INDEX_%0dx%0d_to_%0dx%0dx%0d.bin",
            FP_TOTAL, FP_INT,
			IN_ROWS, IN_COLS,
            OUT_ROWS, OUT_COLS,
            NUM_CROPS);

	// I/O memory
	reg [FP_TOTAL-1:0] input_mem [IN_ROWS*IN_COLS-1:0];
    reg [FP_TOTAL-1:0] output_mem [4:0];
	logic [FP_TOTAL-1:0] output_benchmark_mem [4:0];

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
		else if (crop_input_TVALID & crop_input_TREADY) begin
			img_idx <= img_idx + 1;
			crop_input_TDATA <= input_mem[img_idx];
		end	
	end
	
	// Sequentially read out output data
	always_ff @(posedge ap_clk) begin
		if (~ap_rst_n) begin
			output_mem <= output_mem_refresh;
		end
		else begin

		    if (cnn_output_0_TVALID & cnn_output_0_TREADY) begin
			    output_mem[0] <= cnn_output_0_TDATA;
			    assert(cnn_output_0_TDATA == output_benchmark_mem[0]);
		    end

		    if (cnn_output_1_TVALID & cnn_output_1_TREADY) begin
			    output_mem[1] <= cnn_output_1_TDATA;
			    assert(cnn_output_1_TDATA == output_benchmark_mem[1]);
		    end
		
		    if (cnn_output_2_TVALID & cnn_output_2_TREADY) begin
			    output_mem[2] <= cnn_output_2_TDATA;
			    assert(cnn_output_2_TDATA == output_benchmark_mem[2]);
		    end
		
		    if (cnn_output_3_TVALID & cnn_output_3_TREADY) begin
			    output_mem[3] <= cnn_output_3_TDATA;
			    assert(cnn_output_3_TDATA == output_benchmark_mem[3]);
		    end
		
		    if (cnn_output_4_TVALID & cnn_output_4_TREADY) begin
			    output_mem[4] <= cnn_output_4_TDATA;
			    assert(cnn_output_4_TDATA == output_benchmark_mem[4]);
		    end

		end
	end
	
	// Run through signal protocol to run module
	integer run_counter = 0;
	initial begin

		$display("\ninput_file_location = %0d", input_file_location);
		$display("output_benchmark_file_location = %0d", output_benchmark_file_location);
		$display("input_read_file_location = %0d", input_read_file_location);
		$display("output_file_location = %0d\n", output_file_location);

		//////////////////////// 1. Load input and benchmark data ////////////////////////
	    
		// input data
		
		$readmemb(input_file_location, input_mem);

		// Output benchmark, against which to compare for assertions
		$readmemb(output_benchmark_file_location, output_benchmark_mem);

		//////////////////////// 2. Wait for computation to complete ////////////////////////

        ap_start = 0; // start off to begin
		repeat(3) begin

		    // toggle ~ap_rst_n
		    @(posedge ap_clk) ap_rst_n <= 0; @(posedge ap_clk) ap_rst_n <= 1; // recall, active low

            // Toggle start
		    @(posedge ap_clk) ap_start <= 1; @(posedge ap_clk) ap_start <= 0; 

            // Wait for done
			@(posedge ap_done) begin 
				run_counter <= run_counter + 1;
				$display("\n\n[INFO] Run %0d complete.", run_counter+1);
			end
		end 

        //////////////////////// 3. Save output, close files ////////////////////////
        // Input-read
		input_read_file = $fopen(input_read_file_location, "wb");
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
		output_file = $fopen(output_file_location, "wb");
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


        $fclose(input_read_file);
        $fclose(output_file);

		//////////////////////// 4. End sim ////////////////////////
        
        $display("\n\n[TB] Simulation complete.");
		$stop;
	end

endmodule