module crop_filter #(
    parameter IN_ROWS = 40;
    parameter IN_COLS = 40;
    parameter OUT_ROWS = 20;
    parameter OUT_COLS = 20;
    parameter Y_1 = 10;
    parameter X_1 = 10)
	(clk, reset, pixel_in, pixel_out, in_valid, out_ready, out_valid);

    input wire clk, reset;
    input wire [11:0] pixel_in;
    output reg [11:0] pixel_out;
    input wire in_valid;
    // output logic in_ready;
    input wire out_ready;
    output reg out_valid;

    integer img_idx;

    always @(posedge clk) begin

        if (reset) begin
            img_idx <= 0;
            // in_ready <= 1'b1;
            out_valid <= 1'b0;
        end 
        
        else if (in_valid && out_ready) begin

            if (img_idx < IN_ROWS * IN_COLS) begin

                if (img_idx % IN_COLS >= X_1 && img_idx / IN_COLS >= Y_1) begin
                    pixel_out <= pixel_in;
                    out_valid <= 1'b1;
                end 

                else begin
                    out_valid <= 1'b0;
                end

                img_idx <= img_idx + 1;

            end 
            
            else begin
                out_valid <= 1'b0;
            end

        end else begin
            out_valid <= 1'b0;
        end

    end

endmodule
