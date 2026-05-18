module led_rotate (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       clk_blink,
    input  logic       dir,        // 0 = left, 1 = right
    output logic [15:0] output_pattern
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            output_pattern <= 16'h0001;          // LED[0] on
        else if (clk_blink) begin
            if (dir)
                output_pattern <= {output_pattern[14:0], output_pattern[15]}; // rotate left
            else
                output_pattern <= {output_pattern[0], output_pattern[15:1]};  // rotate right
        end
    end
endmodule