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


    localparam IMG_IDX_MAX_VALUE = IN_ROWS * IN_COLS - 1;
    localparam IMG_IDX_BITWIDTH = $clog2(IMG_IDX_MAX_VALUE + 1); // +1 because $clog2(0) is undefined
    reg [IMG_IDX_BITWIDTH - 1: 0] img_idx, next_img_idx;

    localparam IMG_COL_BITHWIDTH = $clog2(IN_COLS+1);
    reg [IMG_COL_BITHWIDTH - 1: 0] x;

    localparam IMG_ROW_BITHWIDTH = $clog2(IN_ROWS+1);
    reg [IMG_ROW_BITHWIDTH - 1: 0] y;

    always @(posedge clk) begin

        if (reset) begin // Reset to next_img_idx = 0, out_valid = 0;
            next_img_idx <= 0;
            out_valid <= 1'b0;
        end 
        
        else if (in_valid && out_ready) begin

            // increment the index for each in_valid&out_ready clock-cycle
            img_idx <= next_img_idx;
            next_img_idx <= next_img_idx + 1; 

            // determine x and y of img_idx
            y <= img_idx / IN_COLS;
            x <= img_idx % IN_COLS;

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
