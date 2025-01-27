`timescale 1ns/1ps

module crop_filter_testbench();

    //////////////////////// User parameters ////////////////////////
    localparam FP_TOTAL = 12;
    localparam IN_ROWS         = 40;
    localparam IN_COLS         = 40;
    localparam OUT_ROWS        = 20;
    localparam OUT_COLS        = 20;
    localparam Y_1             = 10;
    localparam X_1             = 10;
    localparam FP_FRAC = 0; // adjust if needed
    localparam FP_INT = FP_TOTAL - FP_FRAC - 1;
    localparam NUM_CROPS = 1; // how many “crops”/frames you want to process

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

    //////////////////////// File-handling ////////////////////////

    // Testbench I/O memory
    logic [FP_TOTAL-1:0] input_mem  [IN_ROWS*IN_COLS-1:0];
    logic [FP_TOTAL-1:0] output_mem [OUT_ROWS*OUT_COLS-1:0];

    // Indices to track read/write progress
    integer i;
    integer idx_in, idx_out;
    integer num_bytes_read;
    integer num_bytes_written;

    // File pointers
    integer input_file, input_read_file, output_file;

    // Sequentially read in input data
	always_ff @(posedge clk) begin
		if (reset) begin
			idx_in <= 0;
		end	
		else if (in_ready & in_valid) begin
			idx_in <= idx_in + 1;
			pixel_in <= input_mem[idx_in]; // give data to module
		end	
	end

    // Sequentially read out output data
	always_ff @(posedge clk) begin
		if (reset) begin
			idx_out <= 0;
		end	
		else if (out_ready & out_valid) begin
			idx_out <= idx_out + 1;
            output_mem[idx_out] <= pixel_out; // get data from module
            assert(pixel_out == pixel_in); // check if output is same as input, which it should be
		end	
	end

    initial begin

        //////////////////////// 1. Toggle reset ////////////////////////
        reset = 1'b1;   
        #(CLOCK_PERIOD*2);

        reset = 1'b0;
        #10;

        //////////////////////// 2. Load input data ////////////////////////
        input_file = $fopen($sformatf("tb_data/ap_fixed_%0d_%0d/tb_input_INDEX_%0dx%0d_to_%0dx%0dx%0d.bin",
            FP_TOTAL,
            FP_INT,
            IN_ROWS, IN_COLS,
            OUT_ROWS, OUT_COLS,
            NUM_CROPS), "rb");
        if (input_file == 0) begin
            $display("Error: Could not open input file for reading.");
            $stop;
        end
        else begin
            $display("Could indeed open input file for reading.");
        end

        // Use $fread in SystemVerilog to read binary data:
        // Each pixel is FP_TOTAL bits. If FP_TOTAL
        // is not a multiple of 8, you may need a custom approach.
        // 
        // We'll assume that each pixel_in is stored in the file as a
        // zero-padded multiple of 8 bits. For example, if FP_TOTAL=12,
        // you might actually store 16 bits per pixel in the file, with the upper 4 bits 0.
        //
        // Another approach is to read bytes in a loop, then assemble them. 
        // The example below tries $fread directly, but might need adjustments 
        // if your file is strictly 12 bits per pixel in raw binary.

        num_bytes_read = $fread(input_mem, input_file);
        $display("[INFO] Read %0d bytes from input_file.", num_bytes_read); 

        //////////////////////// 3. Wait for computation to complete ////////////////////////
       #500000;

        //////////////////////// 3. Save output, close files ////////////////////////
        // Input-read
        input_read_file = $fopen($sformatf("tb_data/ap_fixed_%0d_%0d/tb_input_READ_INDEX_noFIFO_%0dx%0d_to_%0dx%0dx%0d.bin",
            FP_TOTAL,
            FP_INT,
            IN_ROWS, IN_COLS,
            OUT_ROWS, OUT_COLS,
            NUM_CROPS), "wb");
        if (input_read_file == 0) begin
            $display("Error: Could not open input-read file for writing.");
            $stop;
        end
        else begin
            $display("Could indeed open input-read file for writing.");
        end

        // Output
        output_file = $fopen($sformatf("tb_data/ap_fixed_%0d_%0d/tb_output_INDEX_noFIFO_%0dx%0d_to_%0dx%0dx%0d.bin",
            FP_TOTAL,
            FP_INT,
            IN_ROWS, IN_COLS,
            OUT_ROWS, OUT_COLS,
            NUM_CROPS), "wb");
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
        for (i=0; i<IN_ROWS*IN_COLS; i=i+1) begin
            $fwrite(input_read_file, "%b\n", input_mem[i]);
        end

        $fclose(input_file);
        $fclose(input_read_file);
        $fclose(output_file);
        
        //////////////////////// 5. End sim ////////////////////////
        
        $display("[TB] Simulation complete.");
        $stop;
    end

endmodule
