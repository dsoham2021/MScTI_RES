
import vga_pkg::*;

module vga_top (
    input logic clk,
    input logic n_rst,

    output logic hsync,
    output logic vsync,

    output logic [3:0] r,
    output logic [3:0] g,
    output logic [3:0] b
);

    logic[9:0] hsync_ctr, vsync_ctr;
    logic[9:0] hsync_ctr_inc, vsync_ctr_inc;
    logic line_end, frame_end;

    logic pixel_tick;

    vga_clk u_clkgen(.*);


    always_ff @( posedge clk or negedge n_rst ) begin

        if (!n_rst) begin
            hsync_ctr <= 1'b0;
            vsync_ctr <= 1'b0;
        end
        else if (pixel_tick) begin
            hsync_ctr <= (line_end) ? 1'b0 : hsync_ctr_inc;
            vsync_ctr <= (frame_end && line_end) ? 1'b0 : ((line_end) ? (vsync_ctr_inc) : vsync_ctr);
        end
    end


    assign line_end = (hsync_ctr == HSYNC2_END);
    assign frame_end = (vsync_ctr == VSYNC2_END);

    assign hsync_ctr_inc = hsync_ctr + 1;
    assign vsync_ctr_inc = vsync_ctr + 1;


    // HSYNC and VSYNC are active  (But keeping high for ease to debug)
    
    assign hsync = ~(hsync_ctr > HSYNC1_END && hsync_ctr <= HSYNC2_START);
    assign vsync = ~(vsync_ctr > VSYNC1_END && vsync_ctr <= VSYNC2_START);


    // RGB Output signals

    assign r = ((hsync_ctr < H_ACTIVE) && (vsync_ctr < V_ACTIVE)) ? 4'hF : 4'h0;
    assign g = ((hsync_ctr < H_ACTIVE) && (vsync_ctr < V_ACTIVE)) ? 4'h0 : 4'h0;
    assign b = ((hsync_ctr < H_ACTIVE) && (vsync_ctr < V_ACTIVE)) ? 4'h0 : 4'h0;



endmodule