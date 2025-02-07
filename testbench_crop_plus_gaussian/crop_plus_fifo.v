module crop_plus_fifo #(
    parameter PIXEL_BIT_WIDTH = 12,
    parameter IN_ROWS = 40,
    parameter IN_COLS = 40,
    parameter OUT_ROWS = 20,
    parameter OUT_COLS = 20,
    parameter IMG_ROW_BITWIDTH = 10,
    parameter IMG_COL_BITWIDTH = 10)
    (clk, reset, 
    pixel_in_TDATA, pixel_in_TVALID, pixel_in_TREADY,
    crop_Y1_TDATA, crop_Y1_TVALID, crop_Y1_TREADY,
    crop_X1_TDATA, crop_X1_TVALID, crop_X1_TREADY,
    pixel_out_TDATA, pixel_out_TVALID, pixel_out_TREADY);

    //////////////////////// I/0 ////////////////////////
    input wire clk, reset;
    input wire [PIXEL_BIT_WIDTH-1:0] pixel_in_TDATA; 
    input wire pixel_in_TVALID;
    output wire pixel_in_TREADY; 
    input wire [IMG_ROW_BITWIDTH-1:0] crop_Y1_TDATA;
    input wire crop_Y1_TVALID;
    output wire crop_Y1_TREADY;
    input wire [IMG_COL_BITWIDTH-1:0] crop_X1_TDATA;
    input wire crop_X1_TVALID;
    output wire crop_X1_TREADY;
    output wire [PIXEL_BIT_WIDTH-1:0] pixel_out_TDATA;
    output wire pixel_out_TVALID;
    input wire pixel_out_TREADY;

    //////////////////////// Internal signals: crop_filter <--> FIFO handshake and data transmission ////////////////////////
    wire intermediate_pixel_out_TVALID, intermediate_pixel_in_TREADY;
    wire [PIXEL_BIT_WIDTH-1:0] intermediate_pixel_out_TDATA;

    //////////////////////// Submodules ////////////////////////
    crop_filter #(
        .PIXEL_BIT_WIDTH(PIXEL_BIT_WIDTH),
        .IN_ROWS(IN_ROWS),
        .IN_COLS(IN_COLS),
        .OUT_ROWS(OUT_ROWS),
        .OUT_COLS(OUT_COLS),
        .IMG_ROW_BITWIDTH(IMG_ROW_BITWIDTH),
        .IMG_COL_BITWIDTH(IMG_COL_BITWIDTH)
        )crop_filter_inst(
            .clk(clk),
            .reset(reset),
            .pixel_in_TDATA(pixel_in_TDATA),
            .pixel_in_TVALID(pixel_in_TVALID),
            .pixel_in_TREADY(pixel_in_TREADY),
            .crop_Y1_TDATA(crop_Y1_TDATA),
            .crop_Y1_TVALID(crop_Y1_TVALID),
            .crop_Y1_TREADY(crop_Y1_TREADY),
            .crop_X1_TDATA(crop_X1_TDATA),
            .crop_X1_TVALID(crop_X1_TVALID),
            .crop_X1_TREADY(crop_X1_TREADY),
            .pixel_out_TDATA(intermediate_pixel_out_TDATA),
            .pixel_out_TREADY(intermediate_pixel_in_TREADY),
            .pixel_out_TVALID(intermediate_pixel_out_TVALID));

    fifo_sync #(
        .DATA_WIDTH(PIXEL_BIT_WIDTH),
        .FIFO_DEPTH(OUT_ROWS*OUT_COLS))
        fifo_sync_inst(
            .clk(clk),
            .reset(reset),
            .in_TDATA(intermediate_pixel_out_TDATA),
            .in_TVALID(intermediate_pixel_out_TVALID),
            .in_TREADY(intermediate_pixel_in_TREADY),
            .out_TDATA(pixel_out_TDATA),
            .out_TVALID(pixel_out_TVALID),
            .out_TREADY(pixel_out_TREADY));

endmodule