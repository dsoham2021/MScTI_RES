module led_scanner (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       clk_blink,
    output logic [15:0] output_pattern
);
    logic [4:0] pos;          // 0–15 position
    logic       direction;    // 1 = move to higher index

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pos       <= 5'd0;
            direction <= 1'b1;   // start moving toward LED[15]
        end
        else if (clk_blink) begin
            if (direction) begin
                if (pos == 15)
                    direction <= 1'b0;   // bounce
                else
                    pos <= pos + 1;
            end else begin
                if (pos == 0)
                    direction <= 1'b1;   // bounce
                else
                    pos <= pos - 1;
            end
        end
    end

    // One-hot decode of position
    always_comb begin
        output_pattern = 16'd0;
        output_pattern[pos] = 1'b1;
    end
endmodule