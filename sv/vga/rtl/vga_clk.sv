import vga_pkg::*;


// Pixel generator for VGA (25 Mhz)

module vga_clk (
    input logic clk,
    input logic n_rst,
    output logic pixel_tick
);

    logic [1:0] ctr;

    always_ff @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            ctr <= 0;
            pixel_tick <= 0;
        end
        else begin
            if (ctr == 2'd3) begin
                ctr <= 0;
                pixel_tick <= 1'b1;  // 1-cycle pulse
            end
            else begin
                ctr <= ctr + 1;
                pixel_tick <= 1'b0;
            end
        end
    end

    
        

endmodule
