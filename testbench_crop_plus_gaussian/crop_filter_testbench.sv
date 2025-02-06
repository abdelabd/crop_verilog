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
    localparam IMG_ROW_BITWIDTH = 10;
    localparam IMG_COL_BITWIDTH = 10;
    localparam NUM_CROPS       = 1; 

    //////////////////////// DUT signals ////////////////////////
    reg                         clk;
    reg                         reset;
    reg  [FP_TOTAL-1:0]         pixel_in_TDATA;
    reg                         pixel_in_TVALID;
    wire                        pixel_in_TREADY;
    reg  [IMG_ROW_BITWIDTH-1:0] crop_Y1_TDATA;
    reg                         crop_Y1_TVALID;
    wire                        crop_Y1_TREADY;
    reg  [IMG_ROW_BITWIDTH-1:0] crop_X1_TDATA;
    reg                         crop_X1_TVALID;
    wire                        crop_X1_TREADY;
    wire [FP_TOTAL-1:0]         pixel_out_TDATA;
    wire                        pixel_out_TVALID;
    reg                         pixel_out_TREADY;
    
    
    //////////////////////// DUT module ////////////////////////
    crop_filter #(
        .PIXEL_BIT_WIDTH(FP_TOTAL),
        .IN_ROWS(IN_ROWS),
        .IN_COLS(IN_COLS),
        .OUT_ROWS(OUT_ROWS),
        .OUT_COLS(OUT_COLS),
        .IMG_ROW_BITWIDTH(IMG_ROW_BITWIDTH),
        .IMG_COL_BITWIDTH(IMG_COL_BITWIDTH)
    ) dut (
        .clk       (clk),
        .reset     (reset),
        .pixel_in_TDATA  (pixel_in_TDATA),
        .pixel_in_TVALID  (pixel_in_TVALID),
        .pixel_in_TREADY  (pixel_in_TREADY),
        .crop_Y1_TDATA  (crop_Y1_TDATA),
        .crop_Y1_TVALID  (crop_Y1_TVALID),
        .crop_Y1_TREADY  (crop_Y1_TREADY),
        .crop_X1_TDATA  (crop_X1_TDATA),
        .crop_X1_TVALID  (crop_X1_TVALID),
        .crop_X1_TREADY  (crop_X1_TREADY),
        .pixel_out_TDATA (pixel_out_TDATA),
        .pixel_out_TVALID (pixel_out_TVALID),
        .pixel_out_TREADY (pixel_out_TREADY)
    );

    //////////////////////// Generate clock ////////////////////////
    
    parameter CLOCK_PERIOD=100;  
	initial begin  
		clk <= 0;  
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock 
	end  

    //////////////////////// Randomize handshake signals ////////////////////////

    // pixel_in_TVALID
	always_ff @(posedge clk) begin
		pixel_in_TVALID <= $urandom%2;
	end

    // crop_Y1_TVALID
	always_ff @(posedge clk) begin
		crop_Y1_TVALID <= 1'b1;
	end

    // crop_X1_TVALID
	always_ff @(posedge clk) begin
		crop_X1_TVALID <= 1'b1;
	end

	// pixel_out_TREADY
	always_ff @(posedge clk) begin
		pixel_out_TREADY <= $urandom%2;
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
    logic [FP_TOTAL-1:0] output_mem_refresh  [OUT_ROWS*OUT_COLS-1:0];
    genvar ii;
    for (ii=0; ii<5; ii++) begin
        assign output_mem_refresh[ii] = 0;
    end

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
		else if (pixel_in_TREADY & pixel_in_TVALID) begin
            last_idx_in <= idx_in;
			idx_in <= idx_in + 1;
			pixel_in_TDATA <= input_mem[idx_in]; // give data to module

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
		else if (pixel_out_TREADY & pixel_out_TVALID) begin
            last_idx_out <= idx_out;
			idx_out <= idx_out + 1;
            output_mem[idx_out] <= pixel_out_TDATA; // get data from module

            // Asserts
            assert(pixel_out_TDATA == pixel_in_TDATA); // confirm output is same as input
            assert((pixel_out_TDATA != output_mem[idx_out-1])|(idx_out==0)); // output should be changing for systematic value-equals-index data
            assert((idx_out != last_idx_out)|(idx_out==0)); // exception for first cycle because of indexing
            assert((output_mem[last_idx_out] == output_benchmark_mem[last_idx_out])|(idx_out==0)); // check if output is same as benchmark, exception on first cycle because of indexing
		end	
	end

    integer run_counter = 0;
    initial begin

        crop_Y1_TDATA <= 'd10;
        crop_X1_TDATA <= 'd10;

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
        repeat(100) begin
            reset <= 1'b1;  #(CLOCK_PERIOD*2); reset <= 1'b0; 
            wait(finished);
            run_counter <= run_counter + 1;
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
        
        $display("\n\n[INFO] Total runs = %0d", run_counter+1);
        $display("[TB] Simulation complete.");
        $stop;
    end

endmodule
