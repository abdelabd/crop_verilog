module crop_filter #(
    parameter PIXEL_BIT_WIDTH = 12,
    parameter IN_ROWS = 40,
    parameter IN_COLS = 40,
    parameter OUT_ROWS = 20,
    parameter OUT_COLS = 20,
    parameter IMG_COL_BITWIDTH = 10,
    parameter IMG_ROW_BITWIDTH = 10
    ) (clk, reset, 
    pixel_in_TDATA,  pixel_in_TVALID, pixel_in_TREADY, 
    pixel_out_TDATA, pixel_out_TVALID, pixel_out_TREADY, 
    crop_Y1_TDATA, crop_Y1_TVALID, crop_Y1_TREADY,
    crop_X1_TDATA, crop_X1_TVALID, crop_X1_TREADY
    );

    // crop-coordinate input goes: Y_1, X_1, Y_2, X_2, ...

    //////////////////////// I/0 ////////////////////////
    input wire clk, reset;
    input wire [PIXEL_BIT_WIDTH-1:0] pixel_in_TDATA;
    input wire pixel_in_TVALID;
    output reg pixel_in_TREADY;  
    output reg [PIXEL_BIT_WIDTH-1:0] pixel_out_TDATA;
    output reg pixel_out_TVALID;
    input wire pixel_out_TREADY;
    input wire [IMG_ROW_BITWIDTH-1:0] crop_Y1_TDATA;
    input wire crop_Y1_TVALID;
    output reg crop_Y1_TREADY;
    input wire [IMG_COL_BITWIDTH-1:0] crop_X1_TDATA;
    input wire crop_X1_TVALID;
    output reg crop_X1_TREADY;


    //////////////////////// Internal signals ////////////////////////
    reg [IMG_COL_BITWIDTH - 1: 0] x; // x-coordinate of the pixel
    reg [IMG_ROW_BITWIDTH - 1: 0] y; // y-coordinate of the pixel

    reg pass_filter; // 1 if the pixel passes the filter, 0 otherwise
    reg idx_incr; // 1 if we should increment the x and y counters, 0 otherwise

    // Sequential logic: Store x and y coordinates for top-left corner of crop-box
    reg y_received, x_received;
    reg [IMG_ROW_BITWIDTH-1:0] Y1;
    reg [IMG_COL_BITWIDTH-1:0] X1;
    always @(posedge clk) begin
        if (reset) begin
            y_received <= 1'b0;
            crop_Y1_TREADY <= 1'b1;
            x_received <= 1'b0;
            crop_X1_TREADY <= 1'b1;
        end
        else begin
            if (crop_Y1_TVALID & crop_Y1_TREADY) begin
                Y1 <= crop_Y1_TDATA;
                y_received <= 1'b1;
                crop_Y1_TREADY <= 1'b0;
            end
            if (crop_X1_TVALID & crop_X1_TREADY) begin
                X1 <= crop_X1_TDATA;
                x_received <= 1'b1;
                crop_X1_TREADY <= 1'b0;
            end
        end
    end

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

    //////////////////////// Combinational logic: pre_DFF_pixel_out, pixel_in_ready, pre_DFF_pixel_out_valid, pass_filter, idx_incr ////////////////////////
    always @(*) begin   
        pixel_out_TDATA = pixel_in_TDATA;
        pixel_in_TREADY = pixel_out_TREADY && y_received && x_received; // Only accept new data if we can pass on existing data, and we have the crop-coordinates

        // pass_filter logic
        if((y >= Y1) && (y < Y1+OUT_ROWS) && (x > X1) && (x <= X1+OUT_COLS)) pass_filter = 1'b1; // 1 inside crop-region
        else pass_filter = 1'b0; // 0 otherwise

        pixel_out_TVALID = pixel_in_TVALID & pass_filter;

        idx_incr = pixel_in_TVALID & pixel_in_TREADY; // Increment the counters i.f.f. we receive new data 
    end

endmodule
