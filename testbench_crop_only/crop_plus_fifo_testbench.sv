`timescale 1ns/1ps

module crop_plus_fifo_testbench();

    //////////////////////// User parameters ////////////////////////
    localparam FP_TOTAL = 8;
    localparam FP_FRAC = 0;
    localparam FP_INT = FP_TOTAL - FP_FRAC - 1;

    localparam IN_ROWS         = 9;
    localparam IN_COLS         = 9;
    localparam OUT_ROWS        = 3;
    localparam OUT_COLS        = 3;
    localparam Y_1             = 2;
    localparam X_1             = 2;
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
    crop_plus_fifo #(
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
    parameter CLOCK_PERIOD=10;  
	initial begin  
		clk <= 0;  
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock 
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

    // input-valid
	always_ff @(posedge clk) begin
        if (cc_counter < 2*IN_ROWS*IN_COLS) begin
            in_valid <= 1'b0;
        end
        else if (cc_counter < 4*IN_ROWS*IN_COLS) begin
            in_valid <= 1'b1;
        end
        else if (cc_counter < 6*IN_ROWS*IN_COLS) begin
            in_valid <= 1'b0;
        end
        else begin
            in_valid <= $urandom%2;
        end
	end

	// output-ready
	always_ff @(posedge clk) begin
         if (cc_counter < 2*IN_ROWS*IN_COLS) begin
            out_ready <= 1'b0;
        end
        else if (cc_counter < 4*IN_ROWS*IN_COLS) begin
            out_ready <= 1'b0;
        end
        else if (cc_counter < 6*IN_ROWS*IN_COLS) begin
            out_ready <= 1'b1;
        end
        else begin
            out_ready <= $urandom%2;
        end
	end

    //////////////////////// I/O data ////////////////////////

    // I/O memory
    logic [FP_TOTAL-1:0] input_mem  [IN_ROWS*IN_COLS-1:0];
    logic [FP_TOTAL-1:0] output_mem [OUT_ROWS*OUT_COLS-1:0];
    logic [FP_TOTAL-1:0] output_benchmark_mem [OUT_ROWS*OUT_COLS-1:0];
    logic finished;

    genvar ii;
    logic [FP_TOTAL-1:0] output_mem_refresh  [OUT_ROWS*OUT_COLS-1:0];
    for (ii=0; ii<OUT_ROWS*OUT_COLS; ii++) begin
        assign output_mem_refresh[ii] = 0;
    end

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
            output_mem <= output_mem_refresh;
		end	
		else if (out_ready & out_valid) begin
            last_idx_out <= idx_out;
			idx_out <= idx_out + 1;
            output_mem[idx_out] <= pixel_out; // get data from module

            // Asserts
            assert((pixel_out != output_mem[idx_out-1])|(idx_out==0)); // output should be changing for systematic value-equals-index data
            assert((idx_out != last_idx_out)|(idx_out==0)); // exception for first cycle because of indexing
            assert((output_mem[last_idx_out] == output_benchmark_mem[last_idx_out])|(idx_out==0)); // check if output is same as benchmark, exception on first cycle because of indexing
		end	
	end

    integer run_counter = 0;
    initial begin

        //////////////////////// 1. Load input and benchmark data ////////////////////////

        // input data
        $readmemb($sformatf("tb_data/ap_fixed_%0d_%0d/tb_input_INDEX_%0dx%0d_to_%0dx%0dx%0d.bin",
            FP_TOTAL,
            FP_INT,
            IN_ROWS, IN_COLS,
            OUT_ROWS, OUT_COLS,
            NUM_CROPS), input_mem);

        $readmemb($sformatf("tb_data/ap_fixed_%0d_%0d/tb_benchmark_output_INDEX_%0dx%0d_to_%0dx%0dx%0d.bin",
            FP_TOTAL,
            FP_INT,
            IN_ROWS, IN_COLS,
            OUT_ROWS, OUT_COLS,
            NUM_CROPS), output_benchmark_mem);

        //////////////////////// 2. Wait for computation to complete ////////////////////////

        // Let's run it several times
        repeat(1000) begin 
            reset <= 1'b1; #(CLOCK_PERIOD*2); reset <= 1'b0; 
            wait(finished);
            run_counter <= run_counter + 1;
        end
        $display("\n\n[INFO] Total runs = %0d", run_counter+1);

        $display("input_file location = %0d", $sformatf("tb_data/ap_fixed_%0d_%0d/tb_input_INDEX_%0dx%0d_to_%0dx%0dx%0d.bin",
            FP_TOTAL,
            FP_INT,
            IN_ROWS, IN_COLS,
            OUT_ROWS, OUT_COLS,
            NUM_CROPS));
        
         $display("output_file location = %0d", $sformatf("tb_data/ap_fixed_%0d_%0d/tb_output_INDEX_%0dx%0d_to_%0dx%0dx%0d.bin",
            FP_TOTAL,
            FP_INT,
            IN_ROWS, IN_COLS,
            OUT_ROWS, OUT_COLS,
            NUM_CROPS));

        //////////////////////// 3. Save output, close files ////////////////////////
        // Input-read
        input_read_file = $fopen($sformatf("tb_data/ap_fixed_%0d_%0d/tb_input_READ_INDEX_%0dx%0d_to_%0dx%0dx%0d.bin",
            FP_TOTAL,
            FP_INT,
            IN_ROWS, IN_COLS,
            OUT_ROWS, OUT_COLS,
            NUM_CROPS), "wb");
        if (input_read_file == 0) begin
            $display("\n\nError: Could not open input-read file for writing.");
            $stop;
        end
        else begin
            $display("\n\nCould indeed open input-read file for writing.");
        end

        // Output
        output_file = $fopen($sformatf("tb_data/ap_fixed_%0d_%0d/tb_output_INDEX_%0dx%0d_to_%0dx%0dx%0d.bin",
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
        
        //////////////////////// 4. End sim ////////////////////////
        
        $display("\n\n[TB] Simulation complete.");
        $stop;
    end

endmodule
