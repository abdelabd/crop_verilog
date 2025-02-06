// Synchronous FIFO with ready-valid handshake
module fifo_sync #(
    parameter DATA_WIDTH = 12,
    parameter FIFO_DEPTH = 20*20)
    (clk, reset, in_TDATA, in_TVALID, in_TREADY, out_TDATA, out_TVALID, out_TREADY);
    
    //////////////////////// I/0 ////////////////////////
    input wire clk, reset;
    input wire [DATA_WIDTH-1:0] in_TDATA;
    input wire in_TVALID;
    output reg in_TREADY;
    output reg [DATA_WIDTH-1:0] out_TDATA;
    output reg out_TVALID;
    input wire out_TREADY;


    //////////////////////// Internal signals ////////////////////////
    reg [DATA_WIDTH-1:0] fifo_mem [0:FIFO_DEPTH-1]; // FIFO memory
    reg [$clog2(FIFO_DEPTH):0] count;  // how many entries are in the FIFO
    reg [$clog2(FIFO_DEPTH)-1:0] w_ptr; // write pointer
    reg [$clog2(FIFO_DEPTH)-1:0] r_ptr; // read pointer

    //////////////////////// Sequential logic: write to FIFO memory ////////////////////////

    always @(posedge clk) begin
        if (reset) begin
            w_ptr <= 0;
        end else if (in_TVALID && in_TREADY) begin // Write if new data and we have space
            fifo_mem[w_ptr] <= in_TDATA;
            if (w_ptr == FIFO_DEPTH - 1) w_ptr <= 0;
            else w_ptr <= w_ptr + 1;
        end
    end

    //////////////////////// Sequential logic: read from FIFO memory ////////////////////////

    always @(posedge clk) begin
        if (reset) begin
            r_ptr    <= 0;
            out_TDATA <= {DATA_WIDTH{1'b0}};
        end else begin
            if (out_TVALID && out_TREADY) begin // Read if downstream is ready and we have unread data
                out_TDATA <= fifo_mem[r_ptr];
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
            if (in_TVALID && in_TREADY && !(out_TVALID && out_TREADY)) begin
                count <= count + 1; // Increment if we only write new data
            end else if (!(in_TVALID && in_TREADY) && (out_TVALID && out_TREADY)) begin
                count <= count - 1; // Decrement if we only read new data
            end 
            // else constant
        end
    end

    //////////////////////// Combinational logic: handshake signals ////////////////////////
    always @(*) begin
        in_TREADY  = (count < FIFO_DEPTH); // in_TREADY=1 if not full
        out_TVALID = (count > 0); // out_valid=1 if not empty
    end
    
endmodule
