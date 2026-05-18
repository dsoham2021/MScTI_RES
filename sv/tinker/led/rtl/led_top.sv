`timescale 1ns/1ps


module led_top (
    input logic clk,
    input logic rst_n,
    input logic [1:0] sw,
    output logic [15:0] led
); 

    logic pul_out;
    localparam DIV = 20000000;

    pul_gen #(.DIV(DIV)) pDUT(.*);

    led_binary lDUT(.clk(clk),
                    .rst_n(rst_n),
                    .clk_blink(pul_out),
                    .output_pattern(internal_led)
    );

    logic [15:0] pat0, pat1, pat2, pat3;
    logic [1:0] pattern_sel;
    logic [15:0] selected;

    led_binary binary_inst (.clk, .rst_n, .clk_blink(pul_out), .output_pattern(pat0));
    led_rotate   rotate_inst   (.clk, .rst_n, .clk_blink(pul_out), .dir(1'b1), .output_pattern(pat1));
    led_scanner  scanner_inst  (.clk, .rst_n, .clk_blink(pul_out), .output_pattern(pat2));
    led_random   random_inst   (.clk, .rst_n, .clk_blink(pul_out), .output_pattern(pat3));



    always_comb begin

        case (pattern_sel)

            2'b00 : selected = pat0;
            2'b01 : selected = pat1;
            2'b10 : selected = pat2;
            2'b11 : selected = pat3;

        endcase 
        
    end


    always_ff @(posedge clk or negedge rst_n) begin 

        if (!rst_n) begin
            led <= 16'd0;
        end
        else if (pul_out) begin
            led <= selected;
        end
        
    end

    assign pattern_sel = sw;

endmodule