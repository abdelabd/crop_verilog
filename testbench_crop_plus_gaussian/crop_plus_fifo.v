module crop_plus_fifo #(
    parameter PIXEL_BIT_WIDTH = 12,
    parameter IN_ROWS = 40,
    parameter IN_COLS = 40,
    parameter OUT_ROWS = 20,
    parameter OUT_COLS = 20,
    parameter Y_1 = 10,
    parameter X_1 = 10)
    (clk, reset, pixel_in_TDATA, pixel_out_TDATA, pixel_in_TREADY, pixel_in_TVALID, pixel_out_TREADY, pixel_out_TVALID);

    //////////////////////// I/0 ////////////////////////
    input wire clk, reset;
    input wire [PIXEL_BIT_WIDTH-1:0] pixel_in_TDATA;
    output wire [PIXEL_BIT_WIDTH-1:0] pixel_out_TDATA;
    output wire pixel_in_TREADY;
    input wire pixel_in_TVALID;
    input wire pixel_out_TREADY;
    output wire pixel_out_TVALID;

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
        .Y_1(Y_1),
        .X_1(X_1))
        crop_filter_inst(
            .clk(clk),
            .reset(reset),
            .pixel_in_TDATA(pixel_in_TDATA),
            .pixel_out_TDATA(intermediate_pixel_out_TDATA),
            .pixel_in_TREADY(pixel_in_TREADY),
            .pixel_in_TVALID(pixel_in_TVALID),
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