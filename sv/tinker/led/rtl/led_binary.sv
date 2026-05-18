

module led_binary (
    input logic clk, 
    input logic rst_n, 
    input logic clk_blink,
    output logic [15:0] output_pattern
); 

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) output_pattern <= 0;
        else if (clk_blink) output_pattern <= output_pattern + 16'h1;        
    end

endmodule