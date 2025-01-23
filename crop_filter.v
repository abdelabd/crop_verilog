module crop_filter #(
    parameter PIXEL_BIT_WIDTH = 12,
    parameter IN_ROWS = 40,
    parameter IN_COLS = 40,
    parameter OUT_ROWS = 20,
    parameter OUT_COLS = 20,
    parameter Y_1 = 10,
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

    // Sequential logic
    always @(posedge clk) begin

        if (reset) begin // Reset all the counters to 0 
            next_x <= 0;
            next_y <= 0;
            x <= 0;
            y <= 0;
        end 
        
        else if (in_valid && out_ready) begin // if in_vald&&out_ready then increment the counters

            x <= next_x;
            y <= next_y;
            if (x == IN_COLS-1) begin
                next_x <= 0;
                next_y <= y + 1;
            end else begin
                next_x <= x + 1;
                next_y <= y;
            end

        end

    end

    // Combinational logic
    always @(*) begin

        if (in_valid&&out_ready) begin

            // if counters pass the crop-filter, send the pixel out
            if((y >= Y_1) && (y < Y_1+OUT_ROWS) && (x >= X_1) && (x < X_1+OUT_COLS)) begin 
                pixel_out = pixel_in;
                out_valid = 1'b1;
            end

            // else, don't send the pixel
            else begin
                out_valid = 1'b0;
                pixel_out = 'bX; // Don't care
            end
        
        end

        // else, don't send the pixel
        else begin
            out_valid = 1'b0;
            pixel_out = 'bX; // Don't care
        end

    end

endmodule
