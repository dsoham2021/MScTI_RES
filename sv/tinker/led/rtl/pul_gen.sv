`timescale 1ns/1ps


module pul_gen #(
    parameter DIV = 4,
    localparam CTR_WIDTH = $clog2(DIV)
) (
    input logic clk,
    input logic rst_n,

    output logic pul_out
);

    logic [CTR_WIDTH-1 : 0] ctr;

    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin
            ctr <= 0;
            pul_out <= 1'b0;
        end
        
        else if (ctr == (DIV-1)) begin
            pul_out <= 1'b1;
            ctr <= 0;
        end

        else begin
            pul_out <= 1'b0;
            ctr <= ctr + 1;
        end

        
    end

endmodule