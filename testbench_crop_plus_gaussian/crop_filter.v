
module crop_filter #(
    parameter PIXEL_BIT_WIDTH = 12,
    parameter IN_ROWS = 40,
    parameter IN_COLS = 40,
    parameter OUT_ROWS = 20,
    parameter OUT_COLS = 20,
    parameter Y_1 = 10,
    parameter X_1 = 10)
	(clk, reset, 
    pixel_in_TDATA, pixel_in_TVALID, pixel_in_TREADY,
    pixel_out_TDATA, pixel_out_TVALID, pixel_out_TREADY);

    //////////////////////// I/0 ////////////////////////
    input wire clk, reset;
    input wire [PIXEL_BIT_WIDTH-1:0] pixel_in_TDATA; 
    input wire pixel_in_TVALID;
    output reg pixel_in_TREADY; 
    output reg [PIXEL_BIT_WIDTH-1:0] pixel_out_TDATA;
    output reg pixel_out_TVALID;
    input wire pixel_out_TREADY;
    

    //////////////////////// Internal signals ////////////////////////
    localparam IMG_COL_BITHWIDTH = $clog2(IN_COLS)+1;
    reg [IMG_COL_BITHWIDTH - 1: 0] x; // x-coordinate of the pixel

    localparam IMG_ROW_BITHWIDTH = $clog2(IN_ROWS)+1;
    reg [IMG_ROW_BITHWIDTH - 1: 0] y; // y-coordinate of the pixel

    reg pass_filter; // 1 if the pixel passes the filter, 0 otherwise
    reg idx_incr; // 1 if we should increment the x and y counters, 0 otherwise

    //////////////////////// Sequential logic: determine the x- and y-coordinates of the pixel ////////////////////////
    always @(posedge clk) begin
        if (reset) begin // Reset all the counters to 0 
            x <= 0;
            y <= 0;
        end 
        else if (idx_incr) begin
            if (x == IN_COLS-1) begin
                x <= 0;
                if (y == IN_ROWS-1) y <= 0;
                else y <= y + 1;
            end 
            else  x <= x + 1;
        end
        else begin
            x <= x;
            y <= y;
        end
    end

    //////////////////////// Combinational logic: pre_DFF_pixel_out, pixel_in_TREADY, pre_DFF_pixel_out_TVALID, pass_filter, idx_incr ////////////////////////
    always @(*) begin   
        pixel_out_TDATA = pixel_in_TDATA;
        pixel_in_TREADY = pixel_out_TREADY; // Only accept new data if we can pass on existing data

        // pass_filter logic
        if((y >= Y_1) && (y < Y_1+OUT_ROWS) && (x > X_1) && (x <= X_1+OUT_COLS)) pass_filter = 1'b1; // 1 inside crop-region
        else pass_filter = 1'b0; // 0 otherwise

        // pre_DFF_pixel_out_TVALID = pixel_in_TVALID & pass_filter; // Only pass on data if it's new and it passes the filter
        pixel_out_TVALID = pixel_in_TVALID & pass_filter;

        idx_incr = pixel_in_TVALID & pixel_in_TREADY; // Increment the counters i.f.f. we receive new data 
    end

endmodule
