
import vga_pkg::*;


module vga_tb;

    logic clk, n_rst;
    logic hsync, vsync;
    logic [3:0] r, g, b;
    parameter CLK_PERIOD_NS = 4;

    logic pixel_tick_tb;

    vga_top DUT(.*);

    always #(CLK_PERIOD_NS/2) clk = ~clk;

    initial begin

        // Reset on first clk edge
        clk = 0;
        n_rst = 0;
        #3ns;

        n_rst = 1;
         
    end

    // Reference modle for pixel generator pulse

    logic [1:0] tb_ctr;

    always_ff @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            tb_ctr <= 0;
            pixel_tick_tb <= 0;
        end
        else begin
            if (tb_ctr == 2'd3) begin
                tb_ctr <= 0;
                pixel_tick_tb <= 1'b1;
            end
            else begin
                tb_ctr <= tb_ctr + 1;
                pixel_tick_tb <= 1'b0;
            end
        end
    end


    // Reference models for hsync and vsync

    logic [9:0] h_count_ref, v_count_ref;


    always_ff @(posedge clk or negedge n_rst) begin 

        if (!n_rst) begin
            h_count_ref <= 0;
            v_count_ref <= 0;
        end

        else if (pixel_tick_tb) begin
            if (h_count_ref == H_MAX - 1) begin

                h_count_ref <= 0;

                if (v_count_ref == (V_MAX - 1)) begin
                    v_count_ref <= 0;
                end 

                else begin
                    v_count_ref <= v_count_ref + 1;
                end
            end

            else begin
                h_count_ref <= h_count_ref + 1;
            end
        end
    end


    initial begin

        repeat (H_MAX * V_MAX + 100) @(posedge pixel_tick_tb);

        if (v_count_ref >= 1)
            $display("PASS: VGA driver generated %0d complete frames", v_count_ref);
        else
            $error("FAIL: Not enough frames generated");
        $stop;


    end

    

endmodule