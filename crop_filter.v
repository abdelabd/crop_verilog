module crop_filter #(
    parameter PIXEL_BIT_WIDTH = 12,
    parameter IN_ROWS = 40;
    parameter IN_COLS = 40;
    parameter OUT_ROWS = 20;
    parameter OUT_COLS = 20;
    parameter Y_1 = 10;
    parameter X_1 = 10)
	(clk, reset, pixel_in, pixel_out, in_valid, out_ready, out_valid);

    input wire clk, reset;
    input wire [PIXEL_BIT_WIDTH-1:0] pixel_in; 
    output reg [PIXEL_BIT_WIDTH-1:0] pixel_out;
    input wire in_valid;
    // output logic in_ready; // No real need for this, the camera grabber spits out pixels and it's our job to catch them
    input wire out_ready;
    output reg out_valid;

    localparam IMG_COL_BITHWIDTH = $clog2(IN_COLS+1);
    reg [IMG_COL_BITHWIDTH - 1: 0] x, next_x;

    localparam IMG_ROW_BITHWIDTH = $clog2(IN_ROWS+1);
    reg [IMG_ROW_BITHWIDTH - 1: 0] y, next_y;

    always @(posedge clk) begin

        if (reset) begin // Reset to (next_x, next_y) = (0, 0) and out_valid=0
            next_x <= 0;
            next_y <= 0;
            out_valid <= 1'b0;
        end 
        
        else if (in_valid && out_ready) begin

            // determine x and y of incoming pixel
            x <= next_x;
            y <= next_y;
            if (x == IN_COLS-1) begin
                next_x <= 0;
                next_y <= y + 1;
            end else begin
                next_x <= x + 1;
                next_y <= y;
            end

            // if it passes the crop-filter, send the pixel out
            if((y >= Y_1) && (y < Y_1+OUT_ROWS) && (x >= X_1) && (x < X_1+OUT_COLS)) begin 
                pixel_out <= pixel_in;
                out_valid <= 1'b1;
            end

            // else, don't send the pixel
            else begin
                out_valid <= 1'b0;
            end

                
        end 
        
    end

endmodule
