module led_random (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       clk_blink,
    output logic [15:0] output_pattern
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            output_pattern <= 16'hACE1;     // non‑zero seed
        else if (clk_blink) begin
            output_pattern <= {output_pattern[14:0],
                               output_pattern[15] ^ output_pattern[14] ^ output_pattern[12] ^ output_pattern[3]};
        end
    end
endmodule