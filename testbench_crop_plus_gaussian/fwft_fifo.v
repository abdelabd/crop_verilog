module first_word_fall_through_fifo #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH      = 8
)(
    input  wire                     clk,
    input  wire                     reset,
    
    // AXI-Stream–style input interface
    input  wire [DATA_WIDTH-1:0]    in_data,
    input  wire                     in_valid,
    output wire                     in_ready,
    
    // AXI-Stream–style output interface
    output wire [DATA_WIDTH-1:0]    out_data,
    output wire                     out_valid,
    input  wire                     out_ready
);

    // Compute the number of bits needed for addressing (log2 of DEPTH)
    localparam ADDR_WIDTH = $clog2(DEPTH);

    // ------------------------------------------------------------------------
    // Internal Signals
    // ------------------------------------------------------------------------
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    // ^ A simple memory array that stores data in the FIFO.

    reg [ADDR_WIDTH-1:0] wr_ptr; 
    // ^ Write pointer: points to the location where the next incoming word (if in_valid & in_ready) will be stored.

    reg [ADDR_WIDTH-1:0] rd_ptr; 
    // ^ Read pointer: points to the location of the next word to read out.

    reg [ADDR_WIDTH:0]   count;  
    // ^ Holds the current number of words in the FIFO. Range is 0 to DEPTH.
    //   (ADDR_WIDTH+1 bits allow counting up to DEPTH.)

    // ------------------------------------------------------------------------
    // Assign top-level outputs
    // ------------------------------------------------------------------------
    // FIFO is not empty if count != 0, so out_valid is 1 whenever there is data in the FIFO.
    assign out_valid = (count != 0);

    // FIFO is not full if count < DEPTH, so in_ready is 1 whenever there is space in the FIFO.
    assign in_ready  = (count < DEPTH);

    // For a first-word fall-through FIFO, out_data should reflect the data at the read pointer
    // without requiring an extra read cycle. Typically this requires using a memory implementation
    // that can output the stored data asynchronously or on the next clock edge.
    // Many FPGAs allow a synchronous write / asynchronous read mode.
    assign out_data = mem[rd_ptr];

    // ------------------------------------------------------------------------
    // Main FIFO Logic
    // ------------------------------------------------------------------------
    always @(posedge clk) begin
        if (reset) begin
            // On reset, clear everything
            wr_ptr <= 0;
            rd_ptr <= 0;
            count  <= 0;
        end
        else begin
            // ----------------------------
            // 1) Write logic
            // ----------------------------
            if (in_valid && in_ready) begin
                // Write incoming data into memory at wr_ptr
                mem[wr_ptr] <= in_data;
                // Move write pointer
                wr_ptr <= wr_ptr + 1'b1;
                // Increment count
                count  <= count + 1'b1;
            end

            // ----------------------------
            // 2) Read logic
            // ----------------------------
            if (out_valid && out_ready) begin
                // Advance read pointer
                rd_ptr <= rd_ptr + 1'b1;
                // Decrement count
                count  <= count - 1'b1;
            end
        end
    end

endmodule
