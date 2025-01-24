module crop_filter #(
    parameter PIXEL_BIT_WIDTH = 12,
    parameter IN_ROWS = 40,
    parameter IN_COLS = 40,
    parameter OUT_ROWS = 20,
    parameter OUT_COLS = 20,
    parameter Y_1 = 10,
    parameter X_1 = 10)
	(clk, reset, pixel_in, pixel_out, in_ready, in_valid, out_ready, out_valid);

    //////////////////////// I/0 ////////////////////////
    input wire clk, reset;
    input wire [PIXEL_BIT_WIDTH-1:0] pixel_in; 
    output reg [PIXEL_BIT_WIDTH-1:0] pixel_out;
    output reg in_ready; 
    input wire in_valid;
    input wire out_ready;
    output reg out_valid;

    //////////////////////// Internal signals ////////////////////////
    localparam IMG_COL_BITHWIDTH = $clog2(IN_COLS+1);
    reg [IMG_COL_BITHWIDTH - 1: 0] x; // x-coordinate of the pixel

    localparam IMG_ROW_BITHWIDTH = $clog2(IN_ROWS+1);
    reg [IMG_ROW_BITHWIDTH - 1: 0] y; // y-coordinate of the pixel

    reg pass_filter; // 1 if the pixel passes the filter, 0 otherwise
    reg idx_incr; // 1 if we should increment the x and y counters, 0 otherwise
    reg [PIXEL_BIT_WIDTH-1:0] pre_DFF_pixel_out;
    reg pre_DFF_out_valid;


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

    //////////////////////// Combinational logic: pre_DFF_pixel_out, in_ready, pre_DFF_out_valid, pass_filter, idx_incr ////////////////////////
    always @(*) begin   
        pre_DFF_pixel_out = pixel_in; // Keep it simple
        in_ready = out_ready; // Only accept new data if we can pass on existing data
        pre_DFF_out_valid = in_valid & pass_filter; // Only pass on data if it's new and it passes the filter

        // pass_filter logic
        if((y >= Y_1) && (y < Y_1+OUT_ROWS) && (x >= X_1) && (x < X_1+OUT_COLS)) pass_filter = 1'b1; // 1 inside crop-region
        else pass_filter = 1'b0; // 0 otherwise

        idx_incr = in_valid; // Increment the counters i.f.f. we receive new data // TODO: consider idx_incr = in_valid & in_ready
    end

    // Sequential logic: DFF pixel_out and out_valid (allow synthesis  more freedom to meet timing constraints)
    always @(posedge clk) begin
        pixel_out <= pre_DFF_pixel_out;
        out_valid <= pre_DFF_out_valid;
    end

endmodule
