`timescale 1ns/1ps

module crop_filter_testbench();

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
    reg                         clk;
    reg                         reset;
    reg  [FP_TOTAL-1:0] pixel_in;
    wire [FP_TOTAL-1:0] pixel_out;
    wire                        in_ready;
    reg                         in_valid;
    reg                         out_ready;
    wire                        out_valid;
    
    //////////////////////// DUT module ////////////////////////
    crop_filter #(
        .PIXEL_BIT_WIDTH(FP_TOTAL),
        .IN_ROWS(IN_ROWS),
        .IN_COLS(IN_COLS),
        .OUT_ROWS(OUT_ROWS),
        .OUT_COLS(OUT_COLS),
        .Y_1(Y_1),
        .X_1(X_1)
    ) dut (
        .clk       (clk),
        .reset     (reset),
        .pixel_in  (pixel_in),
        .pixel_out (pixel_out),
        .in_ready  (in_ready),
        .in_valid  (in_valid),
        .out_ready (out_ready),
        .out_valid (out_valid)
    );

    //////////////////////// Generate clock ////////////////////////
    
    parameter CLOCK_PERIOD=100;  
	initial begin  
		clk <= 0;  
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock 
	end  

    //////////////////////// Randomize handshake signals ////////////////////////

    // input-valid
	always_ff @(posedge clk) begin
		in_valid <= $urandom%2;
	end

	// output-ready
	always_ff @(posedge clk) begin
		out_ready <= $urandom%2;
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
    string output_benchmark_file_location = $sformatf("tb_data/ap_fixed_%0d_%0d/img_postcrop_INDEX_%0dx%0d_to_%0dx%0dx%0d.bin",
            FP_TOTAL, FP_INT,
			IN_ROWS, IN_COLS,
            OUT_ROWS, OUT_COLS,
            NUM_CROPS);
    string output_file_location = $sformatf("tb_data/ap_fixed_%0d_%0d/cropfilter_pred_INDEX_%0dx%0d_to_%0dx%0dx%0d.bin",
            FP_TOTAL, FP_INT,
			IN_ROWS, IN_COLS,
            OUT_ROWS, OUT_COLS,
            NUM_CROPS);
    
    // I/O memory
    logic [FP_TOTAL-1:0] input_mem  [IN_ROWS*IN_COLS-1:0];
    logic [FP_TOTAL-1:0] output_mem [OUT_ROWS*OUT_COLS-1:0];
    logic [FP_TOTAL-1:0] output_benchmark_mem [OUT_ROWS*OUT_COLS-1:0];
    logic finished;

    // Indices to track read/write progress
    integer i;
    integer last_idx_in, idx_in, last_idx_out, idx_out;

    // File pointers
    integer input_file, input_read_file, output_file, output_benchmark_file;

    // Sequentially read in input data
	always_ff @(posedge clk) begin
		if (reset) begin
            last_idx_in <= 0;
			idx_in <= 0;
            finished <= 1'b0;
		end	
		else if (in_ready & in_valid) begin
            last_idx_in <= idx_in;
			idx_in <= idx_in + 1;
			pixel_in <= input_mem[idx_in]; // give data to module

            if (idx_in == IN_ROWS*IN_COLS-1) begin
                finished <= 1'b1;
            end

            // Asserts
            assert((idx_in != last_idx_in)|(idx_in==0)); // exception for first cycle because of indexing
		end	
	end

    // Sequentially read out output data
	always_ff @(posedge clk) begin
		if (reset) begin
            last_idx_out <= 0;
			idx_out <= 0;
		end	
		else if (out_ready & out_valid) begin
            last_idx_out <= idx_out;
			idx_out <= idx_out + 1;
            output_mem[idx_out] <= pixel_out; // get data from module

            // Asserts
            assert(pixel_out == pixel_in); // confirm output is same as input
            assert((pixel_out != output_mem[idx_out-1])|(idx_out==0)); // output should be changing for systematic value-equals-index data
            assert((idx_out != last_idx_out)|(idx_out==0)); // exception for first cycle because of indexing
            assert((output_mem[last_idx_out] == output_benchmark_mem[last_idx_out])|(idx_out==0)); // check if output is same as benchmark, exception on first cycle because of indexing
		end	
	end

    initial begin

        $display("\ninput_file_location = %0d", input_file_location);
		$display("output_benchmark_file_location = %0d", output_benchmark_file_location);
		$display("input_read_file_location = %0d", input_read_file_location);
		$display("output_file_location = %0d\n", output_file_location);

        //////////////////////// 1. Load input and benchmark data ////////////////////////
	    
        // input data
        $readmemb(input_file_location, input_mem);

        // output benchmark data
        $readmemb(output_benchmark_file_location, output_benchmark_mem);

        //////////////////////// 2. Wait for computation to complete ////////////////////////

        // Toggle reset
        reset = 1'b1;  #(CLOCK_PERIOD*2); reset = 1'b0; #10;
        
        wait(finished);

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
        for (i=0; i<IN_ROWS*IN_COLS; i=i+1) begin
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
        for (i=0; i<OUT_ROWS*OUT_COLS; i=i+1) begin
            $fwrite(output_file, "%b\n", output_mem[i]);
        end
        
        $fclose(input_read_file);
        $fclose(output_file);
        
        //////////////////////// 5. End sim ////////////////////////
        
        $display("[TB] Simulation complete.");
        $stop;
    end

endmodule
