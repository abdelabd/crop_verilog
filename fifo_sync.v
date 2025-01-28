// Synchronous FIFO with ready-valid handshake
module fifo_sync #(
    parameter DATA_WIDTH = 12,
    parameter FIFO_DEPTH = 20*20)
    (clk, reset, in_data, in_valid, in_ready, out_data, out_valid, out_ready);
    
    //////////////////////// I/0 ////////////////////////
    input wire clk, reset;
    input wire [DATA_WIDTH-1:0] in_data;
    input wire in_valid;
    output reg in_ready;
    output reg [DATA_WIDTH-1:0] out_data;
    output reg out_valid;
    input wire out_ready;


    //////////////////////// Internal signals ////////////////////////
    reg [DATA_WIDTH-1:0] fifo_mem [0:FIFO_DEPTH-1]; // FIFO memory
    reg [$clog2(FIFO_DEPTH):0] count;  // how many entries are in the FIFO
    reg [$clog2(FIFO_DEPTH)-1:0] w_ptr; // write pointer
    reg [$clog2(FIFO_DEPTH)-1:0] r_ptr; // read pointer

    //////////////////////// Sequential logic: write to FIFO memory ////////////////////////
    always @(posedge clk) begin
        if (reset) begin
            w_ptr <= 0;
        end else if (in_valid && in_ready) begin // Write if new data and we have space
            fifo_mem[w_ptr] <= in_data;
            if (w_ptr == FIFO_DEPTH - 1) w_ptr <= 0;
            else w_ptr <= w_ptr + 1;
        end
    end

    //////////////////////// Sequential logic: read from FIFO memory ////////////////////////
    always @(posedge clk) begin
        if (reset) begin
            r_ptr    <= 0;
            out_data <= {DATA_WIDTH{1'b0}};
        end else begin
            if (out_valid && out_ready) begin // Read if downstream is ready and we have unread data
                out_data <= fifo_mem[r_ptr];
                if (r_ptr == FIFO_DEPTH - 1) r_ptr <= 0;
                else r_ptr <= r_ptr + 1;
            end 
        end
    end

    //////////////////////// Sequential logic: keep track of count ////////////////////////
    always @(posedge clk) begin
        if (reset) begin
            count <= 0;
        end else begin
            if (in_valid && in_ready && !(out_valid && out_ready)) begin
                count <= count + 1; // Increment if we only write new data
            end else if (!(in_valid && in_ready) && (out_valid && out_ready)) begin
                count <= count - 1; // Decrement if we only read new data
            end 
            // else constant
        end
    end

    //////////////////////// Combinational logic: handshake signals ////////////////////////
    always @(*) begin
        in_ready  = (count < FIFO_DEPTH); // in_ready=1 if not full
        out_valid = (count > 0); // out_valid=1 if not empty
    end
    
endmodule
