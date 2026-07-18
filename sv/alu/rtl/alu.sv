

module alu #(
    parameter WORD_W = 32;
)
(
    input logic [WORD_W-1: 0] rs1,
    input logic [WORD_W-1: 0] rs2,
    input logic [2:0] func_sel,
    output logic S[3:0],
    output logic [WORD_W-1: 0] R

);


    typedef enum logic[2:0] {

        OP_ZERO  = 4'h0,
        OP_NOP  = 4'h1,
        OP_NOT  = 4'h2,
        OP_AND  = 4'h3,
        OP_OR  = 4'h4,
        OP_XOR  = 4'h5,
        OP_ADD  = 4'h6,
        OP_SUB  = 4'h7,

    } alu_op_e;
    
    typedef enum logic[1:0] {
        S_ZERO  = 2'b00,
        S_SIGN  = 2'b01,
        S_OVERF = 2'b10,
        S_CARRY = 2'b11
    } status_e;



    always_comb begin
        
        unique case (func_sel)

            OP_ZERO : R = 0;

            OP_NOP : R = rs1;

            OP_NOT : R = ~rs1;

            OP_AND : R = rs1 & rs2;

            OP_OR : R = rs1 | rs2;

            OP_XOR: R = rs1 ^ rs2;

            OP_ADD: R = rs1 + rs2;

            OP_SUB: R = rs1 - rs2;

            default: R = '0;

        endcase
    end


    assign S[S_ZERO] = (R == '0);
    assign S[S_SIGN] = R[WORD_W-1];


    // For overflow and carry, the add and sub would have different logic

    






endmodule

