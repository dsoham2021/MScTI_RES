`timescale 1ns/1ps


module tb_top;

    logic clk, rst_n, pul_out;

    localparam DIV = 1000;

    pul_gen #(.DIV(DIV)) pDUT(.*);

    always #5 clk = ~clk;


    logic [31:0] ctr_clk;

    always @(posedge clk or negedge rst_n) begin

        if (!rst_n) ctr_clk <= 0;

        else ctr_clk <= ctr_clk + 1;

    end


    initial begin

        clk = 0;
        rst_n = 0;
        #7;
        rst_n = 1;

        repeat (100) @(posedge pul_out);
        $display("Clk %0d", ctr_clk);
        $finish;

    end

endmodule