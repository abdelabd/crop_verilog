module crop_plus_fifo #(
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
    output wire [PIXEL_BIT_WIDTH-1:0] pixel_out;
    output wire in_ready;
    input wire in_valid;
    input wire out_ready;
    output wire out_valid;

    //////////////////////// Internal signals: crop_filter <--> FIFO handshake and data transmission ////////////////////////
    wire intermediate_out_valid, intermediate_in_ready;
    wire [PIXEL_BIT_WIDTH-1:0] intermediate_pixel_out;

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
            .pixel_in(pixel_in),
            .pixel_out(intermediate_pixel_out),
            .in_ready(in_ready),
            .in_valid(in_valid),
            .out_ready(intermediate_in_ready),
            .out_valid(intermediate_out_valid));

    fifo_sync #(
        .DATA_WIDTH(PIXEL_BIT_WIDTH),
        .FIFO_DEPTH(OUT_ROWS*OUT_COLS))
        fifo_sync_inst(
            .clk(clk),
            .reset(reset),
            .in_data(intermediate_pixel_out),
            .in_valid(intermediate_out_valid),
            .in_ready(intermediate_in_ready),
            .out_data(pixel_out),
            .out_valid(out_valid),
            .out_ready(out_ready));

endmodule