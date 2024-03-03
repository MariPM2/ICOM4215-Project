module SecondOperandHandler(
    output reg [31:0] N, 
    input [31:0] PB, 
    input [2:0] Si,
    input [31:0] imm12_I,
    input [31:0] imm12_S,
    input [19:0] imm20,
    input [31:0] PC
);

always @(PB, Si, imm12_I, imm12_S, imm20, PC)
begin
    case(Si)
        3'b000: N = PB; 
        3'b001: N = {{12{imm12_I[11]}}, imm12_I};
        3'b010: N = {{12{imm12_S[11]}}, imm12_S};
        3'b011:  N = {imm20,  20'b0};
         /*
        NOT USED:
        3'b100:
        3'b101:
        */
        default: N = 32'b0;
    endcase
end
endmodule