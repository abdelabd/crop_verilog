`timescale 1ns/1ps

module fifo_sync_testbench();

    //////////////////////// User parameters ////////////////////////
    localparam FP_TOTAL = 8;
    localparam FP_FRAC = 0; // adjust if needed
    localparam FP_INT = FP_TOTAL - FP_FRAC - 1;
    localparam IN_ROWS         = 9;
    localparam IN_COLS         = 9;
    localparam OUT_ROWS        = 3;
    localparam OUT_COLS        = 3;
    localparam NUM_CROPS = 1;

    //////////////////////// DUT signals ////////////////////////
    reg                         clk;
    reg                         reset;
    reg                         in_valid;
    wire                        in_ready;
    reg  [FP_TOTAL-1:0]         in_data;
    wire                        out_valid;
    reg                         out_ready;
    wire [FP_TOTAL-1:0]         out_data;
    
    
    //////////////////////// DUT module ////////////////////////
    fifo_sync #(
        .DATA_WIDTH(FP_TOTAL),
        .FIFO_DEPTH(IN_ROWS*IN_COLS)
        ) dut (
        .clk       (clk),
        .reset     (reset),
        .in_valid  (in_valid),
        .in_ready  (in_ready),
        .in_data   (in_data),
        .out_valid  (out_valid),
        .out_ready  (out_ready),
        .out_data   (out_data)
    );

    //////////////////////// Generate clock ////////////////////////
    
    parameter CLOCK_PERIOD=100;  
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
    logic [FP_TOTAL-1:0] output_mem [IN_ROWS*IN_COLS-1:0];
    logic finished;

    // Indices to track read/write progress
    integer i;
    integer last_idx_in, idx_in, last_idx_out, idx_out;

    // File pointers
    integer input_file, input_read_file, output_file;

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
			in_data <= input_mem[idx_in]; // give data to module

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
            output_mem[idx_out] <= out_data; // get data from module

            // Asserts
            assert((out_data != output_mem[idx_out-1])|(idx_out==0)); // output should be changing for systematic value-equals-index data
            assert((idx_out != last_idx_out)|(idx_out==0)); // exception for first cycle because of indexing
            assert((output_mem[last_idx_out] == input_mem[last_idx_out])|(idx_out==0)); // check if output is same as input, exception on first cycle because of indexing
		end	
	end

    initial begin

        //////////////////////// 1. Toggle reset ////////////////////////
        reset = 1'b1;   
        #(CLOCK_PERIOD*2);

        reset = 1'b0;
        #10;

        //////////////////////// 2. Load input data ////////////////////////

        // input data
        $readmemb($sformatf("tb_data/ap_fixed_%0d_%0d/tb_input_INDEX_%0dx%0d_to_%0dx%0dx%0d.bin",
            FP_TOTAL,
            FP_INT,
            IN_ROWS, IN_COLS,
            OUT_ROWS, OUT_COLS,
            NUM_CROPS), input_mem);

        //////////////////////// 3. Wait for computation to complete ////////////////////////
       #(5*IN_ROWS*IN_COLS*CLOCK_PERIOD+1000);
        // wait(finished);

        $display("input_file location = %0d", $sformatf("tb_data/ap_fixed_%0d_%0d/tb_input_INDEX_%0dx%0d_to_%0dx%0dx%0d.bin",
            FP_TOTAL,
            FP_INT,
            IN_ROWS, IN_COLS,
            OUT_ROWS, OUT_COLS,
            NUM_CROPS));
        
         $display("output_file location = %0d", $sformatf("tb_data/ap_fixed_%0d_%0d/tb_fifoCOPY_INDEX_%0dx%0d_to_%0dx%0dx%0d.bin",
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
            $display("Error: Could not open input-read file for writing.");
            $stop;
        end
        else begin
            $display("Could indeed open input-read file for writing.");
        end

        // Output
        output_file = $fopen($sformatf("tb_data/ap_fixed_%0d_%0d/tb_fifoCOPY_INDEX_%0dx%0d_to_%0dx%0dx%0d.bin",
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


        for (i=0; i<IN_ROWS*IN_COLS; i=i+1) begin
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
